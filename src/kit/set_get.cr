

def set(key_value : String)
  key, value = key_value.split("=", 2)
  if File.exist?(".anv/store")
   encrypted = File.read(".anv/store")
   plain = decrypt(encrypted, read_master_key)
   data = JSON.parse(plain)
 else 
  puts "no store to set pls run init or -h"
 end
 data[key] = value
 new_plain = data.to_json
 new_encrypt = encrypt(new_plain, read_master_key)
 File.write(".anv/store", new_encrypt)
 puts " successfully set #{key}"
end 

def get(key : String)
if File.exist?(".anv/store")
 encrypted = File.read(".anv/store")
 plain = decrypt(encrypted, read_master_key)
 data = JSON.parse(plain)
else 
 puts ".anv/store does not exist pls run init or -h"
end 
 if value = data[key]?
  p value.as_s
 else
  puts "key not found for #{key}"
end 
end 

  
