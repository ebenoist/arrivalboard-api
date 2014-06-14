require "json"
require "arrival/api"

def app
  Arrival::API
end

module Arrival
  describe API do
    describe "/arrivals" do
      describe "#GET" do
        before(:each) do
          TrainStation.create({
            longname: "California/Milwaukee",
            station_id: 570,
            lines: "Blue Line",
            address: "2211 N. California Avenue",
            gtfs: 40570, type: nil,
            geometry: {
              "type"=>"Point",
              "coordinates"=>[-87.69688979878794, 41.921939171500014]
            }
          })

          BusStop.create({
            stop_id: 14564,
            routes: "56",
            name: "Milwaukee & Armitage",
            geometry: {
              "type"=>"Point",
              "coordinates"=>[-87.68871227199998, 41.91772537700001]
            },
            direction: "NWB"
          })
        end

        def bus_etas
          File.read("#{Arrival.fixture_dir}/bus_response.xml")
        end

        def train_etas
          File.read("#{Arrival.fixture_dir}/train_response.xml")
        end

        it "returns etas for the found stations" do
          WebMock.stub_request(:get, /ctabustracker.com/).to_return({ status: 200, body: bus_etas })
          WebMock.stub_request(:get, /transitchicago.com/).to_return({ status: 200, body: train_etas })

          params = {
            lat: 41.923336,
            lng: -87.702231,
            buffer: 5000
          }

          get "v1/arrivals", params
          expect(last_response).to be_successful
          body = JSON.parse(last_response.body, { symbolize_names: true })

          expect(body).to have(2).items

          california_blue = body.first
          mil_and_arm = body[1]

          expect(california_blue[:etas]).to have(3).items
          expect(california_blue[:name]).to eq("California/Milwaukee")

          expect(mil_and_arm[:etas]).to have(4).items
          expect(mil_and_arm[:name]).to eq("Milwaukee & Armitage")
        end
      end
    end
  end
end
