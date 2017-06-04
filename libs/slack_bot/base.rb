require 'slack-ruby-client'
require_relative './command'

module SlackBot
  # A single bot instance.
  class Base

    attr_accessor :web_client
    attr_accessor :rt_client

    # @param [String] name            The name of the bot.
    # @param [Module] command_module  The class of commands to load
    def initialize(name, command_module:, token: nil, web_client: nil, rt_client: nil)
      @name = name
      @token = token || ENV['SLACK_API_TOKEN']

      @commands = command_module.constants.map { |c| command_module.const_get(c) }.select { |c| c < SlackBot::Commands::Base }
      @commands.unshift(SlackBot::Commands::Help)

      @web_client ||= web_client || ::Slack::Web::Client.new({
        token: @token,
        logger: logger
      })

      @rt_client ||= rt_client || ::Slack::RealTime::Client.new({
        token: @token,
        logger: logger
      })

      @rt_client.on :hello do
        logger.info "#{name} has successfully connected to Slack."
      end

      @rt_client.on :message do |data|
        Time.zone = 'UTC'
        @commands.find do |command|
          match = command.match(data.text)
          if match
            inst = command.new(self, data, command.params(data.text))
            inst.call
          end
          match
        end
      end

    end

    # Name of this bot
    def name
      @name
    end

    def logger
      return @logger if @logger
      @logger = ::Logger.new(STDOUT)
      @logger.progname = name
      @logger.level = Logger::INFO
      @logger
    end

    # The array of all registered commands
    # @return [Array<SlackBot::Commands::Base>]
    def commands
      @commands
    end

    # @return [Slack::Web::Client]
    def web_client
      @web_client
    end

    # @return [Slack::RealTime::Client]
    def rt_client
      @rt_client
    end

    # Is the server gracefully shutting down?
    def shutdown?
      @shutdown ||= false
    end

    # Start the realtime connection to Slack
    def start!
      logger.info "Starting #{name} ..."
      @rt_client.start!
    end

    # Stop the realtime connection to slack
    def stop!
      logger.info "Shutting down #{name} ..."
      @shutdown = true
      @rt_client.stop!
    end

    # All the registered commands
    def commands
      @commands ||= []
    end

  end
end
