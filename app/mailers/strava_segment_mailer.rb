class StravaSegmentMailer < ApplicationMailer
  REPORT_EMAIL = "rungraphs-reports@googlegroups.com"

  def strava_segment_report(report_email = REPORT_EMAIL)
    strava_segment_data_provider = Rungraphs::Analytics::StravaSegmentDataProvider.new
    @leaderboards = {
      "Men's Leaderboards" => strava_segment_data_provider.get_segment_leaderboard_data("M"),
      "Women's Leaderboards" => strava_segment_data_provider.get_segment_leaderboard_data("F")
    }

    mail(:to => report_email, :subject => "Rungraphs Strava Segment Weekly Report #{Time.now.in_time_zone('Eastern Time (US & Canada)').to_date.strftime('%m/%d/%y')}")
  end
end
