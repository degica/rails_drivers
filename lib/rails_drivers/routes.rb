# frozen_string_literal: true

module RailsDrivers
  class Routes
    def self.load_driver_routes
      return if defined?(REPLACE_DEFAULT_PATH_WITH_DRIVER)

      Dir[Rails.root.join("#{RailsDrivers.config.drivers_path}/*")].each do |path|
        load "#{path}/config/routes.rb" if File.exist?("#{path}/config/routes.rb")
      end
    end
  end
end
