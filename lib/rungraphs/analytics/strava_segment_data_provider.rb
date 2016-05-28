module Rungraphs
  module Analytics
    class StravaSegmentDataProvider
      MAX_RETRIES = 3
      DATE_RANGE = "this_week"
      ENTRY_FIELD_KEY = "entries"
      SEGMENTS = {
        "McCarren Park Lap" => 3673193,
        "Pulaski Bridge" => 6401050,
        # "Foot of Williamsburg Br to McCarren Park on Bedford Ave" => 8011296,
        "Kent Ave 14th to Metropolitan" => 4857422,
        # "Franklin - Huron to N 12th" => 8541301,
        "Williamsburg Bridge (Manhattan to Brooklyn)" => 6401036,
        # "Williamsburg Bridge - Westbound" => 6254102
        "Prospect Park Long Loop" => 3020587,
        # "Manhattan Bridge to Manhattan" => 1424290,
        "Manhattan Bridge MH>BK" => 2622770,
        # "Brooklyn Bridge (Brooklyn to Manhattan)" => 6400995,
        "Brooklyn Bridge (Manhattan to Brooklyn)" => 6400998,
        # "Columbia: Degraw to Atlantic" => 5701493,
        "Red Hook 400m Loop" => 3669529
        # "Belt Parkway greenway From 91st to Pier" => 804505,
        # "Ocean Parkway - To Coney Island" => 5348874
      }

      def initialize
        @client = Strava::Api::V3::Client.new(:access_token => Rails.application.secrets.strava_access_token)
      end

      def get_segment_leaderboard_data(gender)
        SEGMENTS.map do |segment_name, segment_id|
          {
            :name => segment_name,
            :segment_id => segment_id,
            :entries => @client.segment_leaderboards(segment_id, {:date_range => DATE_RANGE, :gender => gender})[ENTRY_FIELD_KEY]
          }
        end
      end
    end
  end
end