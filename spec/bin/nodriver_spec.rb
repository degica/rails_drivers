# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'bin/nodriver' do
  it 'can run a command without any drivers present' do
    run_command('rails g driver one')
    run_command('rails g driver two')

    expect(run_command "ls -t #{drivers_path}").to eq "two\none\n"
    expect(run_command "nodriver do ls #{drivers_path}").to be_empty
    expect(run_command "ls -t #{drivers_path}").to eq "two\none\n"
  end
end
