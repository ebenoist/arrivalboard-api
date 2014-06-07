require "ox"
require "arrival/models/eta"

module Arrival
  class CTAClient
    HOST = "lapi.transitchicago.com"
    ARRIVALS_PATH = "/api/1.0/ttarrivals.aspx"
    CLIENT_ID = ENV["TT_KEY"]
    MAX_RESULTS = 4

    class << self
      def fetch_etas(map_id)
        uri = build_request("ttarrivals.aspx", map_id)
        response = Net::HTTP.get_response(uri)

        if response.body
          etas_xml = Ox.parse(response.body).locate("ctatt/eta")
          etas_xml.map { |eta_xml| ETA.from_xml(eta_xml) }
        end
      end

      def build_request(resource, map_id)
        uri = URI("http://#{HOST}#{ARRIVALS_PATH}")
        uri.query = {
          max: MAX_RESULTS,
          key: CLIENT_ID,
          mapid: map_id
        }.to_query

        uri
      end
    end
  end
end
