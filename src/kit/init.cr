require "./en_de"
require "random/secure"

def init
  puts "...initializing .anv..."
  if File.exists?(".anv")
    puts ".anv file exists use help for help"
  else
    Dir.mkdir_p(".anv")
    template_data = "{}"
    encrypted_store = encrypt(template_data, key)
    if encrypted_store.nil?
      puts "ERROR: Failed to encrypt initial store"
      return
    end
    File.write(".anv/store", encrypted_store)

    puts ".anv initialized successfully"
  end
end
