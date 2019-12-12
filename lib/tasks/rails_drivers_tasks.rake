# frozen_string_literal: true

namespace :driver do
  DriverError = Class.new(StandardError)

  desc 'Removes every driver but the one specified. Can be undone with driver:restore.'
  task :isolate, [:driver] do |_t, args|
    include FileUtils

    raise DriverError, 'No driver specified' if args.driver.blank?
    raise DriverError, 'Driver not found' unless File.exist?("drivers/#{args.driver}")

    mkdir_p 'tmp/drivers'
    Dir['drivers/*'].each do |driver_path|
      next if driver_path.include?("/#{args.driver}")

      mv driver_path, "tmp/#{driver_path}"
      puts "Moved #{driver_path} to tmp/drivers/"
    end

  rescue DriverError => e
    puts e.message
  end

  desc 'Removes all drivers. Can be undone with driver:restore.'
  task :clear do
    include FileUtils

    mkdir_p 'tmp/drivers'
    Dir['drivers/*'].each do |driver_path|
      mv driver_path, "tmp/#{driver_path}"
      puts "Moved #{driver_path} to tmp/drivers/"
    end
  end

  desc 'Undoes the effects of driver:isolate and driver:clear.'
  task :restore do
    include FileUtils

    Dir['tmp/drivers/*'].each do |tmp_driver_path|
      driver = tmp_driver_path.split('/').last
      mv tmp_driver_path, "drivers/#{driver}"
      puts "Moved #{tmp_driver_path} to drivers/"
    end
  end
end
