# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'spec/support/dummy_app_helpers.rb' do
  context 'running commands' do
    it 'works' do
      expect(dummy_app).to_not have_file 'app/models/test.rb'
      run_command('rails g model Test name:string')
      expect(dummy_app).to have_file 'app/models/test.rb'
    end
  end

  context 'running ruby code' do
    it 'works' do
      expect(run_ruby('puts "whats up"')).to eq "whats up\n"
    end
  end

  context 'creating files' do
    it 'works' do
      create_file 'lib/test.rb', 'puts "hello"'
      expect(read_file('lib/test.rb')).to eq 'puts "hello"'
    end
  end

  context 'the dummy app' do
    it 'renders webpack assets' do
      run_command 'bin/webpack'
      html = http :get, '/'
      script_file = find_js_pack html, 'home'
      expect(http :get, script_file).to include 'Hello from home.js!'
    end
  end
end
