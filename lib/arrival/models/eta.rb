require "active_support/time"

module Arrival
  class ETA
    attr_accessor :station, :destination, :arrival_time, :route

    class << self
      def from_xml(xml_node)
        route = fetch_from_node(xml_node, "rt")
        station = fetch_from_node(xml_node, "staNm")
        destination = fetch_from_node(xml_node, "destNm")

        raw_time = fetch_from_node(xml_node, "arrT")
        arrival_time = Time.parse(raw_time).in_time_zone("America/Chicago").iso8601

        ETA.new(route, station, destination, arrival_time)
      end

      private

      def fetch_from_node(node, locater)
        node.locate(locater).first.nodes.first
      end
    end

    def initialize(route, station, destination, arrival_time)
      @route = route
      @station = station
      @destination = destination
      @arrival_time = arrival_time
    end
  end
end
