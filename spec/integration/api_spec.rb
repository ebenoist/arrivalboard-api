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
          Station.create({
            name: "California/Milwaukee",
            routes: "Blue Line",
            station_id: 40570,
            type: :cta_train,
            geometry: {
              "type"=>"Point",
              "coordinates"=>[-87.69688979878794, 41.921939171500014]
            }
          })

          Station.create({
            name: "Milwaukee & Armitage",
            station_id: 14564,
            routes: "56",
            type: :cta_bus,
            geometry: {
              "type"=>"Point",
              "coordinates"=>[-87.68871227199998, 41.91772537700001]
            },
            direction: "NWB"
          })

          Station.create({
            name: "W 38th Ave & Irving St",
            station_id: 13716,
            routes: "32",
            type: :rtd_bus,
            geometry: {
              "type"=>"Point",
              "coordinates"=>[-87.68871227199998, 41.91772537700001]
            },
            direction: "South"
          })
        end

        def bus_etas
          File.read("#{Arrival.fixture_dir}/bus_response.xml")
        end

        def train_etas
          File.read("#{Arrival.fixture_dir}/train_response.xml")
        end

        def rtd_etas
          File.read("#{Arrival.fixture_dir}/rtd-bus-feed.pb")
        end

        it "returns etas for the found stations" do
          WebMock.stub_request(:get, /ctabustracker.com/).to_return({ status: 200, body: bus_etas })
          WebMock.stub_request(:get, /transitchicago.com/).to_return({ status: 200, body: train_etas })
          WebMock.stub_request(:get, /www.rtd-denver.com/).to_return({ status: 200, body: rtd_etas })

          params = {
            lat: 41.923336,
            lng: -87.702231,
            buffer: 5000
          }

          get "v1/arrivals", params
          expect(last_response).to be_successful
          body = JSON.parse(last_response.body, { symbolize_names: true })

          expect(body).to have(3).items

          california_blue = body.detect { |station| station[:name] == "California/Milwaukee" }
          mil_and_arm = body.detect { |station| station[:name] == "Milwaukee & Armitage" }
          denver = body.detect { |station| station[:name] == "W 38th Ave & Irving St" }

          expect(california_blue[:etas]).to have(3).items
          expect(california_blue[:name]).to eq("California/Milwaukee")

          expect(mil_and_arm[:etas]).to have(4).items
          expect(mil_and_arm[:name]).to eq("Milwaukee & Armitage")

          expect(denver[:etas]).to have(1).items
          expect(denver[:name]).to eq("W 38th Ave & Irving St")
        end
      end
    end
  end
end
