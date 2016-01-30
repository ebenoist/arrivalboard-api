require "arrival/train_client"

module Arrival
  describe TrainClient do
    it "makes a request with a station id and returns a time table" do
      stop_ids = [40570, 1235]

      request_one = WebMock.stub_request(
        :get,
        "http://#{TrainClient::HOST}#{TrainClient::ARRIVALS_PATH}?key=#{TrainClient::CLIENT_ID}&mapid=40570&max=#{TrainClient::MAX_RESULTS}"
      )

      request_two = WebMock.stub_request(
        :get,
        "http://#{TrainClient::HOST}#{TrainClient::ARRIVALS_PATH}?key=#{TrainClient::CLIENT_ID}&mapid=1235&max=#{TrainClient::MAX_RESULTS}"
      )

      TrainClient.fetch_etas(stop_ids)

      request_one.should have_been_made
      request_two.should have_been_made
    end

    it "returns a parsed XML object" do
      sample_response = <<-XML
        <?xml version="1.0" encoding="UTF-8"?>
        <ctatt>
          <tmst>20140517 12:51:14</tmst>
          <errCd>0</errCd>
          <errNm />
          <eta>
            <staId>40570</staId>
            <stpId>30112</stpId>
            <staNm>California</staNm>
            <stpDe>Service toward Forest Park</stpDe>
            <rn>125</rn>
            <rt>Blue</rt>
            <destSt>30077</destSt>
            <destNm>Forest Park</destNm>
            <trDr>5</trDr>
            <prdt>20140517 12:50:58</prdt>
            <arrT>20140517 12:55:58</arrT>
            <isApp>0</isApp>
            <isSch>0</isSch>
            <isDly>0</isDly>
            <isFlt>0</isFlt>
            <flags />
            <lat>41.94277</lat>
            <lon>-87.71591</lon>
            <heading>126</heading>
          </eta>
          <eta>
            <staId>40570</staId>
            <stpId>30111</stpId>
            <staNm>California</staNm>
            <stpDe>Service toward O'Hare</stpDe>
            <rn>112</rn>
            <rt>Blue</rt>
            <destSt>30171</destSt>
            <destNm>O'Hare</destNm>
            <trDr>1</trDr>
            <prdt>20140517 12:50:52</prdt>
            <arrT>20140517 12:56:52</arrT>
            <isApp>0</isApp>
            <isSch>0</isSch>
            <isDly>0</isDly>
            <isFlt>0</isFlt>
            <flags />
            <lat>41.90253</lat>
            <lon>-87.66525</lon>
            <heading>303</heading>
          </eta>
          <eta>
            <staId>40570</staId>
            <stpId>30111</stpId>
            <staNm>California</staNm>
            <stpDe>Service toward O'Hare</stpDe>
            <rn>123</rn>
            <rt>Blue</rt>
            <destSt>0</destSt>
            <destNm>O'Hare</destNm>
            <trDr>1</trDr>
            <prdt>20140517 12:51:02</prdt>
            <arrT>20140517 13:06:02</arrT>
            <isApp>0</isApp>
            <isSch>1</isSch>
            <isDly>0</isDly>
            <isFlt>0</isFlt>
            <flags />
            <lat />
            <lon />
            <heading />
          </eta>
        </ctatt>
      XML

      request = WebMock.stub_request(:get, /#{TrainClient::ARRIVALS_PATH}/).to_return({
        status: 200,
        body: sample_response
      })

      stop_id = 10
      response = TrainClient.fetch_etas([stop_id])

      response_for_stop = response[stop_id]
      expect(response_for_stop).to have(3).items
      expect(response_for_stop.map(&:route).uniq).to eq(["Blue"])
    end
  end
end
