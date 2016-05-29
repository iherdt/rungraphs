class NyrrRaceResultsMailer < ApplicationMailer
  REPORT_EMAIL = "rungraphs-reports@googlegroups.com"

  def nyrr_results_report(report_email = REPORT_EMAIL)
    nyrr_race_results_provider = Rungraphs::Analytics::NYRRRaceResultsAnalyticsProvider.new
    @races = nyrr_race_results_provider.get_local_competitive_race_results
    if @races.length == 0
      puts "No results. Bailing on email."
      return
    else
      mail(:to => report_email, :subject => "NYRR Unattached Brooklyn Runners Weekly Report #{Date.today.strftime("%m/%d/%y")}")
    end
  end
end
