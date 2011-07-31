require 'rubygems'
require 'bundler'
require 'resque/server'

Bundler.setup

require File.join(File.dirname(__FILE__), 'application')

set :run, false
set :environment, :production

begin
  
  log = File.new("log/sinatra.log", "a+")
  $stdout.reopen(log)
  $stderr.reopen(log)
  
rescue => e
  $stdout.puts e
ensure
  run Rack::URLMap.new \
    "/"       => Sinatra::Application,
    "/resque" => Resque::Server.new
end