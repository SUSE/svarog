ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'minitest/autorun'
require 'rack/test'

OUTER_APP = Rack::Builder.parse_file('config.ru').first

class MiniTest::Spec
  include Rack::Test::Methods
  def app
    OUTER_APP
  end
end


