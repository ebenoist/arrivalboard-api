require "mongoid/document"

module Arrival
  class Station
    include Mongoid::Document

    field :longname
    field :station_id
    field :lines
    field :address
    field :gtfs
    field :type
    field :geometry

    index({ geometry: "2dsphere" }, { unique: true })

    class << self
      def find_by_point(lat, lng, buffer_in_meters)
        point = { type: "Point", coordinates: [lng, lat] }
        geo_near(point).spherical.max_distance(buffer_in_meters)
      end
    end
  end
end
