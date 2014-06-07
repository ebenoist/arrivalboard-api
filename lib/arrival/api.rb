require "arrival/api/version"
require "sinatra"
require "sinatra/contrib"
require "arrival/models/eta"
require "arrival/models/train_station"
require "arrival/models/bus_stop"
require "arrival/train_client"
require "arrival/bus_client"

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

          stations = TrainStation.find_unique_lines_near(lat, lng, buffer, MAX_RESULTS)
          stops = BusStop.find_unique_routes_near(lat, lng, buffer, MAX_RESULTS)

          etas = []
          etas.concat(train_etas(stations))
          etas.concat(bus_etas(stops))
          Arrival.logger.info(etas)

          etas.to_json
        end

        def train_etas(stations)
          stations.map do |station|
            TrainClient.fetch_etas(station.gtfs).as_json
          end.flatten
        end

        def bus_etas(stops)
          stops.map do |stop|
            BusClient.fetch_etas(stop.stop_id).as_json
          end.flatten
        end

      end
    end

  end
end
