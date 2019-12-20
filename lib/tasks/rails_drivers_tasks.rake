# frozen_string_literal: true

namespace :driver do
  desc 'Removes every driver but the one specified. Can be undone with driver:restore.'
  task :isolate, [:driver] do |_t, args|
    require 'rails_drivers/files'
    RailsDrivers::Files.isolate(args.driver)
  rescue RailsDrivers::Files::Error => e
    puts e.message
  end

  desc 'Removes all drivers. Can be undone with driver:restore.'
  task :clear do
    require 'rails_drivers/files'
    RailsDrivers::Files.clear
  end

  desc 'Undoes the effects of driver:isolate and driver:clear.'
  task :restore do
    require 'rails_drivers/files'
    RailsDrivers::Files.restore
  end
end
