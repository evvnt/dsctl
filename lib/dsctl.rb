require 'dotenv/load'
require 'pry' if ENV['RACK_ENV'] == 'development'

require_relative 'dsctl/helpers/logger'
require_relative 'dsctl/client'
require_relative 'dsctl/deploy'
require_relative 'dsctl/schema'
require_relative 'dsctl/schema_finder'
require_relative 'dsctl/validate'
require_relative 'dsctl/version'

raise 'ORGANIZATION_ID is not set' unless ENV['ORGANIZATION_ID']
raise 'API_KEY is not set' unless ENV['API_KEY']
raise 'Target environment is not set' unless ENV['TARGET_ENV']

module Dsctl
end
