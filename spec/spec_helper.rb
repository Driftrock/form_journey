ENV["RAILS_ENV"] = 'test'
require 'simplecov'
SimpleCov.start

require File.expand_path('../dummy/config/environment', __FILE__)
require 'rspec'
require 'pry'
require_relative '../lib/form_journey'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|

end
