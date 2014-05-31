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
      def find_unique_lines_near(lat, lng, buffer_in_meters, limit=100)
        point = { type: "Point", coordinates: [lng, lat] }
        stations = limit(limit).
          geo_near(point).
          spherical.
          max_distance(buffer_in_meters)

        unique_by_line!(stations)
      end

      def unique_by_line!(stations)
        line_list = []

        stations.map do |station|
          if !line_list.member?(station.lines)
            line_list << station.lines
            station
          end
        end.compact
      end

    end
  end
end
