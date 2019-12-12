# frozen_string_literal: true

require 'rails_drivers/version'
require 'rails_drivers/setup'
require 'rails_drivers/railtie'

module RailsDrivers
  def self.loaded
    @loaded ||= []
  end

  def self.freeze!
    @loaded = @loaded&.freeze
  end
end
