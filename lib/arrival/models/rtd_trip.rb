module Arrival
  class RTDTrip
    include Mongoid::Document
    index({ trip_id: 1 }, { unique: true })

    field :route_id
    field :direction_id
    field :trip_id
    field :trip_headsign
  end
end
