module SlackBot
  module Commands
    # @abstract
    class Base

      # Set the pattern that this command responds to
      # @param [String,Regexp,nil] pattern  Set the pattern that a message might match. If nil, will return currently set pattern.
      # @return [Mustermann]
      def self.pattern(pattern = nil)
        if pattern.is_a?(String)
          @pattern = ::Mustermann.new(pattern, type: :sinatra, space_matches_plus: false, uri_decode: false)
        elsif pattern.is_a?(Regexp)
          @pattern = ::Mustermann.new(pattern, type: :regexp, check_anchors: false, uri_decode: false)
        elsif pattern.nil?
          @pattern
        else
          raise ArgumentError.new "Expected either String pattern or Regexp: #{pattern.inspect}"
        end
      end

      # Set or get a description for the command
      def self.description(text = nil)
        if text.is_a?(String)
          @description = text
        elsif text.nil?
          @description
        else
          raise ArgumentError.new "Expected a String: #{text.inspect}"
        end
      end

      # Does this Command match the text string?
      # @param [String] text
      # @return [MatchData]
      def self.match(text)
        @pattern.match(text)
      end

      # The params extracted from the text
      # @param [String] text
      # @return [Hash]
      def self.params(text)
        @pattern.params(text)
      end

      # Get all commands with a class.name that match a Regexp
      # @return [Array<SlackBot::Command>]
      def self.commands
        ObjectSpace.each_object(singleton_class).select { |klass| klass < self }
      end

      # If the command pattern matches, a Command instance will be constructed and called.
      def initialize(bot, data, params)
        @bot = bot
        @data = data
        @params = params
      end

      # Call this command
      def call
        # Overload this function
      end

      # @return [SlackBot::Base]
      def bot
        @bot
      end

      # @return [Slack::Web::Client]
      def web_client
        bot.web_client
      end

      # @return [Slack::RealTime::Client]
      def rt_client
        bot.rt_client
      end

      # @return [Hash]
      def params
        @params ||= {}
      end

      # @return [String]
      def text
        @data[:team]
      end

      # @return [String]
      def user_id
        @data[:user]
      end

      # @return [String]
      def team_id
        @data[:team]
      end

      # @return [String]
      def channel_id
        @data[:channel]
      end

      # @return [Slack::RealTime::Models::User]
      def user
        rt_client.store.users[user_id]
      end

      # @return [Slack::RealTime::Models::Team]
      def team
        rt_client.store.teams[team_id]
      end

      # @return [Slack::RealTime::Models::Channel]
      def channel
        rt_client.store.teams[channel_id]
      end

      # @return [Slack::RealTime::Models::Im]
      def im
        rt_client.store.ims[channel_id]
      end
      alias_method :im_channel, :im

      # @return [Slack::RealTime::Models::Group]
      def group
        rt_client.store.groups[channel_id]
      end
      alias_method :group_channel, :group

      # Send a message
      # @see https://api.slack.com/methods/chat.postMessage#formatting
      # @param [Hash] opts  The options to create a message with.
      # @option opts [String] :text       Required. Text of the message to send. See below for an explanation of formatting. This field is usually required, unless you're providing only :attachments instead.
      # @option opts [String] :channel    Optional. Channel, private group, or IM channel to send message to. Can be an encoded ID, or a name. See below for more details.
      # @param opts [String] :parse       Optional. Change how messages are treated. Defaults to none. See below.
      # @param opts [boolean] :link_names Optional. Find and link channel names and usernames.
      # @param opts [String] :attachments Optional. Structured message attachments.
      # @param opts [boolean] :unfurl_links Optional. Pass true to enable unfurling of primarily text-based content.
      # @param opts [boolean] :unfurl_media Optional. Pass false to disable unfurling of media content.
      # @param opts [String] :username    Optional. Set your bot's user name. Must be used in conjunction with as_user set to false, otherwise ignored. See authorship below.
      # @param opts [boolean] :as_user    Optional. Pass true to post the message as the authed user, instead of as a bot. Defaults to false. See authorship below.
      # @param opts [String] :icon_url    Optional. URL to an image to use as the icon for this message. Must be used in conjunction with as_user set to false, otherwise ignored. See authorship below.
      # @param opts [String] :thread_ts   Optional. (e.g. "1234567890.123456") Provide another message's ts value to make this message a reply. Avoid using a reply's ts value; use its parent instead.
      # @param opts [boolean] :reply_broadcast Optional. Used in conjunction with thread_ts and indicates whether reply should be made visible to everyone in the channel or conversation. Defaults to false.
      def say!(opts)
        opts[:channel] ||= channel_id
        rt_client.message(opts)
      end

    end
  end
end

module SlackBot
  module Commands

    class Help < Base
      pattern 'help'
      description 'Returns instructions about what commands are available.'

      def call
        commands = bot.commands.map { |cmd| "`#{cmd.pattern.to_s}`: #{cmd.description}" }
        say!(text: <<-TEXT)
Here's a list of available commands:
  
#{commands.join("\n")}
        TEXT
      end

    end
  end
end