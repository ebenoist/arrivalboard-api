require "ox"
require "arrival/cta_client"
require "arrival/models/eta"

module Arrival
  module BusClient

    HOST = "www.ctabustracker.com"
    PREDICTIONS_PATH = "/bustime/api/v1/getpredictions"
    CLIENT_ID = ENV["BUS_KEY"]

    class << self
      include Arrival::CTAClient

      def fetch_etas(stop_ids = [])
        cta_fetch(
          stop_ids: stop_ids,
          xml_path: "bustime-response/prd",
          eta_meth: :from_bus_xml
        ) do |id|
          build_request(id)
        end
      end

      def build_request(stop_id)
        uri = URI.parse("http://#{HOST}#{PREDICTIONS_PATH}")
        uri.query = {
          key: CLIENT_ID,
          stpid: stop_id
        }.to_query

        uri
      end
    end
  end
end
