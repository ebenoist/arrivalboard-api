require "sinatra"
require "sinatra/contrib"
require "arrival/models/train_station"
require "arrival/models/bus_stop"

module Arrival
  class API < Sinatra::Base
    register Sinatra::Namespace

    before do
      content_type "application/json"
    end

    namespace "/v1" do
      namespace "/arrivals" do
        MAX_RESULTS = 10

        get do
          lat = params[:lat].to_f
          lng = params[:lng].to_f
          buffer = params[:buffer].to_i

          places = fetch_places(lat, lng, buffer)
          fetch_etas!(places)

          places.to_json
        end

        def fetch_etas!(places)
          threads = []
          places.each do |place|
            threads << Thread.new do
              place.fetch_etas!
            end
          end

          threads.map(&:join)
        end

        def fetch_places(lat, lng, buffer)
          relevant_places = []
          stations = TrainStation.find_unique_lines_near(lat, lng, buffer, MAX_RESULTS)
          stops = BusStop.find_unique_routes_near(lat, lng, buffer, MAX_RESULTS)

          relevant_places.concat(stations)
          relevant_places.concat(stops)
        end
      end
    end
  end
end
