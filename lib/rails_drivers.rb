# frozen_string_literal: true

require 'rails_drivers/version'
require 'rails_drivers/setup'
require 'rails_drivers/railtie'

module RailsDrivers
  class << self
    def loaded
      @loaded ||= []
    end

    def freeze!
      @loaded = @loaded&.freeze
    end
  end
end
