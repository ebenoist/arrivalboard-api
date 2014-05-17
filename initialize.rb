%w(. ./lib/ ./config/).each do |path|
  $: << path
end

load("keys.rb") rescue "Please create an keys.rb"
require "bundler"
Bundler.setup

require "arrival"
Dir.glob("./lib/initializers/*").sort.each { |file| require file }
