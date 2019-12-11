# frozen_string_literal: true

module RailsDrivers
  module Setup
    DRIVER_PATHS = %w[
      app
      app/models
      app/views
      app/controllers
      app/mailers
      config/initializers
      db db/migrate
      lib
    ].freeze

    #
    # This allows Rails to find models, views, controllers, etc inside of drivers.
    #
    def setup_paths
      # This ISOLATE_DRIVER constant gets defined by bin/driver
      if defined?(ISOLATE_DRIVER)
        setup_one_driver(ISOLATE_DRIVER)
      else
        setup_every_driver
      end
    end

    private

    def rails_config
      Rails.application.config
    end

    def setup_one_driver(driver_name)
      DRIVER_PATHS.each do |path|
        rails_config.paths[path] = "drivers/#{driver_name}/#{path}"
        rails_config.autoload_paths = ["#{rails_config.root}/drivers/#{driver_name}/lib"]
      end
    end

    def setup_every_driver
      Dir['drivers/*'].each do |driver|
        DRIVER_PATHS.each do |path|
          rails_config.paths[path] << "#{driver}/#{path}"
        end

        # We want to autoload driver/*/lib folders
        rails_config.autoload_paths += ["#{rails_config.root}/#{driver}/lib"]
      end
    end
  end
end
