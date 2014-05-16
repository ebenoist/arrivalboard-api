require "arrival/models/station"

module Arrival
  describe Station do
    before(:each) do
      chi_geometry = { type: "Point", coordinates: [41.88, -87.62] }
      sf_geometry = { type: "Point", coordinates: [-122.41, 37.78] }

      @chicago = Station.create({ longname: "chicago", geometry: chi_geometry })
      @sanfran = Station.create({ longname: "san fran", geometry: sf_geometry })
    end

    it "can be found by a lat lng point with a buffer" do
      found = Station.find_by_point(-87.6212, 41.881, 200)
      expect(found).to have(1).item
      expect(found.first.longname).to eq("chicago")
    end
  end
end

