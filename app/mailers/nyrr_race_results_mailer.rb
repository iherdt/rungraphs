class NyrrRaceResultsMailer < ApplicationMailer
  REPORT_EMAIL = "rungraphs-reports@googlegroups.com"
  NBR_TEAM_NAME = "nbr"

  def nyrr_results_report(report_email = REPORT_EMAIL)
    nyrr_race_results_provider = Rungraphs::Analytics::NYRRRaceResultsAnalyticsProvider.new(Time.now.at_midnight - 1.week, Time.now.at_midnight)
    @races = nyrr_race_results_provider.get_local_competitive_race_results
    if @races.length == 0
      puts "No results. Bailing on email."
      return
    else
      mail(:to => report_email, :subject => "NYRR Unattached Brooklyn Runners Weekly Report #{Date.today.strftime("%m/%d/%y")}")
    end
  end

  def nbr_results_report(report_email = REPORT_EMAIL)
    nyrr_race_results_provider = Rungraphs::Analytics::NYRRRaceResultsAnalyticsProvider.new(Time.now.at_midnight, Time.now.at_midnight)
    @races = nyrr_race_results_provider.get_team_race_results(NBR_TEAM_NAME)
    if @races.length == 0
      puts "No results. Bailing on email."
      return
    else
      mail(:to => report_email, :subject => "NBR Race Results #{Date.today.strftime("%m/%d/%y")}")
    end
  end
end
