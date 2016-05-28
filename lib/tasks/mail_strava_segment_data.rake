desc "Send strava segment weekly report"

namespace :strava do
  task :segment_data => :environment do
    StravaSegmentMailer.strava_segment_report.deliver_now
  end

  task :mail_segment_data => :environment do
    if Time.now.monday?
      StravaSegmentMailer.strava_segment_report.deliver_now
    else
      puts "bailing because it is not Monday"
    end
  end
end