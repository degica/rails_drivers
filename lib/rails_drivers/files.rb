# frozen_string_literal: true

module RailsDrivers
  module Files
    class Error < StandardError
    end

    module_function

    def isolate(driver)
      raise Error, 'No driver specified' if driver.nil? || driver == ''
      raise Error, "Driver #{driver.inspect} not found" unless File.exist?("drivers/#{driver}")

      FileUtils.mkdir_p 'tmp/drivers'
      Dir['drivers/*'].each do |driver_path|
        next if driver_path.include?("/#{driver}")

        FileUtils.mv driver_path, "tmp/#{driver_path}"
      end
    end

    def clear
      FileUtils.mkdir_p 'tmp/drivers'
      Dir['drivers/*'].each do |driver_path|
        FileUtils.mv driver_path, "tmp/#{driver_path}"
      end
    end

    def restore
      Dir['tmp/drivers/*'].each do |tmp_driver_path|
        driver = tmp_driver_path.split('/').last
        FileUtils.mv tmp_driver_path, "drivers/#{driver}"
      end
    end
  end
end
