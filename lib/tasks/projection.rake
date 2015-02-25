# require 'rubygems'
# require 'mechanize'
require 'open-uri'
# require 'json'

=begin

rake projection:new['http://api.rtrt.me/events/NYRR-WASHINGTONHEIGHTS5K-2015/profiles?max=10000&total=1&appid=4d7a9ceb0be65b3cc4948ee9&token=b0976a5c7c82e1de4563de76ddc72601&search=&callback=jcb8&func=na&parms=%7B%22browser%22%3Afalse%7D&settings=%7B%22setWait%22%3Afalse%7D&_=1424658974485',3.1,'Washington Heights 5k 2015','March 1st 2015 9:00am']

ProjectedRace.first.projected_results.order("net_time").each_with_index {|r,i| puts "#{i+1}\t#{r.sex}\t#{r.team}\t#{r.net_time}\t#{r.full_name}"}

=end
namespace :projection do

  task :new, [:roster_link, :distance, :name,:date_and_time] => :environment do |t, arg|
    roster_link = arg[:roster_link]
    distance = arg[:distance]
    name = arg[:name]
    date_and_time = arg[:date_and_time]

    projected_race = ProjectedRace.create(name: name, date_and_time: date_and_time, distance: distance)
    create_new_result_projections(projected_race, roster_link)
    # add_overall_places_to_projected_runners(projected_race)
    # add_gender_places_to_projected_runners()
    # add_age_group_places_to_projected_runners()
  end

  def create_new_result_projections(projected_race, roster_link)
    roster_data = open(roster_link).read
    json_roster_data = /{.+}/.match(roster_data)[0]
    roster_data_hash = JSON.parse(json_roster_data)

    roster_data_hash['list'].each do |runner_info|
      next if projected_race.runners.any? do |runner|
        runner.first_name == runner_info['fname'] &&
        runner.last_name == runner_info['lname'] &&
        runner.city == runner_info['city']
      end
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

      # add runner and projected time
      runners = Runner.where(first_name: runner_info['fname'].downcase, last_name: runner_info['lname'].downcase)
      if !runners.empty? && !runners[0].results.empty?
        runner = runners[0]
        p runner

        projected_result.update_attributes("runner_id" => runner.id, "team" => runner.team, "state" => runner.state, "age" => Time.now.year - runner.birth_year)

        # TODO, limit best to races within the last year
        # exclude mile since AG not as accurate and check for AG% since 18 mile Tune Up does not have AG%
        best_result = runner.results.where.not(ag_percent: nil, distance: 1.0).where("date" < "?", 1.year.ago).where("date > ?", 1.year.ago).order('ag_percent DESC')[0]
        p best_result

        # if runner has no times with ag%, choose the best pace
        if best_result.nil?
          best_result = runner.results.order('pace_per_mile DESC')[0]
        end

        # calculate projected time
        # T2 = T1 x (D2/D1)1.06
        best_time = DateTime.parse(best_result.net_time)
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
        projected_result.update_attributes("team" => 'UNK')
      end

      puts

      projected_result.save!
    end
  end

  def add_overall_places_to_projected_runners(projected_race)
    projected_race.projected_results.order('net_time').each_with_index do |result, i|
      result.overall_place = i + 1
      result.save!
    end
  end

  def add_gender_places_to_projected_runners()

  end


  def add_age_group_places_to_projected_runners()
  end
end
