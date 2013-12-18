puts "*** 00-application_initializer.rb"

require 'redis'
require 'redis-namespace'

require 'yaml'
require 'haml'
require 'json'

# Define global constans
APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../../'))
LIB_ROOT = File.expand_path(File.join(APP_ROOT, 'lib'))

# Establish connection to redis server
REDIS_DATABASES = {:production => 0, :development => 1, :test => 2}
REDIS = Redis.new(:host => "localhost", :port => 6379, :db => REDIS_DATABASES[ENV['RACK_ENV'].to_sym], :thread_safe => true)

# Load libraries
Dir[File.join(LIB_ROOT,"/**/*.rb")].each {|file| require file }

# Read options from yml file(s)
if ENV['RACK_ENV'] == 'test'
	CONFIG_FILE = File.expand_path('config/example-config.yml')
else
	CONFIG_FILE = File.expand_path('config/application.yml')
end

CONFIG = YAML.load_file(File.expand_path(CONFIG_FILE))


