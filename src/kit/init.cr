require "./en_de"
require "random/secure"

def init
  puts "...initializing .anv..."
  if File.exists?(".anv")
    puts ".anv file exists use -h for help"
  else
    Dir.mkdir_p(".anv")
    # Generate a 64-byte key (128 hex chars) for CBC + HMAC
    key = Random::Secure.hex(64)
    File.write(".anv/master.key", key)
    File.chmod(".anv/master.key", 0o600)
    
    # Update .gitignore
    if File.exists?(".gitignore")
      ignore_content = File.read(".gitignore")
      unless ignore_content.includes?(".anv/master.key")
        File.open(".gitignore", "a") do |file|
          file.puts "\n.anv/master.key"
        end
      end
    else
      File.write(".gitignore", ".anv/master.key\n")
    end
    
    # Create initial encrypted store using  new encrypt_hmac
    template_data = "{}"
    encrypted_store = encrypt_hmac(template_data, key)
    if encrypted_store.nil?
      puts "ERROR: Failed to encrypt initial store"
      return
    end
    File.write(".anv/store", encrypted_store)
    
    puts ".anv initialized successfully"
    puts "master key saved to .anv/master.key"
    puts "do NOT commit .anv/master.key to git"
  end
end
