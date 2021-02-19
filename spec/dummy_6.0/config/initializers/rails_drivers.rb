# frozen_string_literal: true

require 'rails_drivers'

RailsDrivers.configure do |config|
  config.drivers_path = ENV['DRIVERS_PATH']
end
