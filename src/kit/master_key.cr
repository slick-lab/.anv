require "random/secure"
require "system"

def set_master_key : Bool
  key = Random::Secure.hex(64)
  
  if system("which secret-tool > /dev/null 2>&1")
    success = system("echo '#{key}' | secret-tool store --label='anv master key' anv-key master")
    if success
      puts " Master key stored in system keyring (secret-tool)"
      return true
    else
      puts " Failed to store master key with secret-tool"
      return false
    end
  elsif system("which security > /dev/null 2>&1")
    success = system("security add-generic-password -a #{ENV["USER"]} -s anv-master-key -w '#{key}'")
    if success
      puts " Master key stored in system keychain (security)"
      return true
    else
      puts " Failed to store master key with security"
      return false
    end
  else
    puts " No supported keyring found (secret-tool or security)"
    puts "   Install libsecret-tools on Linux or use macOS Keychain"
    return false
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
