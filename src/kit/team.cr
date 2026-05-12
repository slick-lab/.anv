require "http/client"

def team_add(github_username : String)
  response = HTTP::Client.get("https://github.com/#{github_username}.keys")
  public_key = response.body.lines.first
  m_key = read_master_key
  age_encrypt(public_key, m_key, ".anv/keys/#{github_username}.age")
end 

def age_encrypt(public_key : String, m_key : String, path : String) : Bool
  command = "age -r \"#{public_key}\ -o #{path} #{m_key}"
  system(command)
end 

def age_decrypt(private_key_file : String, m_key : String, file : String) : Bool
  command = "age -d -i #{private_key_file} -0 
  
  
