require "openssl/cipher"
require "base64"
require "random/secure"

def init
 puts "...initializing .anv..."
if File.exist?(".anv")
 puts ".anv file exists use -h for help")
else 
 File.touch(".anv")
 puts "created .anv file starting encryption.."
 start_encryption
end

def start_encryption
  key = Random::Secure.hex(32)
  puts "saving key.."
  Dir.mkdir_p("anv")
  File.write("anv/master.key", key)
  template_data = "anv secret protector"
  cipher = OpenSSL::Cipher.new("AES-256-GCM")
  cipher.encrypt 
  cipher.key = key.hexabyte
  iv = Random::Secure.random_bytes(12)
  cipher.iv = iv
  encrypted = cipher.update(template_data) + cipher.final
  tag = cipher.auth_tag
  combined = iv + tag + encrypted 
  Base64.encode(combined)
end 
   
