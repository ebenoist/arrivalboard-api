module Arrival
  module CTAClient
    def cta_fetch(stop_ids: [], xml_path:, eta_meth:)
      return {} if stop_ids.empty?

      results = Hash.new { |h, k| h[k] = [] }
      threads = stop_ids.map do |stop_id|
        Thread.new {
          uri = yield stop_id
          results[stop_id] = fetch(uri, xml_path, eta_meth)
        }
      end

      threads.map(&:join)
      results
    end

    def fetch(uri, xml_path, eta_meth)
      response = Net::HTTP.get_response(uri)

      if response.body
        etas_xml = Ox.parse(response.body).locate(xml_path)
        etas_xml.map { |eta_xml| ETA.send(eta_meth, eta_xml) }
      end
    end
  end
end
