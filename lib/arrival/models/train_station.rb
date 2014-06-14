require "mongoid/document"
require "arrival/train_client"

module Arrival
  class TrainStation
    include Mongoid::Document
    attr_accessor :etas

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

    def fetch_etas!
      @etas = TrainClient.fetch_etas(gtfs)
    end

    def as_json(options = nil)
      {
        name: longname,
        etas: etas.as_json,
        distance: fetch_distance
      }
    end

    def fetch_distance
      geo_near_distance if self.respond_to?(:geo_near_distance)
    end
  end
end
