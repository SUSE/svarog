ENV['RACK_ENV'] = ENV['RACK_ENV'] || 'development'

require 'rubygems'
require 'bundler'

Bundler.require(:default, ENV['RACK_ENV'].to_sym) if defined?(Bundler)

$: << File.join(File.expand_path(File.dirname(__FILE__)), 'lib')
require 'svarog'
run Svarog


