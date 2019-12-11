# RailsDrivers

## What are these "drivers"?

Each driver is like a mini Rails app that has full access to the core of hats. A driver has its own `app`, `config`, `spec`, and `db` folder.

Technically speaking, drivers are just a way to put code into a different folder, but there are some rules we like to follow in order to reduce application complexity:

- Drivers should not touch other drivers
- The core app should not touch drivers directly

The "core" app refers to the files inside your `<project root>/app` directory.

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

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'rails_drivers'
```

And then execute:
```bash
$ bundle install
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
