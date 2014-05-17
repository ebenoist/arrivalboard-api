require 'rubygems'
require 'bundler/setup'
require File.expand_path '../initialize.rb', __FILE__

require "arrival/api"

api = Rack::URLMap.new(
  "/" => Arrival::API,
)

run Rack::Cascade.new([
  api
])
