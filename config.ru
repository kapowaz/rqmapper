require 'rubygems'
require 'bundler'

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
  run Sinatra::Application
end