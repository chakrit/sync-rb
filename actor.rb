require './helpers'

class Downloader
  def initialize(queue)
    @queue = queue
  end

  def start
    Thread.new do
      true while download_one
    end
  end

  def download_one
    item = @queue.shift
    return nil if item.nil?

    item.progress = 0
    while item.progress < item.size
      item.progress += item.bandwidth
      log "downloading #{item.name} (#{item.progress}/#{item.size})..."
    end

    log "#{item.name} finished."
    item
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
  queue = Concurrent::Array.new
  queue.push(high_sierra, brew_update, the_last_jedi, bundle_install)

  downloaders = [
    Downloader.new(queue),
    Downloader.new(queue)
  ]

  downloaders.each(&:start)

  loop do
    exit(0) if queue.empty?
    sleep 1
  end
end
