module Arrival
  class Station
    include Mongoid::Document
    index({ geometry: "2dsphere" })

    attr_accessor :etas
    field :name
    field :geometry
    field :routes
    field :type
    field :direction
    field :station_id

    class << self
      def find_unique_routes_near(lat, lng, buffer_in_meters)
        point = { type: "Point", coordinates: [lng, lat] }
        stations = geo_near(point).spherical.max_distance(buffer_in_meters)

        # Compare by a composite key of routes and direction
        stations.to_a.uniq { |station| "#{station.routes}-#{station.direction}" }
      end
    end

    def distance
      attributes["geo_near_distance"]
    end
  end
end
