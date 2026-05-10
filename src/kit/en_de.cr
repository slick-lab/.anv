require "openssl/cipher"
require "openssl/hmac"
require "base64"
require "./master_key"

def read_master_key : String?
  get_master_key
end

def encrypt(data : String, key : String) : String?
  raw_key = key.hexbytes
  enc_key = raw_key[0, 32]
  hmac_key = raw_key[32, 32]

  cipher = OpenSSL::Cipher.new("AES-256-CBC")
  cipher.encrypt
  cipher.key = enc_key

  iv = Random::Secure.random_bytes(16)
  cipher.iv = iv

  encrypted = cipher.update(data) + cipher.final

  mac = OpenSSL::HMAC.digest(:SHA256, hmac_key, iv + encrypted)

  combined = iv + mac + encrypted
  Base64.encode(combined)
rescue ex
  puts "Encryption failed: #{ex.message}"
  nil
end

def decrypt(encoded : String, key : String) : String?
  raw_key = key.hexbytes
  enc_key = raw_key[0, 32]
  hmac_key = raw_key[32, 32]

  combined = Base64.decode(encoded)

  iv = combined[0, 16]
  mac = combined[16, 32]
  encrypted_data = combined[48..-1]

  expected_mac = OpenSSL::HMAC.digest(:SHA256, hmac_key, iv + encrypted_data)

  if mac != expected_mac
    puts "Decryption failed: HMAC mismatch"
    return nil
  end

  cipher = OpenSSL::Cipher.new("AES-256-CBC")
  cipher.decrypt
  cipher.key = enc_key
  cipher.iv = iv

   bytes = cipher.update(encrypted_data) + cipher.final
   String.new(bytes)
rescue ex
  puts "Decryption failed: #{ex.message}"
  nil
end
