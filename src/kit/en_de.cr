require "openssl/cipher"
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

def encrypt(data : String, key : String) : String?
  store_path = ".anv/store"
  
  cipher = OpenSSL::Cipher.new("AES-256-GCM")
  cipher.encrypt
  cipher.key = key.hexbytes
  
  iv = Random::Secure.random_bytes(12)
  cipher.iv = iv
  
  encrypted = cipher.update(data) + cipher.final
  tag = cipher.auth_tag
  
  combined = iv + tag + encrypted
  encoded = Base64.encode(combined)
  
  # Hardcoded path - no choice given
  File.write(store_path, encoded)
  
  return "encrypted successfully"
rescue ex
  puts "Encryption failed: #{ex.message}"
  return nil
end

def decrypt(key : String) : String?
  store_path = ".anv/store"
  master_key_path = ".anv/master.key"
  
  unless File.exist?(store_path)
    puts "ERROR: No store found at #{store_path}"
    return nil
  end
  
  unless File.exist?(master_key_path)
    puts "ERROR: No master key found at #{master_key_path}"
    return nil
  end
  
  encrypted = File.read(store_path)
  
  cipher = OpenSSL::Cipher.new("AES-256-GCM")
  cipher.decrypt
  cipher.key = key.hexbytes
  
  combined = Base64.decode(encrypted)
  iv = combined[0, 12]
  tag = combined[12, 16]
  encrypted_data = combined[28..-1]
  
  cipher.iv = iv
  cipher.auth_tag = tag
  
  plain = cipher.update(encrypted_data) + cipher.final
  return plain
rescue ex
  puts "Decryption failed: #{ex.message}"
  puts "Possible causes: corrupted store or wrong master key"
  return nil
end
