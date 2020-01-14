# frozen_string_literal: true

module RailsDrivers
  class Railtie < ::Rails::Railtie
    include ::RailsDrivers::Setup

    rake_tasks do
      load File.expand_path("#{__dir__}/../tasks/rails_drivers_tasks.rake")

      # load drivers rake tasks
      Dir['drivers/*/lib/tasks/**/*.rake'].each do |driver_rake_file|
        load driver_rake_file
      end
    end

    config.before_configuration { setup_paths }
    config.after_initialize { RailsDrivers.freeze! }
  end
end
