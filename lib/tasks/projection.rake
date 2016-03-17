# require 'rubygems'
# require 'mechanize'
# require 'open-uri'
# require 'json'

=begin

bundle exec rake projection:new["http://api.rtrt.me/events/NYH2016/profiles","4d7a9ceb0be65b3cc4948ee9","DB46DA9BD41A9123CD26","13.1","NYC Half 2016","March 20th 2016 8:00am","03/20/16"]

=end
namespace :projection do

  task :new, [:url, :apiid, :token, :distance, :name, :date_and_time, :date] => :environment do |t, arg|
    distance = arg[:distance]
    name = arg[:name]
    date_and_time = arg[:date_and_time]
    date = format_date(arg[:date])

    projected_race = ProjectedRace.create(name: name, date_and_time: date_and_time, distance: distance, date: date)
    create_new_result_projections(projected_race, arg[:url], arg[:apiid], arg[:token])
    projected_race.save!
    projected_race.reload
    projected_race.set_team_results
  end

  def create_new_result_projections(projected_race, url, apiid, token)
    url = url
    params = {
      max: "100000",
      total: "1",
      failonmax: "1",
      appid: apiid,
      token: token,
      search: "",
      source: "webtracker"
    }

    roster_data = RestClient.post url, params, :content_type => :json, :accept => :json

    json_roster_data = /{.+}/.match(roster_data)[0]
    roster_data_hash = JSON.parse(json_roster_data)
    counter = 0

    roster_data_hash['list'].each do |runner_info|
      if projected_race.projected_results.any? do |projected_result|
        projected_result.first_name == runner_info['fname'] &&
        projected_result.last_name == runner_info['lname'] &&
        projected_result.city == runner_info['city']
      end
        if runner_info['bib'] < projected_result.bib
          projected_result.update_attributes("bib" => runner_info['bib'])
          projected_result.save!
          next
        end
      end
      counter += 1

      # create result
      projected_result = ProjectedResult.create(
          first_name: runner_info['fname'],
          last_name: runner_info['lname'],
          sex: runner_info['sex'],
          full_name: "#{runner_info['name']}",
          city: runner_info['city'],
          country: runner_info['country'],
          bib: runner_info['bib'],
          projected_race_id: projected_race.id
        )

        if runner_info['city']
          city = runner_info['city'].downcase
        else
          city = nil
        end

      # add runner and projected time
      runners = Runner.where(first_name: runner_info['fname'].downcase, last_name: runner_info['lname'].downcase, city: city)

      # if a runner changes cities or if runner with same name without city
      if runners.empty?
        runners = Runner.where(first_name: runner_info['fname'].downcase, last_name: runner_info['lname'].downcase).where.not(city: city)
      end

      if !runners.empty? && !runners[0].results.empty?
        runner = runners[0]

        projected_result.update_attributes("runner_id" => runner.id, "team" => runner.team, "state" => runner.state, "age" => Time.now.year - runner.birth_year)

        # TODO, limit best to races within the last 3 months
        # exclude mile since AG not as accurate and check for AG% since 18 mile Tune Up does not have AG%
        best_result = runner.results.where.not(ag_percent: nil, distance: 1.0).where("date > ?", 3.months.ago).order('ag_percent DESC')[0]

        # if runner has results in last 3 months, find all time best result
        if best_result.nil?
          best_result = runner.results.where.not(ag_percent: nil, distance: 1.0).where("date > ?", 3.months.ago).order('ag_percent DESC')[0]
        end

        # if still no best time, find the most recent race
        if best_result.nil?
          best_result = runner.results.where.not(distance: 0.2).order('date DESC')[0]
        end

        # calculate projected time
        # T2 = T1 x (D2/D1)1.06
        puts counter
        puts runner.full_name
        p best_result

        next if best_result.nil?

        # check type of result time
        if best_result.net_time && !best_result.net_time.blank?
          if /^\d\d.\d\d$/ =~ best_result.net_time
            best_result.net_time = '00:' + best_result.net_time
          end
          best_time = DateTime.parse(best_result.net_time)
        elsif best_result.finish_time && !best_result.finish_time.blank?
          if /^\d\d.\d\d$/ =~ best_result.finish_time
            best_result.finish_time = '00:' + best_result.finish_time
          end
          best_time = DateTime.parse(best_result.finish_time)
        elsif best_result.gun_time && !best_result.gun_time.blank?
          if /^\d\d.\d\d$/ =~ best_result.gun_time
            best_result.gun_time = '00:' + best_result.gun_time
          end
          best_time = DateTime.parse(best_result.gun_time)
        else
          next
        end

        puts "best_time #{best_time.hour}:#{(best_time.min)}:#{best_time.sec}"
        best_time_in_seconds = best_time.hour * 60 * 60 + best_time.min * 60 + best_time.sec
        puts "best_time_in_seconds #{best_time_in_seconds}"
        puts "projected_race.distance #{projected_race.distance}"
        puts "best_result.distance #{best_result.distance}"
        projected_time_in_seconds = best_time_in_seconds * ((projected_race.distance / best_result.distance )**1.06)
        puts "projected_time_in_seconds #{projected_time_in_seconds}"
        projected_time = "#{sprintf "%02d",(projected_time_in_seconds / 3600).floor}:#{sprintf "%02d", ((projected_time_in_seconds % 3600) / 60).floor}:#{sprintf "%02d", ((projected_time_in_seconds % 3600) % 60).round}"
        puts "projected_time #{projected_time}"
        projected_pace_in_seconds = projected_time_in_seconds / projected_race.distance
        projected_pace = "#{sprintf "%02d", (projected_pace_in_seconds / 60).floor}:#{sprintf "%02d", ((projected_pace_in_seconds % 3600) % 60).round}"
        projected_result.update_attributes("net_time" => projected_time, "pace_per_mile" => projected_pace, "ag_percent" => best_result.ag_percent)

      else
        puts "Not found: #{runner_info['name']} "
        projected_result.update_attributes("team" => '---')
      end

      puts

      projected_result.save!
    end
  end

  def format_date(date_str)
    date = Date.strptime(date_str, '%m/%d/%y')
  end
end
