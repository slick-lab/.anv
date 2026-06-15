require "random/secure"
require "system"

def set_master_key : String
  key = Random::Secure.hex(128)
  # lets try to check if there is a key in the keyring first, if there is we should use that instead of creating a new one, otherwise we will lose access to all secrets on every run 
  check_key = get_master_key
  return check_key if check_key
  if system("which secret-tool > /dev/null 2>&1")
    success = system("echo '#{key}' | secret-tool store --label='anv master key' anv-key master")
    if success
      puts " Master key stored in system keyring (secret-tool)"
      return key
    else
      puts " Failed to store master key with secret-tool"
      "" 
    end
  elsif system("which security > /dev/null 2>&1")
    success = system("security add-generic-password -a #{ENV["USER"]} -s anv-master-key -w '#{key}'")
    if success
      puts " Master key stored in system keychain (security)"
      return key
    else
      puts " Failed to store master key with security"
      ""
    end
  else
    puts " No supported keyring found (secret-tool or security)"
    puts "   Install libsecret-tools on Linux or use macOS Keychain"
     ""
  end
end

def get_master_key : String?
  if system("which secret-tool > /dev/null 2>&1")
    key = `secret-tool lookup anv-key master`.strip
    unless key.empty?
      return key
    else
      puts " secret-tool found but no key stored"
    end
  end
  
  if system("which security > /dev/null 2>&1")
    key = `security find-generic-password -a #{ENV["USER"]} -s anv-master-key -w 2>/dev/null`.strip
    unless key.empty?
      return key
    else
      puts " security found but no key stored"
    end
  end
  
  puts " Master key not found in any system keyring"
  nil
end

def display_master_key
  key = get_master_key
  if key
    puts "Master Key: #{key}"
  else
    puts "No master key found. Run `anv init` to create one."
  end
end

def delete_master_key
  if system("which secret-tool > /dev/null 2>&1")
    system("secret-tool clear anv-key master")
  end
  if system("which security > /dev/null 2>&1")  
    system("security delete-generic-password -a #{ENV["USER"]} -s anv-master-key")
  end
end
