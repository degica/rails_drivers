# frozen_string_literal: true

module RailsDrivers
  class Config
    DEFAULT_DRIVERS_PATH = 'drivers'

    attr_accessor :drivers_path

    def initialize(options = {})
      @drivers_path = options[:drivers_path] || DEFAULT_DRIVERS_PATH
    end
  end

  def self.config
    @config ||= Config.new
  end

  def self.configure
    yield config if block_given?
  end
end
