# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'bin/driver' do
  it 'can create a migration in a driver' do
    run_command('rails g driver driver_name')
    run_command('driver driver_name g migration create_tests value:integer')

    migrations = Dir[File.expand_path(File.join(dummy_app, 'drivers/driver_name/db/migrate/*'))]
    expect(migrations.size).to eq 1
    expect(migrations.first).to include 'create_tests'
  end
end
