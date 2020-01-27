# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rails Driver Overrides' do
  let(:product_model) do
    <<-RUBY
      class Product
        include RailsDrivers::Overrides

        def say_hello
          'hello'
        end
      end
    RUBY
  end

  let(:product_override) do
    <<-RUBY
      module ProductOverride
        extend ActiveSupport::Concern

        def override_method
          'it worked!'
        end
      end
    RUBY
  end

  let(:alt_product_override) do
    <<-RUBY
      module ProductOverride
        extend ActiveSupport::Concern

        def override_method
          'it worked! (v2)'
        end
      end
    RUBY
  end

  before do
    create_file 'app/models/product.rb', product_model
  end

  context 'with no override present' do
    specify 'the model still functions' do
      say_hello_result = run_ruby %(puts Product.new.say_hello)
      expect(say_hello_result).to eq "hello\n"

      override_method_included = run_ruby %(puts Product.new.respond_to?(:override_method))
      expect(override_method_included).to eq "false\n"
    end

    specify 'an override can be added mid-session' do
      create_file 'tmp/product_override.rb', product_override

      script = %(
        # First, confirm the product already exists
        IO.write 'before.out', Product.new.respond_to?(:override_method)

        # Write file mid-session
        FileUtils.mkdir_p 'drivers/store/overrides'
        FileUtils.cp 'tmp/product_override.rb', 'drivers/store/overrides'

        # Reload and the plugin should show up
        reload!
        IO.write 'after.out', Product.new.override_method
      )

      run_command 'rails c', input: script

      before = read_file('before.out')
      after = read_file('after.out')

      expect(before).to eq 'false'
      expect(after).to eq 'it worked!'
    end
  end

  context 'with an override present' do
    before do
      create_file 'drivers/store/overrides/product_override.rb', product_override
    end

    it 'is included by the model' do
      override_method_exists = run_ruby %(puts Product.new.respond_to?(:override_method))
      expect(override_method_exists).to eq "true\n"

      override_method_output = run_ruby %(puts Product.new.override_method)
      expect(override_method_output).to eq "it worked!\n"
    end

    it "populates the model's driver_overrides" do
      overrides = run_ruby %(puts Product.driver_overrides.to_s)
      expect(overrides).to eq "[ProductOverride]\n"
    end

    it 'persists across reloads' do
      create_file 'tmp/new_product_override.rb', alt_product_override

      script = %(
        IO.write 'before.out', Product.new.override_method
        FileUtils.cp 'tmp/new_product_override.rb', 'drivers/store/overrides/product_override.rb'
        reload!
        IO.write 'after.out', Product.new.override_method
      )

      run_command 'rails c', input: script

      before = read_file('before.out')
      after = read_file('after.out')

      expect(before).to eq 'it worked!'
      expect(after).to eq 'it worked! (v2)'
    end
  end
end
