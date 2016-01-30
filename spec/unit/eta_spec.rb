require "arrival/models/eta"
require "ox"

module Arrival
  describe ETA do
    before(:each) do
      # Freeze time for DST flakes
      today = Time.new(2016, 10, 30, 14, 14, 14, "-06:00")
      allow(Time).to receive(:now).and_return(today)
    end

    describe "::from_bus_xml" do
      it "can be generated from xml" do
        route = "56"
        destination = "Jefferson Park Blue"
        arrival_time = "20140517 12:55:58"
        direction = "Northbound"

        eta_xml = <<-XML
        <prd>
          <rt>#{route}</rt>
          <des>#{destination}</des>
          <prdtm>#{arrival_time}</prdtm>
          <rtdir>#{direction}</rtdir>
        </prd>
        XML

        document = Ox.parse(eta_xml)
        eta = Arrival::ETA.from_bus_xml(document)
        expect(eta.route).to eq(route)
        expect(eta.destination).to eq(destination)
        expect(eta.direction).to eq(direction)
      end
    end

    describe "::from_train_xml" do
      it "can be generated from xml" do
        route = "Blue"
        destination = "Forest Park"
        arrival_time = "20140517 12:55:58"

        eta_xml = <<-XML
        <eta>
          <rt>#{route}</rt>
          <destNm>#{destination}</destNm>
          <arrT>#{arrival_time}</arrT>
        </eta>
        XML

        document = Ox.parse(eta_xml)
        eta = Arrival::ETA.from_train_xml(document)
        expect(eta.route).to eq(route)
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
        eta = Arrival::ETA.from_train_xml(document)
        expect(eta.arrival_time).to eq("2014-05-17T17:55:58Z")
      end

      def with_time_zone(tz_name)
        prev_tz = ENV['TZ']
        ENV['TZ'] = tz_name
        yield
      ensure
        ENV['TZ'] = prev_tz
      end

      it "forces chicago time even if the current timezone is not chicago" do
        arrival_time = "20140517 12:55:58"

        eta_xml = <<-XML
        <eta>
          <staNm>foo</staNm>
          <rt>bar</rt>
          <destNm>some</destNm>
          <arrT>#{arrival_time}</arrT>
        </eta>
        XML

        eta = nil
        with_time_zone("US/Eastern") do
          document = Ox.parse(eta_xml)
          eta = Arrival::ETA.from_train_xml(document)
        end

        expect(eta.arrival_time).to eq("2014-05-17T17:55:58Z")
      end
    end

  end
end
