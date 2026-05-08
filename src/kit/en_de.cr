require "openssl/cipher"
require "base64"
require "hmac"

def encrypt_hmac(data : String, key : String) : String?
  # Key derivation: use first 32 bytes for encryption, next 32 bytes for HMAC
  raw_key = key.hexbytes
  enc_key = raw_key[0, 32]
  hmac_key = raw_key[32, 32]
  
  # Encrypt
  cipher = OpenSSL::Cipher.new("AES-256-CBC")
  cipher.encrypt
  cipher.key = enc_key
  
  iv = Random::Secure.random_bytes(16)
  cipher.iv = iv
  
  encrypted = cipher.update(data) + cipher.final
  
  # Create HMAC of IV + encrypted data
  hmac = HMAC.new(hmac_key, :sha256)
  hmac << iv
  hmac << encrypted
  mac = hmac.digest
  
  # Pack: IV (16) + MAC (32) + Encrypted data
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
  
  # Unpack
  iv = combined[0, 16]
  mac = combined[16, 32]
  encrypted_data = combined[48..-1]
  
  # Verify HMAC before decryption
  hmac = HMAC.new(hmac_key, :sha256)
  hmac << iv
  hmac << encrypted_data
  expected_mac = hmac.digest
  
  unless mac.bytes == expected_mac.bytes
    puts "Decryption failed: HMAC mismatch - data tampered or wrong key"
    return nil
  end
  
  # Decrypt
  cipher = OpenSSL::Cipher.new("AES-256-CBC")
  cipher.decrypt
  cipher.key = enc_key
  cipher.iv = iv
  
  cipher.update(encrypted_data) + cipher.final
rescue ex
  puts "Decryption failed: #{ex.message}"
  nil
end
