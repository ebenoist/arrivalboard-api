require "arrival/models/train_station"

module Arrival
  describe TrainStation do
    describe "#as_json" do
      before(:each) do
        etas = [ETA.new("route", "station", "destination", "arrival")]
        TrainClient.stub(:fetch_etas).and_return(etas)
      end

      it "presents the station with attached eta information" do
        etas = [ETA.new("route", "station", "destination", "arrival")]
        TrainClient.stub(:fetch_etas).and_return(etas)

        stop = TrainStation.new({ gtfs: 10 })
        stop.fetch_etas!

        presented_stop = stop.as_json
        expect(presented_stop[:etas]).to eq(etas.as_json)
      end

      it "includes the geo_near_distance if present" do
        stop = TrainStation.new
        stop.stub(:geo_near_distance).and_return(100)

        presented_stop = stop.as_json
        expect(presented_stop[:distance]).to eq(100)
      end

      it "includes the name" do
        stop = TrainStation.new({ longname: "foo" })
        presented_stop = stop.as_json
        expect(presented_stop[:name]).to eq("foo")
      end
    end

    describe "#fetch_etas" do
      it "returns the arrival times with the BusClient" do
        etas = [ETA.new("route", "station", "destination", "arrival")]
        TrainClient.should_receive(:fetch_etas).with(10).and_return(etas)

        stop = TrainStation.new({ gtfs: 10 })
        expect(stop.fetch_etas!).to eq(etas)
      end

      it "stores the results on the instance" do
        etas = [ETA.new("route", "station", "destination", "arrival")]
        TrainClient.should_receive(:fetch_etas).with(10).and_return(etas)

        stop = TrainStation.new({ gtfs: 10 })
        stop.fetch_etas!

        expect(stop.etas).to eq(etas)
      end
    end

    describe "::find_unique_lines_near" do
      before(:each) do
        @chi_geometry = { type: "Point", coordinates: [41.88, -87.62] }
        sf_geometry = { type: "Point", coordinates: [-122.41, 37.78] }

        @chicago = TrainStation.create({ longname: "chicago", geometry: @chi_geometry })
        @sanfran = TrainStation.create({ longname: "san fran", geometry: sf_geometry })
      end

      it "can be found by a lat lng point with a buffer" do
        found = TrainStation.find_unique_lines_near(-87.6212, 41.881, 200)
        expect(found).to have(1).item
        expect(found.first.longname).to eq("chicago")
      end

      it "optionally limits the request" do
        another_spot_in_chicago = TrainStation.create({ longname: "chicago 2", geometry: @chi_geometry })
        found = TrainStation.find_unique_lines_near(-87.6212, 41.881, 200, 1)
        expect(found).to have(1).item
      end

      it "only returns result for the closest station for a given line" do
        logan = { type: "Point", coordinates: [41.92972804224899, -87.70854138602054] }
        california = { type: "Point", coordinates: [41.921939171500014, -87.69688979878794,] }

        TrainStation.create({ lines: "blue", longname: "california", geometry: california })
        TrainStation.create({ lines: "blue", longname: "logan", geometry: logan })
        TrainStation.create({ lines: "brown", longname: "logan brown", geometry: logan })

        # Western
        lat = -87.68736438139825
        lng = 41.91615742912893

        found = TrainStation.find_unique_lines_near(lat, lng, 3000, 10)

        expect(found).to have(2).items
        expect(found.first.longname).to eq("california")
        expect(found[1].longname).to eq("logan brown")
      end
    end
  end
end

