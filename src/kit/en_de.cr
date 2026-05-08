require "openssl/cipher"
require "openssl/hmac"
require "base64"

def read_master_key : String?
  master_key_path = ".anv/master.key"
  
  unless File.exist?(master_key_path)
    puts "ERROR: No master key found at #{master_key_path}"
    puts "Please run init first"
    return nil
  end
  
  File.read(master_key_path).strip
end

def encrypt_hmac(data : String, key : String) : String?
  raw_key = key.hexbytes
  enc_key = raw_key[0, 32]
  hmac_key = raw_key[32, 32]
  
  cipher = OpenSSL::Cipher.new("AES-256-CBC")
  cipher.encrypt
  cipher.key = enc_key
  
  iv = Random::Secure.random_bytes(16)
  cipher.iv = iv
  
  encrypted = cipher.update(data) + cipher.final
  
  mac = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA256.new, hmac_key, iv + encrypted)
  
  combined = iv + mac + encrypted
  Base64.encode(combined)
rescue ex
  puts "Encryption failed: #{ex.message}"
  nil
end

def decrypt_hmac(encoded : String, key : String) : String?
  raw_key = key.hexbytes
  enc_key = raw_key[0, 32]
  hmac_key = raw_key[32, 32]
  
  combined = Base64.decode(encoded)
  
  iv = combined[0, 16]
  mac = combined[16, 32]
  encrypted_data = combined[48..-1]
  
  expected_mac = OpenSSL::HMAC.digest(OpenSSL::Digest::SHA256.new, hmac_key, iv + encrypted_data)
  
  unless OpenSSL.secure_compare(mac, expected_mac)
    puts "Decryption failed: HMAC mismatch"
    return nil
  end
  
  cipher = OpenSSL::Cipher.new("AES-256-CBC")
  cipher.decrypt
  cipher.key = enc_key
  cipher.iv = iv
  
  cipher.update(encrypted_data) + cipher.final
rescue ex
  puts "Decryption failed: #{ex.message}"
  nil
end
