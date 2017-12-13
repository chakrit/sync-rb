require 'bundler/setup'
require 'scanf'
require 'monitor'
require 'thread'
require 'concurrent'
require 'pry'

$monitor = Monitor.new # rubocop:disable Style/GlobalVars

def log(message)
  $monitor.synchronize do # rubocop:disable Style/GlobalVars
    puts message
  end
end

def experiment
  iteration = 0

  loop do
    iteration += 1
    log "\e[H\e[2J\niteration: #{iteration}"
    yield

    # wait to see result and also allows SIGINT to come through
    scanf('%c')
  end
end
