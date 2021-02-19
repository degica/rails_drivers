# frozen_string_literal: true

require_relative './config'

module RailsDrivers
  module Files
    class Error < StandardError
    end

    module_function

    def isolate(driver)
      raise Error, 'No driver specified' if driver.nil? || driver == ''
      raise Error, "Driver #{driver.inspect} not found" unless File.exist?("#{RailsDrivers.config.drivers_path}/#{driver}")

      FileUtils.mkdir_p 'tmp/drivers'
      Dir["#{RailsDrivers.config.drivers_path}/*"].each do |driver_path|
        next if driver_path.include?("/#{driver}")

        FileUtils.mv driver_path, "tmp/#{driver_path}"
      end
    end

    def clear
      FileUtils.mkdir_p 'tmp/drivers'
      Dir["#{RailsDrivers.config.drivers_path}/*"].each do |driver_path|
        FileUtils.mv driver_path, "tmp/#{driver_path}"
      end
    end

    def restore
      Dir['tmp/drivers/*'].each do |tmp_driver_path|
        driver = tmp_driver_path.split('/').last
        FileUtils.mv tmp_driver_path, "#{RailsDrivers.config.drivers_path}/#{driver}"
      end
    end
  end
end
