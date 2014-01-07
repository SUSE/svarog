puts "*** 00-application_initializer.rb"

# Define global constans
APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../../'))
LIB_ROOT = File.expand_path(File.join(APP_ROOT, 'lib'))

# Establish connection to redis server
REDIS_DATABASES = {:production => 0, :development => 1, :test => 2}
REDIS = Redis.new(:host => "localhost", :port => 6379, :db => REDIS_DATABASES[ENV['RACK_ENV'].to_sym], :thread_safe => true)

# Load libraries
Dir[File.join(LIB_ROOT,"/**/*.rb")].each {|file| require file }

# Only load configurations if there's a config directory in the first place..
CONFIG_DIR = File.join(APP_ROOT, "config") unless defined?(CONFIG_DIR)
CONFIG = YAML.load(File.read(File.join(CONFIG_DIR, "application.yml"))).deep_symbolize_keys! if File.directory?(CONFIG_DIR)
