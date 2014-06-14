require "arrival/bus_client"

module Arrival
  class BusStop
    include Mongoid::Document
    attr_reader :etas

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

    def fetch_etas!
      @etas = BusClient.fetch_etas(stop_id)
    end

    def as_json(options = nil)
      {
        etas: etas.as_json,
        distance: fetch_distance,
        name: name
      }
    end

    def fetch_distance
      geo_near_distance if self.respond_to?(:geo_near_distance)
    end
  end
end
