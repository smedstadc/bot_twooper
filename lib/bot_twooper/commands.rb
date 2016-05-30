module BotTwooper
  module Commands
    @commands = {}

    def self.register(trigger, command)
      raise "command must respond to :call" unless command.respond_to? :call
      trigger.strip!
      warn "    Warning #{trigger} will override a trigger in use" unless @commands[trigger].nil?
      puts "    Mapping #{trigger} to #{command}"
      @commands[trigger] = command
    end

    def self.for(message)
      if message.body =~ /(\A.\w+)/
        @commands[$1]
      end
    end

    def self.available
      @commands.keys
    end
  end
end