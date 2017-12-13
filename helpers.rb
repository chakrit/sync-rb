require 'bundler/setup'
require 'concurrent'

def experiment
  loop do
    yield
    sleep 0.1 # allow SIGINT to come through
  end
rescue => e # rubocop:disable Lint/RescueWithoutErrorClass
  puts "error: #{e.message}"
  binding.pry # rubocop:disable Lint/Debugger
end
