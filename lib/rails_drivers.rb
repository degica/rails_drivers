# frozen_string_literal: true

require 'rails_drivers/version'
require 'rails_drivers/config'
require 'rails_drivers/setup'
require 'rails_drivers/railtie' if defined?(Rails)
require 'rails_drivers/extensions'

module RailsDrivers
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config if block_given?
    end

    def loaded
      @loaded ||= []
    end

    def freeze!
      @loaded = @loaded&.freeze
    end
  end
end
