
require './helpers'

class Downloader
  def initialize
    @bandwidth = 0
    @mutex = Mutex.new
  end

  def take_bandwidth(amount)
    synchronize do
      @bandwidth += amount
    end
  end

  def return_bandwidth(amount)
    synchronize do
      @bandwidth -= amount
    end
  end

  def download(task)
    task.progress = 0

    Thread.new do
      take_bandwidth(task.bandwidth)
      begin
        while task.progress < task.size
          task.progress += task.bandwidth
          log "#{task.name} - #{task.progress}/#{task.size}"
          sleep 0.1
        end

        log "#{task.name} finished."

      ensure
        return_bandwidth(task.bandwidth)
        log "------------ current bandwidth: #{@bandwidth}"
      end
    end
  end

  private

  def synchronize
    @mutex.synchronize do
      yield
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
  threads = tasks.map do |task|
    downloader.download(task)
  end

  threads.each(&:join)
  raise 'race condition!' if downloader.bandwidth != 0
end
