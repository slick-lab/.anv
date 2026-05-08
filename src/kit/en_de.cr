require "openssl/cipher"
require "base64"

@[Link("crypto")]
lib LibCrypto
  EVP_CTRL_GCM_GET_TAG = 0x10
  EVP_CTRL_GCM_SET_TAG = 0x11
  EVP_GCM_TLS_TAG_LEN = 16
  fun evp_cipher_ctx_ctrl = EVP_CIPHER_CTX_ctrl(ctx : Void*, type : Int32, arg : Int32, ptr : Void*) : Int32
end

class OpenSSL::Cipher
  def auth_tag : Bytes
    tag = Bytes.new(LibCrypto::EVP_GCM_TLS_TAG_LEN)
    LibCrypto.evp_cipher_ctx_ctrl(@ctx, LibCrypto::EVP_CTRL_GCM_GET_TAG, tag.size, pointerof(tag).as(Void*))
    tag
  end

  def auth_tag=(tag : Bytes)
    LibCrypto.evp_cipher_ctx_ctrl(@ctx, LibCrypto::EVP_CTRL_GCM_SET_TAG, tag.size, pointerof(tag).as(Void*))
  end
end

def read_master_key : String?
  master_key_path = ".anv/master.key"
  
  unless File.exists?(master_key_path)
    puts "ERROR: No master key found at #{master_key_path}"
    puts "Please run init first"
    return nil
  end
  
  File.read(master_key_path).strip
end

def encrypt(data : String, key : String) : String?
  cipher = OpenSSL::Cipher.new("AES-256-GCM")
  cipher.encrypt
  cipher.key = key.hexbytes
  
  iv = Random::Secure.random_bytes(12)
  cipher.iv = iv
  
  encrypted = cipher.update(data) + cipher.final
  tag = cipher.auth_tag
  
  combined = iv + tag + encrypted
  Base64.encode(combined)
rescue ex
  puts "Encryption failed: #{ex.message}"
  return nil
end

def decrypt(encoded : String, key : String) : String?
  cipher = OpenSSL::Cipher.new("AES-256-GCM")
  cipher.decrypt
  cipher.key = key.hexbytes
  
  combined = Base64.decode(encoded)
  iv = combined[0, 12]
  tag = combined[12, 16]
  encrypted_data = combined[28..-1]
  
  cipher.iv = iv
  cipher.auth_tag = tag
  
  cipher.update(encrypted_data) + cipher.final
rescue ex
  puts "Decryption failed: #{ex.message}"
  puts "Possible causes: corrupted store or wrong master key"
  return nil
end
