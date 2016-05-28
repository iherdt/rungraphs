class StravaSegmentMailer < ApplicationMailer
  REPORT_EMAIL = "nbr-reports@googlegroups.com"

  def strava_segment_report
    strava_segment_data_provider = Rungraphs::Analytics::StravaSegmentDataProvider.new
    @leaderboards = {
      "Men's Leaderboards" => strava_segment_data_provider.get_segment_leaderboard_data("M"),
      "Women's Leaderboards" => strava_segment_data_provider.get_segment_leaderboard_data("F")
    }

    mail(:to => REPORT_EMAIL, :subject => "Rungraphs Strava Segment Weekly Report #{Date.today.strftime("%m/%d/%y")}")
  end
end
