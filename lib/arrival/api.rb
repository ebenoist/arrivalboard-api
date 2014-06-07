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

          stations = Station.find_unique_lines_near(lat, lng, buffer, MAX_RESULTS)
          stations.map do |station|
            etas = CTAClient.fetch_etas(station.gtfs)
            Arrival.logger.info(etas.as_json)
            etas.as_json
          end.flatten.to_json
        end
      end
    end

  end
end
