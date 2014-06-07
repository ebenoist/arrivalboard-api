require "time"
require "tzinfo"

module Arrival
  class ETA
    attr_accessor :station, :destination, :arrival_time, :route, :direction

    class << self
      def from_bus_xml(xml_node)
        route = fetch_from_node(xml_node, "rt")
        station = fetch_from_node(xml_node, "stpnm")
        destination = fetch_from_node(xml_node, "des")
        direction = fetch_from_node(xml_node, "rtdir")


        raw_time = fetch_from_node(xml_node, "prdtm")
        arrival_time = parse_chicago_time(raw_time)

        ETA.new(route, station, destination, arrival_time, direction)
      end

      def from_train_xml(xml_node)
        route = fetch_from_node(xml_node, "rt")
        station = fetch_from_node(xml_node, "staNm")
        destination = fetch_from_node(xml_node, "destNm")

        raw_time = fetch_from_node(xml_node, "arrT")
        arrival_time = parse_chicago_time(raw_time)

        ETA.new(route, station, destination, arrival_time)
      end

      private

      def parse_chicago_time(raw_time)
        date, time = raw_time.split(" ")
        hour, minute, second = time.split(":")
        year = date[0..3]
        month = date[4..5]
        day = date[6..8]


        zone = TZInfo::Timezone.get("America/Chicago")
        offset = zone.current_period.utc_total_offset

        Time.new(year, month, day, hour, minute, second, offset).utc.iso8601
      end


      def fetch_from_node(node, locater)
        node.locate(locater).first.nodes.first
      end
    end

    def initialize(route, station, destination, arrival_time, direction = nil)
      @route = route
      @station = station
      @destination = destination
      @arrival_time = arrival_time
      @direction = direction
    end
  end
end
