require "protobuf"
require "google/transit/gtfs-realtime.pb"
require "net/http"
require "uri"
require "arrival/models/eta"
require "arrival/models/rtd_trip"

module Arrival
  module RTDBusClient
    FEED_URL = "http://www.rtd-denver.com/google_sync/TripUpdate.pb"
    RTD_USER = ENV["RTD_USER"]
    RTD_PASS = ENV["RTD_PASS"]

    class << self
      def fetch_etas(stop_ids)
        return {} if stop_ids.empty?

        uri = URI.parse(FEED_URL)
        resp = Net::HTTP.start(uri.host, uri.port) do |http|
          request = Net::HTTP::Get.new(uri.request_uri)
          request.basic_auth(RTD_USER, RTD_PASS)
          http.request(request)
        end

        feed = Transit_realtime::FeedMessage.decode(resp.body)
        filter_and_parse(feed, stop_ids)
      end

      def filter_and_parse(feed, stop_ids)
        results = Hash.new { |h, k| h[k] = [] }
        stop_ids = stop_ids.map(&:to_s)

        feed.entity.map do |entity|
          entity.trip_update.stop_time_update.map do |update|
            next unless stop_ids.include?(update.stop_id)
            next if update.arrival.nil?
            results[update.stop_id.to_i] << build_eta_from(entity.trip_update.trip, update)
          end
        end

        results
      end

      def build_eta_from(trip, schedule)
        with_time_zone("America/Denver") do
          meta_info = Arrival::RTDTrip.where({
            trip_id: trip.trip_id
          })

          destination = meta_info.count >= 1 ? meta_info[0].trip_headsign : nil

          eta = ETA.new(
            trip.route_id,
            destination,
            Time.at(schedule.arrival.time).utc,
            nil
          )
        end
      end

      # Ugly hack
      def with_time_zone(tz_name)
        prev_tz = ENV['TZ']
        ENV['TZ'] = tz_name
        yield
      ensure
        ENV['TZ'] = prev_tz
      end
    end
  end
end
