require "./en_de"

def set(key_value : String) : String?
  key, value = key_value.split("=", 2)
  
  unless File.exist?(".anv/store")
    return "no store to set pls run init or -h"
  end
  
  master_key = read_master_key
  return "master key not found" unless master_key
  
  plain = decrypt(master_key)
  return "decryption failed" unless plain
  
  data = JSON.parse(plain)
  data[key] = value
  new_plain = data.to_json
  
  encrypt(new_plain, master_key)
  return "successfully set #{key}"
end 

def get(key : String) : String?
  unless File.exist?(".anv/store")
    return ".anv/store does not exist pls run init or -h"
  end
  
  master_key = read_master_key
  return "master key not found" unless master_key
  
  plain = decrypt(master_key)
  return "decryption failed" unless plain
  
  data = JSON.parse(plain)
  
  if value = data[key]?
    return value.as_s
  else
    return "key not found for #{key}"
  end
end
