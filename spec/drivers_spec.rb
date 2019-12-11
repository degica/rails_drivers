# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'A Rails Driver' do
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

  let(:product_model) do
    <<-RUBY
      class Product < ApplicationRecord
        validates :name, presence: true
      end
    RUBY
  end

  let(:product_routes) do
    <<-RUBY
      Dummy::Application.routes.draw do
        get :products, to: 'products#index'
      end
    RUBY
  end

  let(:products_controller) do
    <<-RUBY
      class ProductsController < ApplicationController
        def index
          render inline: Product.pluck(:name).join("\\n")
        end
      end
    RUBY
  end

  before do
    run_command 'rails g migration create_products name:string'
    run_command 'rails db:migrate'
  end

  shared_examples 'an engine' do |model_dir, concern_dir|
    it "loads from #{model_dir} and #{concern_dir}" do
      create_file File.join(model_dir, 'product.rb'), product_includes_greetable_model
      create_file File.join(concern_dir, 'greetable.rb'), greetable_concern

      expect(run_ruby %(puts Product.create(name: 'success').name)).to eq "success\n"
      expect(run_ruby %(puts Product.last.greet)).to eq "hi\n"
    end
  end

  it_behaves_like 'an engine', 'app/models',               'app/models/concerns'
  it_behaves_like 'an engine', 'drivers/store/app/models', 'drivers/store/app/models/concerns'

  it_behaves_like 'an engine', 'app/controllers',               'app/controllers/concerns'
  it_behaves_like 'an engine', 'drivers/store/app/controllers', 'drivers/store/app/controllers/concerns'

  it 'sets up routes' do
    create_file 'app/models/product.rb',                    product_model
    create_file 'drivers/store/app/controllers/product.rb', products_controller
    create_file 'drivers/store/config/routes.rb',           product_routes

    expect(run_command 'rake routes').to include 'products'

    run_ruby %(Product.create(name: 'success').name)
    expect(http :get, '/products').to include 'success'
  end
end
