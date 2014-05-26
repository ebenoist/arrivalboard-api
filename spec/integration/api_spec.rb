require "json"
require "arrival/api"
require "arrival/models/station"

def app
  Arrival::API
end

module Arrival
  describe API do
    describe "/arrivals" do
      describe "#GET" do
        before(:each) do
          CTAClient.stub(:fetch_etas).and_return([{}])
        end

        it "returns 10 of the nearest stations" do
          lat = 10
          lng = 20
          buffer = 5

          params = {
            lat: lat,
            lng: lng,
            buffer: buffer,
          }

          stations = []
          10.times do |i|
            stations << Station.new({ longname: i.to_s })
          end

          Station.should_receive(:find_by_point).with(lat, lng, buffer, API::MAX_RESULTS).and_return(stations)

          get "v1/arrivals", params
          expect(last_response).to be_successful
          parsed_body = JSON.parse(last_response.body)
          expect(parsed_body).to have(10).items
        end

        it "returns a set of etas" do
          station_one = Station.new({ gtfs: 10 })
          station_two = Station.new({ gtfs: 20 })

          Station.should_receive(:find_by_point).and_return([station_one, station_two])

          eta_one = ETA.new("blue", "cali", "forest", "soon")
          eta_two = ETA.new("blue", "cali", "ohare", "soon")

          CTAClient.should_receive(:fetch_etas).with(10).and_return(eta_one)
          CTAClient.should_receive(:fetch_etas).with(20).and_return(eta_two)

          get "v1/arrivals", { lat: 10, lng: 10, buffer: 10 }
          expect(last_response).to be_successful
          parsed_body = JSON.parse(last_response.body)
          expect(parsed_body).to eq([
            eta_one.as_json, eta_two.as_json
          ])
        end
      end
    end
  end
end
