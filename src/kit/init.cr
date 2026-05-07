require "openssl/cipher"
require "base64"
require "random/secure"

def init
  puts "...initializing .anv..."
  if File.exists?(".anv")
    puts ".anv file exists use -h for help"
  else
    Dir.mkdir_p(".anv")
    key = Random::Secure.hex(32)
    File.write(".anv/master.key", key)
    File.chmod(".anv/master.key", 0o600)
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
    template_data = "{}"
    cipher = OpenSSL::Cipher.new("AES-256-GCM")
    cipher.encrypt
    cipher.key = key.hexbytes
    iv = Random::Secure.random_bytes(12)
    cipher.iv = iv
    encrypted = cipher.update(template_data) + cipher.final
    tag = cipher.auth_tag
    combined = iv + tag + encrypted
    encoded = Base64.encode(combined)
    File.write(".anv/store", encoded)
    puts ".anv initialized successfully"
    puts "master key saved to .anv/master.key"
    puts "do NOT commit .anv/master.key to git"
  end
end
