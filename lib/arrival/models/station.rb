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

    index({ geometry: "2dsphere" })

    class << self
      def find_by_point(lat, lng, buffer_in_meters, limit=100)
        point = { type: "Point", coordinates: [lng, lat] }
        limit(limit).geo_near(point).spherical.max_distance(buffer_in_meters)
      end
    end
  end
end
