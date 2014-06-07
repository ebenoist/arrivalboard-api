require "ox"
require "arrival/models/eta"

module Arrival
  class BusClient
    HOST = "www.ctabustracker.com"
    PREDICTIONS_PATH = "/bustime/api/v1/getpredictions"
    CLIENT_ID = ENV["BUS_KEY"]

    class << self
      def fetch_etas(stop_id)
        uri = build_request(stop_id)
        response = Net::HTTP.get_response(uri)

        if response.body
          etas_xml = Ox.parse(response.body).locate("bustime-response/prd")
          etas_xml.map { |eta_xml| ETA.from_bus_xml(eta_xml) }
        end
      end

      def build_request(stop_id)
        uri = URI("http://#{HOST}#{PREDICTIONS_PATH}")
        uri.query = {
          key: CLIENT_ID,
          stpid: stop_id
        }.to_query

        uri
      end
    end
  end
end
