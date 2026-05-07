require "openssl/cipher"

def read_master_key : String
  if File.exist?(".anv/master.key")
   file = File.read(".anv/master.key")
    file
  else
   return "error no master key found"
 end 
end

def encrypt(data : String, key : String)
    file = ".anv/store"
    cipher = OpenSSL::Cipher.new("AES-256-GCM")
    cipher.encrypt
    cipher.key = key.hexbytes
    iv = Random::Secure.random_bytes(12)
    cipher.iv = iv
    encrypted = cipher.update(data) + cipher.final
    tag = cipher.auth_tag
    combined = iv + tag + encrypted
    encoded = Base64.encode(combined)
    File.write(".anv/store", encoded)
    puts ".anv initialized successfully"
    puts "master key saved to .anv/master.key"
    puts "do NOT commit .anv/master.key to git"
end
     
