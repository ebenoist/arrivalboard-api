require "arrival/models/station"

module Arrival
  describe Station do
    before(:each) do
      @chi_geometry = { type: "Point", coordinates: [41.88, -87.62] }
      sf_geometry = { type: "Point", coordinates: [-122.41, 37.78] }

      @chicago = Station.create({ longname: "chicago", geometry: @chi_geometry })
      @sanfran = Station.create({ longname: "san fran", geometry: sf_geometry })
    end

    it "can be found by a lat lng point with a buffer" do
      found = Station.find_unique_lines_near(-87.6212, 41.881, 200)
      expect(found).to have(1).item
      expect(found.first.longname).to eq("chicago")
    end

    it "optionally limits the request" do
      another_spot_in_chicago = Station.create({ longname: "chicago 2", geometry: @chi_geometry })
      found = Station.find_unique_lines_near(-87.6212, 41.881, 200, 1)
      expect(found).to have(1).item
    end

    it "only returns result for the closest station for a given line" do
      logan = { type: "Point", coordinates: [41.92972804224899, -87.70854138602054] }
      california = { type: "Point", coordinates: [41.921939171500014, -87.69688979878794,] }

      Station.create({ lines: "blue", longname: "california", geometry: california })
      Station.create({ lines: "blue", longname: "logan", geometry: logan })
      Station.create({ lines: "brown", longname: "logan brown", geometry: logan })

      # Western
      lat = -87.68736438139825
      lng = 41.91615742912893

      found = Station.find_unique_lines_near(lat, lng, 3000, 10)

      expect(found).to have(2).items
      expect(found.first.longname).to eq("california")
      expect(found[1].longname).to eq("logan brown")
    end
  end
end

