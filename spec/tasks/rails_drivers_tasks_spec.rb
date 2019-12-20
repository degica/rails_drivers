# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'tasks/rails_drivers_tasks.rake' do
  before do
    run_command 'rails g driver first'
    run_command 'rails g driver second'
    run_command 'rails g driver third'
  end

  describe 'rake driver:isolate' do
    context 'and a valid driver name is given' do
      it 'removes the other two drivers' do
        run_command 'rake driver:isolate[second]'
        expect(dummy_app).to_not have_file 'drivers/first'
        expect(dummy_app).to     have_file 'drivers/second'
        expect(dummy_app).to_not have_file 'drivers/third'
      end
    end

    context 'and no driver is passed' do
      it 'complains' do
        expect(run_command('rake driver:isolate')).to include 'No driver specified'
      end
    end

    context 'and an invalid driver name is given' do
      it 'prints an error' do
        expect(run_command('rake driver:isolate[bad]')).to include 'Driver "bad" not found'
      end
    end
  end

  describe 'rake driver:clear' do
    it 'removes all drivers' do
      run_command 'rake driver:clear'
      expect(dummy_app).to_not have_file 'drivers/first'
      expect(dummy_app).to_not have_file 'drivers/second'
      expect(dummy_app).to_not have_file 'drivers/third'
    end
  end

  describe 'rake driver:restore' do
    it 'undoes the effects of driver:isolate' do
      run_command 'rake driver:isolate[second]'
      run_command 'rake driver:restore'
      expect(dummy_app).to have_file 'drivers/first'
      expect(dummy_app).to have_file 'drivers/second'
      expect(dummy_app).to have_file 'drivers/third'
    end
  end
end
