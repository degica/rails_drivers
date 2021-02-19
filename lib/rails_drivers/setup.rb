# frozen_string_literal: true

module RailsDrivers
  module Setup
    DRIVER_PATHS = %w[
      app
      app/assets
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
      # This REPLACE_DEFAULT_PATH_WITH_DRIVER constant gets defined by bin/driver when we want
      # to run a command in the context of a driver instead of the main rails app.
      if defined?(REPLACE_DEFAULT_PATH_WITH_DRIVER)
        replace_rails_paths_with_driver(REPLACE_DEFAULT_PATH_WITH_DRIVER)
      else
        add_every_driver_to_rails_paths
      end
    end

    private

    def rails_config
      Rails.application.config
    end

    def drivers_path
      RailsDrivers.config.drivers_path
    end

    def add_rails_autoload_path(path)
      rails_config.autoload_paths << path
    end

    def replace_rails_paths_with_driver(driver_name)
      add_rails_autoload_path "#{rails_config.root}/#{drivers_path}"

      DRIVER_PATHS.each do |path|
        rails_config.paths[path] = "#{drivers_path}/#{driver_name}/#{path}"
        rails_config.autoload_paths += [
          "#{rails_config.root}/#{drivers_path}/#{driver_name}/lib"
        ]
      end
    end

    def add_every_driver_to_rails_paths
      add_rails_autoload_path "#{rails_config.root}/#{drivers_path}"

      Dir["#{drivers_path}/*"].each do |driver|
        DRIVER_PATHS.each do |path|
          rails_config.paths[path] << "#{driver}/#{path}"
        end

        # We want to autoload driver/*/lib folders
        rails_config.autoload_paths += [
          "#{rails_config.root}/#{driver}/lib"
        ]
      end
    end
  end
end
