
require './helpers'

class Downloader
  MAX_BANDWIDTH = 100

  def initialize
    @bandwidth = 0
    @semaphore = Concurrent::Semaphore.new(MAX_BANDWIDTH)
  end

  def take_bandwidth(amount)
    @semaphore.acquire(amount)
    @bandwidth += amount
    raise 'bandwidth overflow!' if @bandwidth > MAX_BANDWIDTH
  end

  def return_bandwidth(amount)
    @semaphore.release(amount)
    @bandwidth -= amount
  end

  def download(task)
    Thread.new do
      log "#{task.name} starting..."
      task.progress = 0

      take_bandwidth(task.bandwidth)
      begin
        while task.progress < task.size
          task.progress += task.bandwidth
          log "#{task.name} - #{task.progress}/#{task.size}"
          sleep 0.1
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

high_sierra    = DownloadTask.new('High Sierra',    60, 400)
the_last_jedi  = DownloadTask.new('The Last Jedi',  80, 700)
brew_update    = DownloadTask.new('brew update',    40, 100)
bundle_install = DownloadTask.new('bundle install', 40, 200)

experiment do
  tasks = [high_sierra, brew_update, the_last_jedi, bundle_install]

  downloader = Downloader.new
  threads = tasks.map do |task|
    downloader.download(task)
  end

  threads.each(&:join)
end
