require "sinatra"
require "sinatra/contrib"
require "arrival/models/station"
require "arrival/train_client"
require "arrival/bus_client"
require "arrival/rtd_bus_client"

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
          etas = fetch_etas(stations)

          stations.map do |station|
            present_station(station, etas[station.station_id])
          end.to_json
        end

        def fetch_etas(stations)
          grouped = Hash.new { |h, k| h[k] = [] }

          stations.each do |station|
            grouped[station.type] << station.station_id
          end


          etas = {}
          etas.merge!(Arrival::BusClient.fetch_etas(grouped[:cta_bus]))
          etas.merge!(Arrival::TrainClient.fetch_etas(grouped[:cta_train]))
          etas.merge!(Arrival::RTDBusClient.fetch_etas(grouped[:rtd_bus]))

          etas
        end

        def present_station(station, etas)
          {
            name: station.name,
            direction: station.direction,
            distance: station.distance,
            etas: etas || []
          }
        end
      end
    end
  end
end
