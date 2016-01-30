require "ox"
require "arrival/cta_client"
require "arrival/models/eta"

module Arrival
  module TrainClient

    HOST = "lapi.transitchicago.com"
    ARRIVALS_PATH = "/api/1.0/ttarrivals.aspx"
    CLIENT_ID = ENV["TT_KEY"]
    MAX_RESULTS = 4

    class << self
      include Arrival::CTAClient

      def fetch_etas(stop_ids = [])
        cta_fetch(
          stop_ids: stop_ids,
          xml_path: "ctatt/eta",
          eta_meth: :from_train_xml
        ) do |id|
          build_request(id)
        end
      end

      def build_request(map_id)
        uri = URI.parse("http://#{HOST}#{ARRIVALS_PATH}")
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
