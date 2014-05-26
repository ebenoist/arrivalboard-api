require "arrival/api/version"
require "sinatra"
require "sinatra/contrib"
require "arrival/models/eta"
require "arrival/models/station"
require "arrival/cta_client"

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

          stations = Station.find_by_point(lat, lng, buffer, MAX_RESULTS)
          stations.map do |station|
            CTAClient.fetch_etas(station.gtfs).as_json
          end.flatten.to_json
        end
      end
    end

  end
end
