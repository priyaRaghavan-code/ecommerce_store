class RedisClient
  def self.connection
    @connection ||= Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
  end
end
