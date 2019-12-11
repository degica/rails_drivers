# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rails Drivers' do
  context 'a rails app' do
    let(:product_model) do
      <<-RUBY
      class Product < ApplicationRecord
      end
      RUBY
    end

    it 'loads constants in app/models' do
      create_file 'app/models/product.rb', product_model
      run_command 'rails g migration create_products name:string'
      run_command 'rails db:migrate'

      expect(run_ruby %{puts Product.create(name: "success").name}).to eq "success\n"
    end

    it 'loads constants in drivers/*/app/models' do
      create_file 'drivers/store/app/models/product.rb', product_model
      run_command 'driver store g migration create_products name:string'
      run_command 'rails db:migrate'

      expect(run_ruby %{puts Product.create(name: "success").name}).to eq "success\n"
    end
  end
end
