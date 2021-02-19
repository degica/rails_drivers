# frozen_string_literal: true

module DriversPathHelpers
  def self.included(klass)
    klass.send(:extend, DriversPathHelpers)

    RSpec::Matchers.define :have_driver_file do |file_path|
      match do |dummy_app_path|
        File.exist? File.expand_path(File.join(dummy_app_path, drivers_path, file_path))
      end
    end
  end

  def drivers_path
    ENV['DRIVERS_PATH'] || 'drivers'
  end
end
