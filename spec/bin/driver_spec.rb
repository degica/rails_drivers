# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'bin/driver' do
  it 'can create a migration in a driver' do
    run_command('rails g driver driver_name')
    run_command('driver driver_name g migration create_tests value:integer')

    migrations = Dir[File.expand_path(File.join(dummy_app, "#{drivers_path}/driver_name/db/migrate/*"))]
    expect(migrations.size).to eq 1
    expect(migrations.first).to include 'create_tests'
  end

  it 'can run a command with only one driver present' do
    run_command('rails g driver one')
    run_command('rails g driver two')

    expect(run_command "ls -t #{drivers_path}").to eq "two\none\n"
    expect(run_command "driver one do ls #{drivers_path}").to eq "one\n"
    expect(run_command "ls -t #{drivers_path}").to eq "two\none\n"
  end
end
