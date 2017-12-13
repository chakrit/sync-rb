require './helpers'

class Car
  def initialize(name)
    @name = "#{self.class.name}-#{name}"
    @speed = 0
  end

  def ignite
    log "igniting #{@name}..."
    sleep delays(:ignition)
    log "#{@name} engine started!"
  end

  def accelerate
    sleep delays(:acceleration)
    @speed += 0.1
    log "#{@name} is at #{format('%.2f', @speed)} kph..."
  end
end

class Toyota < Car
  def delays(item)
    case item
    when :ignition then 1.01
    when :acceleration then 0.11
    end
  end
end

class Honda < Car
  def delays(item)
    case item
    when :ignition then 2.0
    when :acceleration then 0.09
    end
  end
end

experiment do
  cars = (1..3).flat_map do |n|
    [
      Honda.new(n.to_s),
      Toyota.new(n.to_s)
    ]
  end

  monitor = Monitor.new
  lights  = monitor.new_cond

  threads = cars.shuffle.map do |car|
    Thread.new do
      monitor.synchronize { lights.wait }
      car.ignite

      monitor.synchronize { lights.wait }
      car.accelerate
      car.accelerate
      car.accelerate
    end
  end

  log '#=#=#=#=#= READY =#=#=#=#=#'
  monitor.synchronize { lights.broadcast }
  sleep 5

  log '#=#=#=#=#=  GO!  =#=#=#=#=#'
  monitor.synchronize { lights.broadcast }

  threads.each(&:join)
end
