require "./kit/*"

def run(command_args : Array(String))
  if command_args.empty?
    puts "ERROR: No command specified"
    puts "Usage: anv run -- <command> [args]"
    return
  end

  unless File.exists?(".anv")
    puts "ERROR: No store found. Run `anv init` first."
    return
  end

  master_key = read_master_key
  if master_key.nil?
    puts "ERROR: Master key not found. Run `anv init` first."
    return
  end

  encrypted_blob = File.read(".anv")
  plain = decrypt(encrypted_blob, master_key)
  if plain.nil?
    puts "ERROR: Decryption failed"
    return
  end

  data = JSON.parse(plain).as_h

  env = ENV.to_h
  data.each do |key, value|
    env[key.to_s] = value.to_s
  end
  p 
  Process.exec(command_args[0], command_args[1..-1], env: env)
end

def main
  if ARGV.size < 1
    puts "Usage: anv <command> [arguments]"
    puts ""
    puts "Commands:"
    puts "  init                     Initialize anv in current directory"
    puts "  set KEY=value            Set a secret"
    puts "  get KEY                  Get a secret"
    puts "  run -- <command>         Run command with secrets injected"
    puts "  help                     Show this help message"
    exit 1
  end

  command = ARGV[0]

  case command
  when "init"
    init
  when "set"
    if ARGV.size < 2
      puts "ERROR: Usage: anv set KEY=value"
      exit 1
    end
    set(ARGV[1])
  when "get"
    if ARGV.size < 2
      puts "ERROR: Usage: anv get KEY"
      exit 1
    end
    get(ARGV[1])
  when "run"
    args = ARGV[1..-1] || [] of String
    if args.size > 0 && args[0] == "--"
      args = args[1..-1] || [] of String
    end
    run(args)
  when  "rm", # i added rm to make it feel similar to gnu utils rm 
   if ARGV.size < 1
    puts "error what am i to delete"
    exit 1
   end 
   delete(ARGV[1])
  when "list"
   list_keys
  when "rotate"
  rotate
  when "help"
    puts "Usage: anv <command> [arguments]"
    puts ""
    puts "Commands:"
    puts "  init                     Initialize anv in current directory"
    puts "  set KEY=value            Set a secret"
    puts "  get KEY                  Get a secret"
    puts "  rm KEY / delete KEY      Deletes a secret"
    puts " list                      list all secrets"
    puts " rotate                    rotate keys"
    puts "  run -- <command>         Run command with secrets injected"
    puts "  help                     Show this help message"
  else
    puts "ERROR: Unknown command '#{command}'"
    puts "Run 'anv help' for available commands"
    exit 1
  end
end

main
