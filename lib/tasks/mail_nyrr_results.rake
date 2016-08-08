desc "Send NYRR results weekly report"

namespace :nyrr do
  task :mail_results_data => :environment do
    if Time.now.monday?
      NyrrRaceResultsMailer.nyrr_results_report.deliver_now
    else
      puts "bailing because it is not Monday"
    end
  end
end