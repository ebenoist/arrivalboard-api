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
      found = Station.find_by_point(-87.6212, 41.881, 200)
      expect(found).to have(1).item
      expect(found.first.longname).to eq("chicago")
    end

    it "optionally limits the request" do
      another_spot_in_chicago = Station.create({ longname: "chicago 2", geometry: @chi_geometry })
      found = Station.find_by_point(-87.6212, 41.881, 200, 1)
      expect(found).to have(1).item
    end
  end
end

