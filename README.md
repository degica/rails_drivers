# RailsDrivers

## What are these "drivers"?

Each driver is like a mini Rails app that has full access to the main app. A driver has its own `app`, `config`, `spec`, and `db` folder.

Technically speaking, drivers are just a way to put code into a different folder, but there are some rules we like to follow in order to reduce application complexity:

- Drivers should not touch other drivers
- The main app should not touch drivers directly

The "main app" refers to the files inside your `<project root>/app` directory.

Thankfully, we can test that these rules are adhered to by removing drivers before running the test suite.

## Aren't these just engines?

Very similar, yes. They use the same Rails facilities for adding new `app` paths, etc.

But Drivers have one useful property: they can be freely added and removed from your project without breaking anything.

## Usage

Every folder inside `drivers` has its own `app`, `config`, `db`, and `spec` folders. They are effectively a part of the overall Rails app.

### Creating a new driver

Just run `rails g driver my_new_driver_name`.

### Creating migrations for a driver

`bundle exec driver my_driver_name generate migration blah etc_etc:string`

The `driver` utility technically works with other generators and rake tasks, but is only guaranteed to work with migrations.
The reason is that some generators assume a particular path, rather than using the Rails path methods.

### Testing for coupling

Since drivers are merged into your main application just like engines, there's nothing stopping them from accessing other drivers, and there's nothing stopping your main application from accessing drivers. In order to ensure those things don't happen, we have a handful of rake tasks:

1. `rake driver:isolate[<name of driver>] # leaves you with only one driver`
2. `rake driver:clear                     # removes all drivers`
3. `rake driver:restore                   # restores all drivers`

Suppose you have a driver called `store` and a driver called `admin`. You don't want `store` and `admin` to talk to each other.

```bash
# Run specs with store driver only
rake driver:isolate[store]
rspec --pattern '{spec,drivers/*/spec}/**{,/*/**}/*_spec.rb'
rake driver:restore

# Run specs with admin driver only
rake driver:isolate[admin]
rspec --pattern '{spec,drivers/*/spec}/**{,/*/**}/*_spec.rb'
rake driver:restore
```

This lets you to ensure that the store and admin function properly without each other. Note we're running all of the main app's specs twice. This is good because we also want to make sure the main app is not reaching into drivers.

Of course there's nothing stopping you from using if-statements to detect whether a driver is present. It's up to you to determine what's a "safe" level of crossover. Generally, if you find yourself using a lot of those if-statements, you should consider rethinking which functionality belongs in a driver and which functionality belongs in your main app.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rails_drivers'
```

And then execute:
```bash
$ bundle install
```

Add this line to your routes.rb

```ruby
require 'rails_drivers/routes'
```

(Optional) Add these lines to your `spec/rails_helper.rb`

```ruby
Dir[Rails.root.join("drivers/*/spec/support/*.rb")].each { |f| require f }

RSpec.configure do |config|
  Dir[Rails.root.join('drivers/*/spec')].each { |x| config.project_source_dirs << x }
  Dir[Rails.root.join('drivers/*/lib')].each { |x| config.project_source_dirs << x }
  Dir[Rails.root.join('drivers/*/app')].each { |x| config.project_source_dirs << x }
end
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
