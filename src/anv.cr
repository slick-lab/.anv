require "./kit/init"
require "./kit/set_get"
require "./kit/en_de"

def main
  if ARGV.size < 1
    puts "Usage: anv <command> [arguments]"
    puts ""
    puts "Commands:"
    puts "  init                     Initialize anv in current directory"
    puts "  set KEY=value            Set a secret"
    puts "  get KEY                  Get a secret"
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
  when "help"
    puts "Usage: anv <command> [arguments]"
    puts ""
    puts "Commands:"
    puts "  init                     Initialize anv in current directory"
    puts "  set KEY=value            Set a secret"
    puts "  get KEY                  Get a secret"
    puts "  help                     Show this help message"
  else
    puts "ERROR: Unknown command '#{command}'"
    puts "Run 'anv help' for available commands"
    exit 1
  end
end

main
