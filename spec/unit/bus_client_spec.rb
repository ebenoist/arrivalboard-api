require "arrival/bus_client"

module Arrival
  describe BusClient do
    it "makes a request with a station id and returns a time table" do
      stp_id = 40570
      request = WebMock.stub_request(
        :get,
        "http://#{BusClient::HOST}#{BusClient::PREDICTIONS_PATH}?key=#{BusClient::CLIENT_ID}&stpid=#{stp_id}"
      )

      BusClient.fetch_etas(stp_id)
      request.should have_been_made
    end

    it "returns a parsed XML object" do
      sample_response = <<-XML
      <?xml version="1.0"?>

          <bustime-response>

              <prd>
                <tmstmp>20140607 14:19</tmstmp>
                <typ>A</typ>
                <stpnm>Milwaukee &amp; Armitage</stpnm>
                <stpid>14564</stpid>
                <vid>6849</vid>


                <dstp>333</dstp>
                <rt>56</rt>
                <rtdir>Northbound</rtdir>
                    <des>Jefferson Park Blue Line</des>
                    <prdtm>20140607 14:20</prdtm>

                    <tablockid>56 -451</tablockid>
                    <tatripid>77</tatripid>
              </prd>

              <prd>
                <tmstmp>20140607 14:19</tmstmp>
                <typ>A</typ>
                <stpnm>Milwaukee &amp; Armitage</stpnm>
                <stpid>14564</stpid>
                <vid>6744</vid>


                <dstp>6764</dstp>
                <rt>56</rt>
                <rtdir>Northbound</rtdir>
                    <des>Jefferson Park Blue Line</des>
                    <prdtm>20140607 14:32</prdtm>

                    <tablockid>56 -410</tablockid>
                    <tatripid>79</tatripid>
              </prd>

              <prd>
                <tmstmp>20140607 14:19</tmstmp>
                <typ>A</typ>
                <stpnm>Milwaukee &amp; Armitage</stpnm>
                <stpid>14564</stpid>
                <vid>6772</vid>


                <dstp>9418</dstp>
                <rt>56</rt>
                <rtdir>Northbound</rtdir>
                    <des>Jefferson Park Blue Line</des>
                    <prdtm>20140607 14:36</prdtm>

                    <tablockid>56 -408</tablockid>
                    <tatripid>81</tatripid>
              </prd>

              <prd>
                <tmstmp>20140607 14:19</tmstmp>
                <typ>A</typ>
                <stpnm>Milwaukee &amp; Armitage</stpnm>
                <stpid>14564</stpid>
                <vid>6502</vid>


                <dstp>18856</dstp>
                <rt>56</rt>
                <rtdir>Northbound</rtdir>
                    <des>Jefferson Park Blue Line</des>
                    <prdtm>20140607 14:48</prdtm>

                    <tablockid>56 -406</tablockid>
                    <tatripid>83</tatripid>
              </prd>

          </bustime-response>
      XML

      request = WebMock.stub_request(:get, /#{BusClient::PREDICTIONS_PATH}/).to_return({
        status: 200,
        body: sample_response
      })

      response = BusClient.fetch_etas(10)
      expect(response).to have(4).items
      expect(response.map(&:route).uniq).to eq(["56"])
    end
  end
end
