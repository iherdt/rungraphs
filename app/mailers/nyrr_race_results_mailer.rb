class NyrrRaceResultsMailer < ApplicationMailer
  REPORT_EMAIL = "rungraphs-reports@googlegroups.com"

  def nyrr_results_report(report_email = REPORT_EMAIL, start_time = Time.now.at_midnight - 1.week, end_time = Time.now.at_midnight)
    nyrr_race_results_provider = Rungraphs::Analytics::NYRRRaceResultsAnalyticsProvider.new(start_time, end_time)
    @races = nyrr_race_results_provider.get_local_competitive_race_results
    if @races.length == 0
      puts "No results. Bailing on email."
      return
    else
      mail(:to => report_email, :subject => "NYRR Unattached Brooklyn Runners Weekly Report #{Time.now.in_time_zone('Eastern Time (US & Canada)').to_date.strftime('%m/%d/%y')}")
    end
  end

  def team_results_report(team_code, report_email = REPORT_EMAIL, start_time = Time.now.in_time_zone("Eastern Time (US & Canada)").at_midnight, end_time = Time.now.in_time_zone("Eastern Time (US & Canada)").at_midnight, team_champs = false)
    nyrr_race_results_provider = Rungraphs::Analytics::NYRRRaceResultsAnalyticsProvider.new(start_time, end_time)
    @races = nyrr_race_results_provider.get_team_race_results(team_code, team_champs)
    @team_code = team_code
    if @races.length == 0
      puts "No results. Bailing on email."
      return
    else
      mail(:to => report_email, :subject => "#{team_code.upcase} #{@races.first[0][:name]} Race Results")
    end
  end
end
