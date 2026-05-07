require "json"
require "file_utils"
require "./en_de"

LOCK_FILE = ".anv/store.lock"
MAX_RETRIES = 50
RETRY_DELAY = 0.05

def acquire_lock
  retries = 0
  
  while retries < MAX_RETRIES
    begin
      lock_file = File.open(LOCK_FILE, "w")
      lock_file.flock(File::Lock::Exclusive)
      return lock_file
    rescue
      retries += 1
      sleep RETRY_DELAY
    end
  end
  
  puts "ERROR: Could not acquire lock after #{MAX_RETRIES * RETRY_DELAY} seconds"
  puts "Another anv process is running. Please wait and try again."
  exit 1
end

def release_lock(lock_file)
  lock_file.flock(File::Lock::Unlock)
  lock_file.close
  File.delete(LOCK_FILE) if File.exists?(LOCK_FILE)
end

def set(key_value : String)
  lock = acquire_lock
  
  begin
    key, value = key_value.split("=", 2)
    
    unless File.exists?(".anv/store")
      puts "ERROR: No store found. Run `anv init` first."
      return
    end
    
    master_key = read_master_key
    if master_key.nil?
      puts "ERROR: Master key not found. Run `anv init` first."
      return
    end
    
    encrypted_blob = File.read(".anv/store")
    plain = decrypt(encrypted_blob, master_key)
    if plain.nil?
      puts "ERROR: Decryption failed. Corrupted store or wrong key."
      return
    end
    
    data = JSON.parse(plain).as_h
    data[key] = value
    
    new_plain = data.to_json
    new_encrypted = encrypt(new_plain, master_key)
    if new_encrypted.nil?
      puts "ERROR: Encryption failed"
      return
    end
    
    File.write(".anv/store", new_encrypted)
    puts "✓ #{key} set successfully"
  ensure
    release_lock(lock)
  end
end

def get(key : String)
  lock = acquire_lock
  
  begin
    unless File.exist?(".anv/store")
      puts "ERROR: No store found. Run `anv init` first."
      return
    end
    
    master_key = read_master_key
    if master_key.nil?
      puts "ERROR: Master key not found. Run `anv init` first."
      return
    end
    
    encrypted_blob = File.read(".anv/store")
    plain = decrypt(encrypted_blob, master_key)
    if plain.nil?
      puts "ERROR: Decryption failed. Corrupted store or wrong key."
      return
    end
    
    data = JSON.parse(plain).as_h
    
    if data.has_key?(key)
      puts data[key]
    else
      puts "ERROR: Key '#{key}' not found"
    end
  ensure
    release_lock(lock)
  end
end
