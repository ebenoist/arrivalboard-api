module Arrival
  class BusStop
    include Mongoid::Document

    field :stop_id
    field :routes
    field :name
    field :geometry

    index({ geometry: "2dsphere" })

    class << self
      def find_unique_routes_near(lat, lng, buffer_in_meters, limit=100)
        point = { type: "Point", coordinates: [lng, lat] }
        stops = limit(limit).
          geo_near(point).
          spherical.
          max_distance(buffer_in_meters)

        unique_by_route!(stops)
      end

      def unique_by_route!(stops)
        route_list = []

        stops.map do |stop|
          if !route_list.member?(stop.routes)
            route_list << stop.routes
            stop
          end
        end.compact
      end
    end

  end
end
