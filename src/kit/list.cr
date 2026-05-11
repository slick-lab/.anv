def list_keys
  unless File.exist?(".anv/store")
    puts "ERROR: No store found. Run `anv init` first."
    return
  end
  
  master_key = read_master_key
  if master_key.nil?
    puts "ERROR: Master key not found."
    return
  end
  
  encrypted_blob = File.read(".anv/store")
  plain = decrypt_hmac(encrypted_blob, master_key)
  if plain.nil?
    puts "ERROR: Decryption failed"
    return
  end
  
  data = Hash(String, String).from_json(plain)
  
  if data.empty?
    puts "No secrets stored. Run `anv set KEY=value` to add one."
    return
  end
  
  puts "Stored secrets:"
  data.each_key do |key|
    puts "  - #{key}"
  end
end
