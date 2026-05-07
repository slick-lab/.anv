def set(key_value : String) : String?
  key, value = key_value.split("=", 2)
  
  unless File.exist?(".anv/store")
    return "no store to set pls run init or -h"
  end
  
  encrypted = File.read(".anv/store")
  plain = decrypt(encrypted)
  data = JSON.parse(plain)
  
  data[key] = value
  new_plain = data.to_json
  new_encrypt = encrypt(new_plain, read_master_key)
  File.write(".anv/store", new_encrypt)
  
  return "successfully set #{key}"
end 

def get(key : String) : String?
  unless File.exist?(".anv/store")
    return ".anv/store does not exist pls run init or -h"
  end
  
  encrypted = File.read(".anv/store")
  plain = decrypt(encrypted)
  data = JSON.parse(plain)
  
  if value = data[key]?
    return value.as_s
  else
    return "key not found for #{key}"
  end
end
