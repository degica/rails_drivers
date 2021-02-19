# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'rails g driver' do
  before :each do
    run_command 'rails g driver driver_name'
  end

  context 'creating files' do
    it 'creates the app directory' do
      expect(dummy_app).to have_driver_file 'driver_name/app/'
    end

    it 'creates the models directory' do
      expect(dummy_app).to have_driver_file 'driver_name/app/models/driver_name/'
      expect(dummy_app).to have_driver_file 'driver_name/app/models/driver_name.rb'
    end

    it 'creates the controllers directory' do
      expect(dummy_app).to have_driver_file 'driver_name/app/controllers/'
      expect(dummy_app).to have_driver_file 'driver_name/app/controllers/driver_name/'
    end

    it 'creates the views directory' do
      expect(dummy_app).to have_driver_file 'driver_name/app/views/'
      expect(dummy_app).to have_driver_file 'driver_name/app/views/driver_name/'
    end

    it 'creates the routes' do
      expect(dummy_app).to have_driver_file 'driver_name/config/routes.rb'
    end

    it 'creates the driver initializer' do
      expect(dummy_app).to have_driver_file 'driver_name/config/initializers/driver_name_feature.rb'
    end

    it 'creates the tasks directory' do
      expect(dummy_app).to have_driver_file 'driver_name/lib/tasks/.keep'
    end

    it 'creates the readme' do
      expect(dummy_app).to have_driver_file 'driver_name/README.md'
    end
  end

  context 'the namespace' do
    it 'has the right table_name_prefix' do
      expect(run_ruby %(puts DriverName.table_name_prefix)).to eq "driver_name_\n"
    end
  end

  context 'the initializer' do
    it 'populates RailsDrivers.loaded' do
      expect(run_ruby %(puts RailsDrivers.loaded.inspect)).to eq "[:driver_name]\n"
    end
  end

  context 'the routes.rb' do
    it 'draws from the Rails application' do
      expect(read_file("#{drivers_path}/driver_name/config/routes.rb")).to include "Dummy::Application.routes.draw do\n"
    end
  end

  context 'the readme' do
    it 'includes the driver name' do
      expect(read_file("#{drivers_path}/driver_name/README.md")).to include 'DriverName'
    end
  end
end
