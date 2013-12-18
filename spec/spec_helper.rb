ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'minitest/autorun'
require 'rack/test'
require 'debugger'
require 'svarog'

class MiniTest::Spec
  include Rack::Test::Methods
  def app
    Rack::Builder.parse_file(File.join(APP_ROOT, 'config.ru')).first
  end
end

