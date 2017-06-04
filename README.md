# YASB - Yet Another Slack Bot

YASB ("yaz-bee") is focused on simplicity for rapid development.

## Quick Start

Put your first custom command into to the `./commands` folder.  Here's an example:
```ruby
# Change this module name to your own module name
module MyAwesomeBot
  module Commands
    # Change the command name to be descriptive
    class SayWhat < SlackBot::Commands::Base

      # Messages that match the pattern will execute the command
      pattern 'say :word'
      # Provide helpful text to the `help` command
      description 'Have the bot say any word you want.'

      # Overload the `call` method
      def call
        # Here you have access to `params` from the command, `user`, `team`, `channel`, etc.
        say!(text: "Oh hi, #{user[:name]}! You wanted me to say: #{params[:word]}")
      end

    end
  end
end
```

Create a simple executable Ruby file:
```ruby
# main.rb
require_relative './init/base'
bot = SlackBot::Base.new('AwesomeBot', command_module: MyAwesomeBot::Commands)
bot.start!
```

Start your bot!
```bash
SLACK_API_TOKEN=XXXX ruby main.rb
```

# Slack Bot, gooooooooooo!

![Image of Max Headroom](https://www.dropbox.com/s/grxebrekgoc2hj5/max-headroom.gif?dl=1)
