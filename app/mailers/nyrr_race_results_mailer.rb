class NyrrRaceResultsMailer < ApplicationMailer
  REPORT_EMAIL = "rungraphs-reports@googlegroups.com"

  def nyrr_results_report(report_email = REPORT_EMAIL, start_time = Time.now.at_midnight - 1.week, end_time = Time.now.at_midnight)
    nyrr_race_results_provider = Rungraphs::Analytics::NYRRRaceResultsAnalyticsProvider.new(start_time, end_time)
    @races = nyrr_race_results_provider.get_local_competitive_race_results
    if @races.length == 0
      puts "No results. Bailing on email."
      return
    else
      mail(:to => report_email, :subject => "NYRR Unattached Brooklyn Runners Weekly Report #{Date.today.strftime("%m/%d/%y")}")
    end
  end

  def team_results_report(team_code, report_email = REPORT_EMAIL, start_time = Time.now.at_midnight, end_time = Time.now.at_midnight)
    nyrr_race_results_provider = Rungraphs::Analytics::NYRRRaceResultsAnalyticsProvider.new(start_time, end_time)
    @races = nyrr_race_results_provider.get_team_race_results(team_code)
    @team_code = team_code
    if @races.length == 0
      puts "No results. Bailing on email."
      return
    else
      mail(:to => report_email, :subject => "#{team_code.upcase} Race Results #{Date.today.strftime("%m/%d/%y")}")
    end
  end
end
