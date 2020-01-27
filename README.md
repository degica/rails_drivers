# RailsDrivers

## What are these "drivers"?

Each driver is like a mini Rails app that has full access to the main app. A driver has its own `app`, `config`, `spec`, and `db` folder.

Technically speaking, "driver" is just a fancy name for code that live in a different app folder. The advantage of doing this is that it provides clear-cut separation of concerns. If we follow a couple of simple rules, we can actually test that separation:

- Drivers should not touch other drivers
- The main app should not touch drivers directly

The "main app" refers to the files inside your `<project root>/app` directory.

If your test suite is good enough (see [Testing for coupling](#testing-for-coupling), you can test that these rules are adhered to by selectively adding and removing drivers before running your tests.

## Aren't these just engines?

Very similar, yes. They use the same Rails facilities for adding new `app` paths, etc.

But practically speaking, drivers come with less friction. They can be freely added and removed from your project without making changes to the main app. There's no need to mess around with gems, routes, or dummy apps.

Another difference is that drivers have a different dependency direction from engines. Engines are depended on by the Rails app:
```
         depends on
(Rails App) --> (Engine)
```
A Rails app includes an engine as a plugin. The engine doesn't know how the Rails app works. For drivers, it's the other way around:
```
      depends on
(Driver) --> (Rails App)
```
The Rails app doesn't know how its drivers work. It simply acts as a platform for all drivers to be built on. This makes drivers a great way to develop independent features that all rely on the same set of core functionality.

## Usage

Every folder inside `drivers` has its own `app`, `config`, `db`, and `spec` folders. They are effectively a part of the overall Rails app.

### Creating a new driver

Run `rails g driver my_new_driver_name` to get a scaffold driver.

### Creating migrations for a driver

`bundle exec driver my_driver_name generate migration blah etc_etc:string`

The `driver` utility technically works with other generators and rake tasks, but is only guaranteed to work with migrations.
The reason is that some generators have hard-coded path strongs, rather than using the Rails path methods.

### Creating a rake task in a driver

Every driver includes a `lib/tasks` directory where you can define rake tasks. Rake tasks defined in drivers are automatically loaded and namespaced.
For example,

```ruby
# drivers/my_driver/lib/tasks/my_namespace.rake
namespace :my_namespace do
  task :task_name do
  end
end
```

Can be executed using `rake driver:my_driver:my_namespace:task_name`.

### Overrides

Sometimes you want to add a method to a core class, but that method will only be used by one driver. This can be achieved by adding files to your driver's `overrides` directory.

```ruby
# app/models/product.rb
# (doesn't have to be a model - can be anything)
class Product < ApplicationRecord
  # When you include this, every driver's product_override.rb is loaded and
  # included. Works correctly with autoloading during development.
  include RailsDrivers::Overrides
end


# drivers/my_driver/overrides/product_override.rb
module MyDriver
  module ProductOverride
    extend ActiveSupport::Concern

    def new_method
      'Please only call me from code inside my_driver'
    end
  end
end


# Anywhere in my_driver (or elsewhere, but that's bad style)
Product.new.new_method
```

For each Override, the accompanying class simply `includes` it, so any methods you define will be available throughout the whole app. To make sure your drivers don't change the core behavior of the app, see [Testing for coupling](#testing-for-coupling).

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

# Short-hand with 'driver' utility!
bundle exec driver admin do rspec --pattern '{spec,drivers/*/spec}/**{,/*/**}/*_spec.rb'
# (can run with no drivers as well)
bundle exec nodriver do rspec --pattern '{spec,drivers/*/spec}/**{,/*/**}/*_spec.rb'

# Or you can move the driver folders around manually
mv drivers/admin tmp/drivers/admin
bundle exec rspec --pattern '{spec,drivers/*/spec}/**{,/*/**}/*_spec.rb'
mv tmp/drivers/admin drivers/admin
```

This lets you to ensure that the store and admin function properly without each other. Note we're running all of the main app's specs twice. This is good because we also want to make sure the main app is not reaching into drivers.

Of course there's nothing stopping you from using if-statements to detect whether a driver is present. It's up to you to determine what's a "safe" level of crossover. Generally, if you find yourself using a lot of those if-statements, you should consider rethinking which functionality belongs in a driver and which functionality belongs in your main app. On the other hand, the if-statements provide clear feature boundaries and can function as feature flags. Turning off a feature is as simple as removing a folder from `drivers`.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rails_drivers'
```

And then execute:
```bash
$ bundle install
```

Finally, add these lines to your routes.rb:

```ruby
require 'rails_drivers/routes'

# This can go before or after your application's route definitions
RailsDrivers::Routes.load_driver_routes
```

### RSpec

If you use RSpec with FactoryBot, add these lines to your `spec/rails_helper.rb` or `spec/spec_helper.rb`:

```ruby
Dir[Rails.root.join("drivers/*/spec/support/*.rb")].each { |f| require f }

RSpec.configure do |config|
  FactoryBot.definition_file_paths += Dir['drivers/*/spec/factories']
  FactoryBot.reload

  Dir[Rails.root.join('drivers/*/spec')].each { |x| config.project_source_dirs << x }
  Dir[Rails.root.join('drivers/*/lib')].each { |x| config.project_source_dirs << x }
  Dir[Rails.root.join('drivers/*/app')].each { |x| config.project_source_dirs << x }
end
```

### Webpacker

If you use Webpacker, take a look at this snippet. You'll want to add the code between the comments:

```javascript
// config/webpack/environment.js
const { environment } = require('@rails/webpacker')

//// Begin driver code ////
const { config } = require('@rails/webpacker')
const { sync } = require('glob')
const { basename, dirname, join, relative, resolve } = require('path')
const extname = require('path-complete-extname')

const getExtensionsGlob = () => {
  const { extensions } = config
  return extensions.length === 1 ? `**/*${extensions[0]}` : `**/*{${extensions.join(',')}}`
}

const addToEntryObject = (sourcePath) => {
  const glob = getExtensionsGlob()
  const rootPath = join(sourcePath, config.source_entry_path)
  const paths = sync(join(rootPath, glob))
  paths.forEach((path) => {
    const namespace = relative(join(rootPath), dirname(path))
    const name = join(namespace, basename(path, extname(path)))
    environment.entry.set(name, resolve(path))
  })
}

sync('drivers/*').forEach((driverPath) => {
  addToEntryObject(join(driverPath, config.source_path));
})
//// End driver code ////

module.exports = environment
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
