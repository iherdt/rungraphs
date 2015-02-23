# require 'rubygems'
# require 'mechanize'
# require 'open-uri'
# require 'json'

namespace :nyrr do

  RESULT_PROPERTIES = {
  "Last Name" => "last_name",
  "First Name" => "first_name",
  "Bib" => "bib",
  "Team" => "team",
  "City" => "city",
  "State" => "state",
  "Country" => "country",
  "OverallPlace" => "overall_place",
  "GenderPlace" => "gender_place",
  "AgePlace" => "age_place",
  "FinishTime" => "finish_time",
  "PaceperMile" => "pace_per_mile",
  "AGTime" => "ag_time",
  "AGGenderPlace" => "ag_gender_place",
  "AG %" => "ag_percent",
  "NetTime" => "net_time"
  }

  CLUB_POINTS = {
    "2014" => [1, 27, 37, 38, 41, 46, 48, 51, 57, 60],
    "2013" => [1, 14, 17, 20, 23, 29, 32, 37, 45, 48],
    "2012" => [4, 11, 16, 21, 23, 25, 31, 35, 41, 45],
    "2011" => [4, 17, 19, 23, 26, 30, 33, 39, 44],
    "2010" => [4, 16, 21, 26, 29, 35, 41, 47, 52],
    "2009" => [4, 18, 22, 28, 29, 31, 32, 38, 41, 46, 47]
  }

  $a = Mechanize.new

  task :results, [:year] => :environment do |t, arg|
    all_results_page = "http://web2.nyrrc.org/cgi-bin/start.cgi/aes-programs/results/resultsarchive.htm"
    yearly_results_page = get_yearly_results_page(all_results_page, arg[:year])
    scrape_yearly_results(yearly_results_page, arg[:year])
  end

  def get_yearly_results_page(all_results_page, year)
    $a.get(all_results_page).form_with(:name => "findOtherRaces") do |f|
      f["NYRRYEAR"] = year
    end.click_button
  end

  def scrape_yearly_results(yearly_results_page, year)
    puts "----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}----#{year}"
    race_links = get_race_links(yearly_results_page)
    race_dates = get_race_dates(yearly_results_page)
    race_links.count.times do |i|
      # only including club points races because of size limits
      # next if !CLUB_POINTS[year].include? i
      scrape_individual_race_results(race_links[i], race_dates[i], year)
    end
  end

  def scrape_individual_race_results(link, date, year)
    # click on individual race result page
    race_results_cover_page = $a.click(link)
    puts "Scraping #{date} #{link.text}"

    if race_results_cover_page.form.nil? || race_results_cover_page.form.radiobutton_with(:value => /500/).nil?
      puts "    ****Failed. Improper result form."
      return
    end

    # fill in form with 'Finishers in order' => 'All' and 'Maximum' => '500'
    race_results_page = race_results_cover_page.form do |f|
      f.radiobutton_with(:value => /500/).check
    end.click_button

    # cannot scrape data if format is different
    if get_rows(race_results_page).empty?
      puts "    ****Failed. Improper table format."
      return
    end

    race = Race.new
    race.name = link.text
    race.date = format_date(date)

    scrape_race_info(race_results_page, race)
    race.save!

    scrape_race_individual_page(race_results_page, race.id, race.date.year)
  end

  def get_race_links(yearly_results_page)
    yearly_results_page.links.select{|link| link.href.match(/result.id=/)}
  end

  def get_race_dates(yearly_results_page)
    yearly_results_page.parser.xpath("//td[b]/p").text.split(/\r|\n/).reject{|el| el.strip.empty?}.map{|el| el[-8..-1]}
  end

  def get_rows(race_results_page)
    race_results_page.parser.xpath("//table[@cellpadding='3'][@cellspacing='0'][@border='1'][@bordercolor='#DDDDDD'][@style='border-collapse:collapse; border-color:#DDD']/tr")
  end

  def scrape_race_individual_page(race_results_page, race_id, race_year)
    puts "scraping page"


    rows = get_rows(race_results_page)
    race_fields_array = []
    rows[0].css('td').each do |i|
      race_fields_array << i.text
    end
    scrape_result_rows(rows, race_id, race_year, race_fields_array)

    # for now, limit to first 500 for each race because of cost of production

    # # if there is a next button, click and add those results too
    next_500_link = race_results_page.parser.xpath("//a[text()='NEXT 500']")[0]
    if next_500_link
      next_race_results_page = $a.click(next_500_link)
      scrape_race_individual_page(next_race_results_page, race_id, race_year)
    end
  end

  def scrape_result_rows(rows, race_id, race_year, race_fields_array)
    rows.shift
    rows.each do |row|
      result = Result.new
      data_array = []
      row.css('td').each_with_index do |field, index|
        property = RESULT_PROPERTIES[race_fields_array[index]]
        if property
          result.update_attributes(property => field.text.downcase)
        elsif race_fields_array[index] == "Sex/Age"
          result.update_attributes("sex" => field.text[0])
          result.update_attributes("age" => field.text[1..2].to_i)
        end
      end
      result.save

      #create or find runner
      birth_year = race_year - result.age
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

        # runners.each do |runner|
        #   if runner.birth_year.between? birth_year - 1, birth_year + 1
        #     result_runner = runner
        #     found = true
        #     break
        #   end
        # end

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
      result.update_attributes("race_id" => race_id)
      result.save!
    end
  end

  def scrape_race_info(race_results_page, race)
    race_info = race_results_page.parser.xpath("//span[@class='text']")[0]
    race_info_clean = race_info.text.split(/\r/).reject(&:empty?).join(';')
    attributes = {}

    attributes["distance"] = /Distance:\D*(\d?\.?\d+\D*\d?\.*\d+).*?(?:;|$)/
    attributes["date_and_time"] = /Date\/Time:\W*(.*?)(?:;|$)/
    attributes["location"] = /Location:\W*(.+?)(?:;|$)/
    attributes["weather"]  = /Weather:\W*(.*?)(?:;|$)/
    attributes["temperature"] = /(\d{1,3})\s?(?:d|D|f|F)/
    attributes["humidity"] = /(\d\d)%/
    attributes["sponsor"] = /Sponsor:\W*(.*?)(?:;|$)/
    attributes.each do |attribute, regex|
      if race_info_clean.match regex
        if "distance" == attribute
          race.update_attributes(attribute => race_info_clean.match(regex).captures[0].to_f)
        elsif ["temperature", "humidity"].include? attribute
          race.update_attributes(attribute => race_info_clean.match(regex).captures[0].to_i)
        else
          race.update_attributes(attribute => race_info_clean.match(regex).captures[0])
        end
      end
    end
  end

  def format_date(date_str)
    date = Date.strptime(date_str, '%m/%d/%y')
  end
end
