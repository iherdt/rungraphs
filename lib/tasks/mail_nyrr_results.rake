desc "Send NYRR results weekly report"

namespace :nyrr do
  task :results_data => :environment do
    NyrrRaceResultsMailer.nyrr_results_report.deliver_now
  end

  task :mail_results_data => :environment do
    if Time.now.monday?
      NyrrRaceResultsMailer.nyrr_results_report.deliver_now
    else
      puts "bailing because it is not Monday"
    end
  end

  task :nbr_results => :environment do
    NyrrRaceResultsMailer.nbr_results_report.deliver_now
  end

  task :mail_nbr_results => :environment do
    NyrrRaceResultsMailer.nbr_results_report.deliver_now
  end
end