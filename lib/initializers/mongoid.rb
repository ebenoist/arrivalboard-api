require "mongoid"

Mongoid.load!(Arrival.database_config, Arrival.env)
