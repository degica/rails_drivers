# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'rails g driver' do
  before :each do
    run_command 'rails g driver driver_name'
  end

  it 'creates the necessary files' do
    expect(dummy_app).to have_file 'drivers/driver_name/app/'
    expect(dummy_app).to have_file 'drivers/driver_name/app/models/driver_name/'
    expect(dummy_app).to have_file 'drivers/driver_name/app/models/driver_name.rb'
    expect(dummy_app).to have_file 'drivers/driver_name/app/controllers/'
    expect(dummy_app).to have_file 'drivers/driver_name/app/controllers/driver_name/'
    expect(dummy_app).to have_file 'drivers/driver_name/app/views/'
    expect(dummy_app).to have_file 'drivers/driver_name/app/views/driver_name/'
    expect(dummy_app).to have_file 'drivers/driver_name/config/routes.rb'
    expect(dummy_app).to have_file 'drivers/driver_name/config/initializers/driver_name_feature.rb'
  end

  context 'the model' do
    it 'has the right table_name_prefix' do
      expect(run_ruby %(puts DriverName.table_name_prefix)).to eq "driver_name_\n"
    end
  end
end
