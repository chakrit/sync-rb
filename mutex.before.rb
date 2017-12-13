
require './helpers'

class Downloader
  attr_reader :bandwidth

  def initialize
    @bandwidth = 0
  end

  def take_bandwidth(amount)
    @bandwidth += amount
  end

  def return_bandwidth(amount)
    @bandwidth -= amount
  end

  def download(task)
    task.progress = 0

    Thread.new do
      take_bandwidth(task.bandwidth)
      begin
        while task.progress < task.size
          task.progress += task.bandwidth
          log "#{task.name} - #{task.progress}/#{task.size}"
        end
      ensure
        return_bandwidth(task.bandwidth)
      end

      log "#{task.name} finished."
      log "------------ current bandwidth: #{@bandwidth}"
    end
  end
end

class DownloadTask
  attr_accessor :name, :bandwidth, :size, :progress

  def initialize(name, bandwidth, size)
    @name = name
    @bandwidth = bandwidth
    @size = size
    @progress = 0
  end
end

tasks = (1..10).map do |n|
  bandwidth = 10  + (rand * 100)
  size      = 100 + (rand * 100)

  DownloadTask.new(n.to_s, bandwidth.to_i, size.to_i)
end

experiment do
  downloader = Downloader.new
  threads    = tasks.map do |task|
    downloader.download(task)
  end

  threads.each(&:join)
  raise 'race condition!' if downloader.bandwidth != 0
end
