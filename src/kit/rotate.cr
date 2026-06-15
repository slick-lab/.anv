require "./en_de"
require "system"
def rotate
  key = read_master_key
  if key.nil?
   puts "couldn't read keys"
   return
 end
  store = File.read(".anv")
  plain = decrypt(store, key)
  if plain.nil?
   puts "decryption failed"
   return
  end 
  puts "starting rotation of keys"
  if system("which secret-tool > /dev/null 2>&1")
   system("secret-tool clear anv-key master")
   puts "removed key"
  elsif system("which security > /dev/null 2>&1")
    system("security delete-generic-password -a #{ENV["USER"]} -s anv-master-key 2>/dev/null")
    puts "removed key"
  else
   puts "no supported keyring found"
  end
  new_key = set_master_key
  encrypted = encrypt(plain, new_key)
  if encrypted.nil?
   puts "encryption failed.."
 else
  File.write(".anv", encrypted)
  puts "encryption was successfull"
 end
end
