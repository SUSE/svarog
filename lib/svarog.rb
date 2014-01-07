require 'rubygems'
require 'sinatra/base'

class Svarog < Sinatra::Base
  # Sinatra config: http://www.sinatrarb.com/configuration.html
  set :root, File.expand_path('..', File.dirname(__FILE__))
  set :initializers, "config/initializers"
  set :haml, { :format => :html5, :attr_wrapper => '"' }
  set :inline_templates, true
  set :environments, %w{development test production}
  set :environment, ENV['RACK_ENV']
  set :logger_level, :info
  set :logger_log_file, File.join(root, "/log/#{environment}.log")

  # Register Sinatra initializers
  Dir["#{initializers}/**/*.rb"].sort.each do |file_path|
    require File.join(Dir.pwd, file_path)
  end

  puts ">> Svarog server application starting in #{ENV['RACK_ENV']}"

  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      if @auth.provided? && @auth.basic? && @auth.credentials
        @auth.credentials == [CONFIG[:basic_auth][:username], CONFIG[:basic_auth][:password]]
      else
        logger.error "Not authorized request from '#{request.env['REMOTE_ADDR']}'"
        false
      end
    end

    def logger
      @logger ||= begin
        @logger = ::Logger.new(self.class.logger_log_file)
        @logger.level = ::Logger.const_get((self.class.logger_level || :warn).to_s.upcase)
        @logger.datetime_format = "%Y-%m-%d %H:%M:%S"
        @logger
      end
    end
  end

  get '/' do
    haml :index
  end

  post '/enqueue' do
    protected!

    message = Notification::Message.new(params)
    message.save

    if message
      logger.info "*** New notification #{message.sender}: #{message.text}"
      status 200
    else
      status 500
    end
  end
end

__END__
@@ index
!!!
%html
  %head
    %title Svarog server
  %body
    %h1 Svarog - a simple way to send the notification mssages through IRC or Mail
    %p Email contact: #{CONFIG[:contact][:email]}
    %p IRC channel: #{CONFIG[:irc][:channels].join(',')}



