require "sinatra"
require "sinatra/contrib"
require "arrival/models/station"
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
        get do
          lat = params[:lat].to_f
          lng = params[:lng].to_f
          buffer = params[:buffer].to_i

          stations = Station.find_unique_routes_near(lat, lng, buffer)
          presented = []
          threads = stations.map do |station|
            Thread.new { presented << present_station(station) }
          end

          threads.map(&:join)
          presented.to_json
        end

        def fetch_etas(station_id, type)
          case type
          when :cta_bus
            Arrival::BusClient.fetch_etas(station_id)
          when :cta_train
            Arrival::TrainClient.fetch_etas(station_id)
          end
        end

        def present_station(station)
          {
            name: station.name,
            direction: station.direction,
            distance: station.distance,
            etas: fetch_etas(station.station_id, station.type)
          }
        end
      end
    end
  end
end
