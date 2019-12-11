# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rails Drivers' do
  let(:greetable_concern) do
    <<-RUBY
      module Greetable
        extend ActiveSupport::Concern
        def greet; 'hi'; end
      end
    RUBY
  end

  let(:product_includes_greetable_model) do
    <<-RUBY
      class Product < ApplicationRecord
        include Greetable
      end
    RUBY
  end

  shared_examples 'an engine' do |model_dir, concern_dir|
    it "loads from #{model_dir} and #{concern_dir}" do
      create_file File.join(model_dir, 'product.rb'), product_includes_greetable_model
      create_file File.join(concern_dir, 'greetable.rb'), greetable_concern
      run_command 'rails g migration create_products name:string'
      run_command 'rails db:migrate'

      expect(run_ruby %(puts Product.create(name: 'success').name)).to eq "success\n"
      expect(run_ruby %(puts Product.last.greet)).to eq "hi\n"
    end
  end

  it_behaves_like 'an engine', 'app/models', 'app/models/concerns'
  it_behaves_like 'an engine', 'drivers/store/app/models', 'drivers/store/app/models/concerns'

  it_behaves_like 'an engine', 'app/controllers', 'app/controllers/concerns'
  it_behaves_like 'an engine', 'drivers/store/app/controllers', 'drivers/store/app/controllers/concerns'
end
