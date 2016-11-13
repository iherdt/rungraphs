namespace :nyrr do

  MARATHON_RESULT_PROPERTIES = {
  "Last Name" => "last_name",
  "First Name" => "first_name",
  "Bib" => "bib",
  "Team" => "team",
  "City" => "city",
  "State" => "state",
  "Country" => "country",
  "Place" => "overall_place",
  "GenderPlace" => "gender_place",
  "AgePlace" => "age_place",
  "FinishTime" => "finish_time",
  "PaceperMile" => "pace_per_mile",
  "Minutesper Mile" => "pace_per_mile",
  "AGTime" => "ag_time",
  "Age-GradedTime" => "ag_time",
  "AGGenderPlace" => "ag_gender_place",
  "AG %" => "ag_percent",
  "Age-GradedPerformance %" => "ag_percent",
  "NetTime" => "net_time",
  "GunTime" => "gun_time",
  "5 km" => "split_5km",
  "10 km" => "split_10km",
  "15 km" => "split_15km",
  "20 km" => "split_20km",
  "13.1 mi" => "split_131m",
  "25 km" => "split_25km",
  "30 km" => "split_30km",
  "35 km" => "split_35km",
  "40 km" => "split_40km"
  }

  $a = Mechanize.new

  # when scraping old race results, start from most recent to least recent to set teams to the most recent team
  task :marathon_results, [:year, :month, :day] => :environment do |t, arg|
    all_results_page = "http://web2.nyrrc.org/cgi-bin/start.cgi/mar-programs/archive/archive_search.html"
    marathon_results_page = get_marathon_results_page(all_results_page, arg[:year])
    date = Date.new(arg[:year].to_i, arg[:month].to_i, arg[:day].to_i)
    scrape_marathon_results(marathon_results_page, arg[:year], date)
  end

  def get_marathon_results_page(all_results_page, year)
    $a.get(all_results_page).form_with(:method => "POST") do |f|
      f["input.searchyear"] = "2015"
      f["input.f.age"] = "0"
      f["input.t.age"] = "99"
      f.radiobutton_with(:value => "search.age").check
    end.click_button
  end

  def scrape_marathon_results(marathon_results_page, year, date)
    
    puts "---------Scraping NYC Marathon #{year}---------"

    begin
      race = Race.new
      race.name = "NYC Marathon #{year}"
      race.date = date
      race.distance = 26.2

      race.save!

      scrape_marathon_individual_page(marathon_results_page, race, date)
      race.set_team_results
    rescue => e
      puts "error creating new race #{race.name} #{e.inspect}"
      race.destroy
    end
  end

  def get_marathon_rows(marathon_results_page)
    return marathon_results_page.parser.xpath("//table[@cellpadding='2'][@cellspacing='1'][@border='0'][@bgcolor='#C0C0C0']/tr")
  end

  def scrape_marathon_individual_page(marathon_results_page, race, date)
    i = 0

    loop do
      i += 1
      puts "--------------------------scraping page #{i}------------------------------"
      rows = get_marathon_rows(marathon_results_page)
      race_fields_array = []
      rows[0].css('td').each do |i|
        race_fields_array << i.text
      end


      # remove separate method because of stack problems with large races
      # scrape_result_rows(rows, race, race_fields_array)
      rows.shift
      rows.each do |row|
        result = Result.new(distance: 26.2, date: date)
        data_array = []
        index = 0
        first_field = true
        row.css('td').each do |field|
          property = MARATHON_RESULT_PROPERTIES[race_fields_array[index]]
          if race_fields_array[index] == " Sex/Age"
            if !field.text.empty?
              result.update_attributes("sex" => field.text[0].downcase)
              result.update_attributes("age" => field.text[1..2].to_i)
            end
          elsif race_fields_array[index] == "Country ofResidence/Citizenship"
            if !field.text.empty?
              if first_field
                result.update_attributes("residence" => field.text[0].downcase)
                first_field = false
              else
                result.update_attributes("country" => field.text[1..2].to_i)
                first_field = true
              end
            end
          # if time field is missing a leading zero, add it here so sorting will work
          elsif ["net_time", "finish_time", "gun_time", "ag_time"].include? property
            if field.text =~ /^\d\d:\d\d$/
              result.update_attributes(property => "0:" + field.text)
            else
              result.update_attributes(property => field.text)
            end
          elsif property
            if !field.text.empty?
              result.update_attributes(property => field.text.downcase)
            end
          end
          if first_field == true
            index += 1
          end
        end

        next if !race.results.where(overall_place: result.overall_place).empty?

        if result.team.blank?
          result.team = 0
        end

        # find or create team
        team = Team.where(name: result.team)
        if team.empty?
          Team.create(name: result.team)
        end

        #create or find runner
        if result.age
          birth_year = race.date.year - result.age
        else
          birth_year = ""
        end
        
        runners = Runner.where(first_name: result.first_name, last_name: result.last_name)

        if runners.empty?
          result_runner = Runner.create(
            first_name: result.first_name,
            last_name: result.last_name,
            birth_year: birth_year,
            team: result.team,
            sex: result.sex,
            full_name: "#{result.first_name} #{result.last_name}",
            city: result.city,
            state: result.state,
            country: result.country
          )
        else
          found = false

          # commented out to assume runner with same name is the same runner

          runners.each do |runner|
            if runner.birth_year && runner.birth_year.between?(birth_year - 1, birth_year + 1)
              result_runner = runner
              found = true
              break
            end
          end

          if not found
            result_runner = Runner.create(
              first_name: result.first_name,
              last_name: result.last_name,
              birth_year: birth_year,
              team: result.team,
              sex: result.sex,
              full_name: "#{result.first_name} #{result.last_name}",
              city: result.city,
              state: result.state,
              country: result.country
            )
          end
        end

        result_runner.save!

        result.update_attributes("runner_id" => result_runner.id)
        result.update_attributes("race_id" => race.id)
        result.save!
        puts "#{race.name} - #{result.overall_place}: #{result.first_name} #{result.last_name}"
      end

      # # if there is a next button, click and add those results too
      next_100_link = marathon_results_page.forms.last.button_with(:value => /Next 100/)

      # break unless next_100_link
      break if next_100_link.nil?

      marathon_results_page = $a.click(next_100_link)
    end
  end
end
