require "arrival/models/station"

module Arrival
  describe Station do
    describe "::find_unique_routes_near" do
      before(:each) do
        @chi_geometry = { type: "Point", coordinates: [41.88, -87.62] }
        sf_geometry = { type: "Point", coordinates: [-122.41, 37.78] }

        @chicago = Station.create({ name: "chicago", geometry: @chi_geometry })
        @sanfran = Station.create({ name: "san fran", geometry: sf_geometry })
      end

      it "can be found by a lat lng point with a buffer" do
        found = Station.find_unique_routes_near(-87.6212, 41.881, 200)
        expect(found).to have(1).item
        expect(found.first.name).to eq("chicago")
      end

      it "only returns result for the closest station for a given line" do
        logan = { type: "Point", coordinates: [41.92972804224899, -87.70854138602054] }
        california = { type: "Point", coordinates: [41.921939171500014, -87.69688979878794,] }

        Station.create({ routes: "blue", name: "california", geometry: california })
        Station.create({ routes: "blue", name: "logan", geometry: logan })
        Station.create({ routes: "brown", name: "logan brown", geometry: logan })

        # Western
        lat = -87.68736438139825
        lng = 41.91615742912893

        found = Station.find_unique_routes_near(lat, lng, 3000)

        expect(found).to have(2).items
        expect(found.first.name).to eq("california")
        expect(found[1].name).to eq("logan brown")
      end

      it "includes stations with a unique direction if present" do
        eastbound_66 = { type: "Point", coordinates: [41.92972804224899, -87.70854138602054] }
        westbound_66 = { type: "Point", coordinates: [41.921939171500014, -87.69688979878794,] }

        Station.create({ routes: "66", name: "eastbound", geometry: eastbound_66, direction: "eastbound" })
        Station.create({ routes: "66", name: "westbound", geometry: westbound_66, direction: "westbound" })

        # Uhm, nearby
        lat = -87.68736438139825
        lng = 41.91615742912893

        found = Station.find_unique_routes_near(lat, lng, 3000)

        expect(found).to have(2).items
        expect(found.first.name).to eq("westbound")
        expect(found[1].name).to eq("eastbound")
      end
    end
  end
end

