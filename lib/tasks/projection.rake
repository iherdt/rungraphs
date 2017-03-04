# require 'rubygems'
# require 'mechanize'
# require 'open-uri'
# require 'json'

=begin

bundle exec rake projection:new["http://api.rtrt.me/events/NYRR-WASHINGTONHEIGHTS5K-2017/profiles","4d7a9ceb0be65b3cc4948ee9","DB46DA9BD41A9123CD26","3.1","Washington Heights 5k","March 5th 2017 9:00am","03/05/17"]


=end
namespace :projection do

  task :new, [:url, :apiid, :token, :distance, :name, :date_and_time, :date, :distance_string] => :environment do |t, arg|
    distance = arg[:distance]
    name = arg[:name]
    date_and_time = arg[:date_and_time]
    date = format_date(arg[:date])
    distance_string = arg[:distance_string]

    projected_race = ProjectedRace.create(name: name, date_and_time: date_and_time, distance: distance, date: date)
    create_new_result_projections(projected_race, arg[:url], arg[:apiid], arg[:token], distance_string)
    projected_race.save!
    projected_race.reload
    projected_race.set_team_results
  end

  def create_new_result_projections(projected_race, url, apiid, token, distance_string)
    url = url
    start = 1
    params = {
      max: "1000",
      total: "1",
      failonmax: "0",
      appid: apiid,
      token: token,
      search: "",
      source: "webtracker",
      start: start
    }

    puts "requesting runners from #{start} to #{start + 999}"
    response = RestClient.post url, params, :content_type => :json, :accept => :json
    json_roster_data = /{.+}/.match(response)[0]
    json_data_hash = JSON.parse(json_roster_data)
    roster_data = json_data_hash["list"]

    total = json_data_hash["info"]["total"].to_i
    puts "total runners: #{total}"

    loop do
      start += 1000
      break if start > total

      puts "requesting runners from #{start} to #{start + 999}"
      params[:start] = start
      response = RestClient.post url, params, :content_type => :json, :accept => :json
      json_roster_data = /{.+}/.match(response)[0]
      json_data_hash = JSON.parse(json_roster_data)
      roster_data.concat(json_data_hash["list"])
    end

    counter = 0

    puts "total results: #{roster_data.count}"
    roster_data.each do |runner_info|
      if !distance_string.blank?
        if runner_info['race'] != distance_string
          next
        end
      end
      
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

    if runner_info['fname'].nil? || runner_info['lname'].nil?
      puts "missing name for #{runner_info.inspect}"
      next
    end

    # add runner and projected time by team first
    runners = Runner.where(first_name: runner_info['fname'].downcase, last_name: runner_info['lname'].downcase, city: city).where.not(team: "0")

    if runners.empty?
      runners = Runner.where(first_name: runner_info['fname'].downcase, last_name: runner_info['lname'].downcase).where.not(team: "0")
    end

    if runners.empty?
      runners = Runner.where(first_name: runner_info['fname'].downcase, last_name: runner_info['lname'].downcase, city: city)
    end

    # if a runner changes cities or if runner with same name without city
    if runners.empty?
      runners = Runner.where(first_name: runner_info['fname'].downcase, last_name: runner_info['lname'].downcase).where.not(city: city)
    end

    if !runners.empty? && !runners[0].results.empty?
      runner = runners[0]

      projected_result.update_attributes("runner_id" => runner.id, "team" => runner.team, "state" => runner.state, "age" => Time.now.year - runner.birth_year)

      # exclude mile since AG not as accurate and check for AG% since 18 mile Tune Up does not have AG%
      best_result = runner.results.where.not(:ag_percent => nil).where("(distance != 1.0 AND distance != 0.2) AND date > ?", 6.months.ago).order('ag_percent DESC')[0]

      if best_result.nil?
        best_result = runner.results.where.not(:ag_percent => nil).where("(distance != 1.0 AND distance != 0.2) AND date > ?", 1.year.ago).order('ag_percent DESC')[0]
      end

      # if still no best time, find the most recent race that is not the mile or 18 miler
      if best_result.nil?
        best_result = runner.results.where.not(:ag_percent => nil).where("distance != 1.0 AND distance != 0.2").order('date DESC').first
      end

      # if still no best time, find the most recent race including the mile and 18 mile
      if best_result.nil?
        best_result = runner.results.order('date DESC').first
      end

      puts counter
      puts runner.full_name
      p best_result

      if best_result.nil?
        puts "No best result: #{runner_info['name']} "
        next
      end

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
      # calculate projected time with Riegel formula
      # http://www.runningforfitness.org/faq/rp
      # T2 = T1 x (D2/D1)1.06
      # this doesn't translate well for women so trying 3% instead of 6
      if runner.sex == "m"
        coefficient = 1.06
      else
        coefficient = 1.03
      end
      if projected_race.distance > best_result.distance
        projected_time_in_seconds = best_time_in_seconds * ((projected_race.distance / best_result.distance )**coefficient)
      else
        # T1 = T2 / (D2/D1)1.06
        projected_time_in_seconds = best_time_in_seconds / ((best_result.distance / projected_race.distance )**coefficient)
      end

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

