require 'rubygems'
require 'bundler/setup'
require File.expand_path '../initialize.rb', __FILE__

require "arrival/api"

require "rack/cors"
use Rack::Cors do
  allow do
    origins /localhost/, "arrivalboard.com"
    resource "*"
  end
end

api = Rack::URLMap.new(
  "/" => Arrival::API,
)

run Rack::Cascade.new([
  api
])
