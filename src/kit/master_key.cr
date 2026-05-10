require "random/secure"


def set_master_key : Bool
 key = Random::Secure.hex(64)
  if system("which secret-tool > /dev/null 2>&1")
   system("echo '#{key}' | secret-tool store --label='anv master key' anv-key master")
   return true
 elsif system("which security > /dev/null 2>&1")
  system("security add-generic-password -a #{ENV["USER"]} -s anv-master-key -w '#{key}'")
  return true
end 
false 
end 

def get_master_key : String?
 if system("which secret-tool > /dev/null 2>&1")
   key = `secret-tool lookup anv-key master`.strip
   return key unless key.empty 
end 
 if system("which security > /dev/null 2>&1")
  key = `security find-generic-password -a #{ENV["USER"]} -s anv-master-key -w 2/dev/null`.strip
   return key unless key.empty
 end 
nil
end 
