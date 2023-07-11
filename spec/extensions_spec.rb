# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rails Driver Extensions' do
  let(:product_model) do
    <<-RUBY
      class Product
        include RailsDrivers::Extensions

        def say_hello
          'hello'
        end
      end
    RUBY
  end

  let(:product_extension) do
    <<-RUBY
      module Store
        module ProductExtension
          extend ActiveSupport::Concern

          def extension_method
            'it worked!'
          end
        end
      end
    RUBY
  end

  let(:alt_product_extension) do
    <<-RUBY
      module Store
        module ProductExtension
          extend ActiveSupport::Concern

          def extension_method
            'it worked! (v2)'
          end
        end
      end
    RUBY
  end

  let(:empty_product_extension) do
    <<-RUBY
      module Store
        module ProductExtension
          extend ActiveSupport::Concern
        end
      end
    RUBY
  end

  let(:name_clash_product_extension) do
    <<-RUBY
      module Store
        module ProductExtension
          extend ActiveSupport::Concern

          def say_hello
            'whoa this should not happen'
          end
        end
      end
    RUBY
  end

  let(:other_driver_product_extension) do
    <<-RUBY
      module Admin
        module ProductExtension
          extend ActiveSupport::Concern

          def admin_method
            'admin method result'
          end
        end
      end
    RUBY
  end

  before do
    create_file 'app/models/product.rb', product_model
  end

  context 'with no extension present' do
    specify 'the model still functions' do
      say_hello_result = run_ruby %(puts Product.new.say_hello)
      expect(say_hello_result).to eq "hello\n"

      extension_method_included = run_ruby %(puts Product.new.respond_to?(:extension_method))
      expect(extension_method_included).to eq "false\n"
    end

    specify 'an extension can be added mid-session' do
      create_file 'tmp/product_extension.rb', product_extension

      script = %(
        # First, confirm the product already exists
        IO.write 'before.out', Product.new.respond_to?(:extension_method)

        # Write file mid-session
        FileUtils.mkdir_p 'drivers/store/extensions'
        FileUtils.cp 'tmp/product_extension.rb', 'drivers/store/extensions'

        # Reload and the plugin should show up
        reload!
        IO.write 'after.out', Product.new.extension_method
      )

      run_command 'rails c', input: script

      before = read_file('before.out')
      after = read_file('after.out')

      expect(before).to eq 'false'
      expect(after).to eq 'it worked!'
    end
  end

  context 'with an extension present' do
    before do
      create_file 'drivers/store/extensions/product_extension.rb', product_extension
    end

    it 'is included by the model' do
      extension_method_exists = run_ruby %(puts Product.new.respond_to?(:extension_method))
      expect(extension_method_exists).to eq "true\n"

      extension_method_output = run_ruby %(puts Product.new.extension_method)
      expect(extension_method_output).to eq "it worked!\n"
    end

    it 'persists across reloads' do
      create_file 'tmp/new_product_extension.rb', alt_product_extension

      script = %(
        IO.write 'before.out', Product.new.extension_method
        FileUtils.cp 'tmp/new_product_extension.rb', 'drivers/store/extensions/product_extension.rb'
        reload!
        IO.write 'after.out', Product.new.extension_method
      )

      run_command 'rails c', input: script

      before = read_file('before.out')
      after = read_file('after.out')

      expect(before).to eq 'it worked!'
      expect(after).to eq 'it worked! (v2)'
    end

    it 'does not include removed methods across reloads' do
      create_file 'tmp/new_product_extension.rb', empty_product_extension

      script = %(
        IO.write 'before.out', Product.new.extension_method
        FileUtils.cp 'tmp/new_product_extension.rb', 'drivers/store/extensions/product_extension.rb'
        reload!
        begin
          Product.new.extension_method # This method should no longer be present!
          IO.write 'after.out', 'it did not work'
        rescue NoMethodError
          IO.write 'after.out', 'it worked'
        end
      )

      run_command 'rails c', input: script

      before = read_file('before.out')
      after = read_file('after.out')

      expect(before).to eq 'it worked!'
      expect(after).to eq 'it worked'
    end
  end

  context 'with multiple extensions present' do
    before do
      create_file 'drivers/store/extensions/product_extension.rb', product_extension
      create_file 'drivers/admin/extensions/product_extension.rb', other_driver_product_extension
    end

    it 'includes both of them' do
      extension_method_output = run_ruby %(puts Product.new.extension_method)
      expect(extension_method_output).to eq "it worked!\n"

      extension_method_output = run_ruby %(puts Product.new.admin_method)
      expect(extension_method_output).to eq "admin method result\n"
    end
  end

  context 'when an extension shadows a method in the overridden class' do
    before do
      create_file 'drivers/store/extensions/product_extension.rb', name_clash_product_extension
    end

    it 'issues a warning' do
      output = run_command 'rails c', input: 'Product', capture_stderr: true

      expect(output).to include 'Driver extension method Store::ProductExtension#say_hello ' \
                                'is shadowed by Product#say_hello and will likely not do anything.'
    end
  end
end
