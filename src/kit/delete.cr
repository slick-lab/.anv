# I total forgot about deleting keys crazy
require "./set_get"

def delete(key : String)
  lock = acquire_lock
  begin
   m_key = read_master_key
   return nil unless m_key
   unless File.exists?(".anv/store")
    puts "error cannot find the store pls run init first"
    return
   end 
   en_blob = File.read(".anv/store") 
   plain_blob = decrypt(en_blob, m_key)
   if plain_blob.nil?
    puts "ERROR: decryption failed"
    return 
   end 
   data = Hash(String, String).from_json(plain_blob)
   unless data.has_key?(key)
   puts "error key #{key} not found"
   return
  end 
  data.delete(key)
 # the indentation for this code is a mess damn 
  new_plain = data.to_json
  new_encrypted = encrypt(new_plain, m_key)
  if new_encrypted.nil?
   puts "encryption failed"
   return 
 end 
 File.write(".anv/store", new_encrypted)
 puts "key deleted successfully"
ensure 
 release_lock(lock)
 end 
end 
