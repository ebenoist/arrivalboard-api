require "arrival/models/eta"
require "ox"

module Arrival
  describe ETA do
    it "can be generated from xml" do
      route = "Blue"
      station = "California"
      destination = "Forest Park"
      arrival_time = "20140517 12:55:58"

      eta_xml = <<-XML
        <eta>
          <staNm>#{station}</staNm>
          <rt>#{route}</rt>
          <destNm>#{destination}</destNm>
          <arrT>#{arrival_time}</arrT>
        </eta>
      XML

      document = Ox.parse(eta_xml)
      eta = Arrival::ETA.from_xml(document)
      expect(eta.route).to eq(route)
      expect(eta.station).to eq(station)
      expect(eta.destination).to eq(destination)
    end

    it "parses the time as chicago time" do
      arrival_time = "20140517 12:55:58"

      eta_xml = <<-XML
        <eta>
          <staNm>foo</staNm>
          <rt>bar</rt>
          <destNm>some</destNm>
          <arrT>#{arrival_time}</arrT>
        </eta>
      XML

      document = Ox.parse(eta_xml)
      eta = Arrival::ETA.from_xml(document)
      expect(eta.arrival_time).to eq("2014-05-17T12:55:58-05:00")
    end
  end
end
