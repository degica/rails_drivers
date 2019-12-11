# frozen_string_literal: true

require 'spec_helper'
require 'pry'

RSpec.describe 'Rails Drivers' do
  it 'works' do
    expect(File.exist?("#{dummy_app}/app/models/test.rb")).to be_falsey
    run_command('rails g model Test name:string')
    expect(File.exist?("#{dummy_app}/app/models/test.rb")).to be_truthy
  end
end
