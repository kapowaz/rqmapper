require './application.rb'
require 'resque/tasks'

task "resque:setup" do
  ENV['QUEUE'] = '*'
end

desc "Alias for resque:work (for Heroku)"
task "jobs:work" => "resque:work"