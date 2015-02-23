%w(. ./lib/ ./config/).each do |path|
  $: << path
end

require "bundler"
Bundler.setup

require "dotenv"
Dotenv.load

require "arrival"
Dir.glob("./lib/initializers/*").sort.each { |file| require file }
