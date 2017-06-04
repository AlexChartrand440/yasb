# The root base include that bootstraps every script in this repo.

require 'active_support'
require 'active_support/core_ext/object'
require 'active_support/core_ext/numeric'
require 'active_support/core_ext/date'
require 'active_support/core_ext/time'
require 'active_support/core_ext/date_time'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/string'
require 'active_support/core_ext/array'
require 'active_support/core_ext/integer'
require 'active_support/core_ext/uri'
require 'active_support/time_with_zone'
require 'socket'
require 'base64'
require 'uri'
require 'openssl'
require 'oj'
require 'mustermann'

def env
  ENV['ENV']
end

def test?
  env == 'test'
end

def development?
  env == 'development'
end

def dev?
  development?
end

def production?
  env == 'production'
end

def prod?
  production?
end

ROOT_PATH = File.dirname(File.realpath("#{__FILE__}/../"))
def root_path
  ROOT_PATH
end

HOSTNAME = Socket.gethostname
def hostname
  HOSTNAME
end

if ENV['SLACK_API_TOKEN'].nil?
  raise 'SLACK_API_TOKEN is a required env.'
end

# Force OJ to serialize as proper json
Oj.default_options = { mode: :compat }

# Force timezone to be UTC time. Use: Time.zone.new instead of Time.new
Time.zone = 'UTC'
START_TIME = Time.zone.now

# default general purpose standard logger
STDOUT.sync = true
STDERR.sync = true
LOGGER = Logger.new(STDOUT)
LOGGER.level = 'info'
LOGGER.progname = 'headroom'

# Initialize custom commands for the bot
require_relative '../libs/slack_bot/base'
Dir["#{ROOT_PATH}/commands/*.rb"].sort.each {|file| require file }

