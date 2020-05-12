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
        get 'products',     to: 'products#index'
        get 'products/new', to: 'products#new'
      end
    RUBY
  end

  let(:products_controller) do
    <<-RUBY
      class ProductsController < ApplicationController
        def index
          render inline: Product.pluck(:name).join("\\n")
        end

        def new
        end
      end
    RUBY
  end

  let(:products_pack) do
    <<-JAVASCRIPT
      console.log("Hello from products pack!");
    JAVASCRIPT
  end

  let(:products_new_view) do
    <<-HTML_ERB
      <%= content_for(:head) do %>
        <%= javascript_pack_tag 'products' %>
      <% end %>

      <article>Pretend there's a product form here</article>
    HTML_ERB
  end

  let(:test_mailer) do
    <<-RUBY
      class TestMailer < ApplicationMailer
        def some_message
          mail to: 'recipient@example.com', from: 'sender@example.com'
        end
      end
    RUBY
  end

  let(:test_mailer_html) do
    <<-HTML_ERB
      <article>This is the mailer view content in html</article>
    HTML_ERB
  end

  let(:test_mailer_text) do
    <<-TEXT_ERB
      This is the mailer view content in text
    TEXT_ERB
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

  context 'with a controller in a driver' do
    before do
      create_file 'app/models/product.rb',                                product_model
      create_file 'drivers/store/app/controllers/products_controller.rb', products_controller
      create_file 'drivers/store/config/routes.rb',                       product_routes
    end

    it 'sets up routes' do
      expect(run_command 'rake routes').to include 'products'

      run_ruby %(Product.create(name: 'success').name)
      expect(http :get, '/products').to include 'success'
    end

    it 'renders webpacker packs in drivers' do
      create_file 'drivers/store/app/views/products/new.html.erb', products_new_view
      create_file 'drivers/store/app/javascript/packs/products.js', products_pack
      run_command 'bin/webpack'

      script_file = find_js_pack http(:get, '/products/new'), 'products'
      expect(http :get, script_file).to include 'Hello from products pack!'
    end
  end

  context 'with a mailer in a driver' do
    before do
      create_file 'drivers/something/app/mailers/test_mailer.rb', test_mailer
      create_file 'drivers/something/app/views/test_mailer/some_message.html.erb', test_mailer_html
      create_file 'drivers/something/app/views/test_mailer/some_message.text.erb', test_mailer_text
    end

    it 'can send mail properly' do
      delivery = run_ruby %(puts TestMailer.some_message.deliver_now)
      expect(delivery).to include 'This is the mailer view content in html'
      expect(delivery).to include 'This is the mailer view content in text'
    end
  end

  context 'with a model, spec, and factory all in a driver' do
    let(:product_model_spec) do
      <<-RUBY
        require 'spec_helper'

        RSpec.describe Product, type: :model do
          context 'factory in driver', :in_driver do
            it 'works' do
              expect(build :product).to be_a Product
            end
          end

          context 'factory out of driver', :not_in_driver do
            it 'works' do
              expect(build :funny_product).to be_a Product
            end
          end
        end
      RUBY
    end

    let(:product_factory) do
      <<-RUBY
        FactoryBot.define do
          factory :product do
            name { 'product' }
          end
        end
      RUBY
    end

    let(:funny_product_factory) do
      <<-RUBY
        FactoryBot.define do
          factory :funny_product, class: Product do
            name { 'hilarious' }
          end
        end
      RUBY
    end

    before do
      create_file 'drivers/store/app/models/product.rb',       product_model
      create_file 'drivers/store/spec/models/product_spec.rb', product_model_spec
      create_file 'drivers/store/spec/factories/product.rb',   product_factory
      create_file 'spec/factories/funny_product.rb',           funny_product_factory
    end

    it 'properly loads the factory' do
      run_command 'rspec drivers/store/spec/models/product_spec.rb -t in_driver'
    end

    it 'still loads non-driver factories' do
      run_command 'rspec drivers/store/spec/models/product_spec.rb -t not_in_driver'
    end
  end

  context 'with a rake task in a driver' do
    def make_rake_task(namespace)
      <<-RUBY
        namespace :#{namespace} do
          desc 'A dummy rake task'
          task :run do
            # Do absolutely nothing!
          end
        end
      RUBY
    end

    before do
      create_file 'drivers/store/lib/tasks/dummy.rake', make_rake_task(:dummy)
      create_file 'drivers/store/lib/tasks/nested/dummy.rake', make_rake_task(:dummy_nested)
    end

    it 'properly loads the rake tasks' do
      expect { run_command 'rake driver:store:dummy:run' }.to_not raise_error
      expect { run_command 'rake driver:store:dummy_nested:run' }.to_not raise_error
    end
  end
end
