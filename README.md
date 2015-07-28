##Rungraphs

See the live site at <a href="http://www.rungraphs.com" target=_blank>www.rungraphs.com</a>

This website makes searching for race results and runner times easy. Unlike searching on <a href="http://web2.nyrrc.org/cgi-bin/start.cgi/aes-programs/results/resultsarchive.htm" target=_blank>New York Road Runners</a> for the latest results, Rungraphs is easy to navigate. A runner can quickly find a race, filter by age group to see who won, filter by gender, see runners for only a specific team, as well as other filters and sorting.

The home page currently has links with commonly visited resources for runners. Posts with upcoming information and analytics will be added.

####Data
Race results were obtained from <a href="http://web2.nyrrc.org/cgi-bin/start.cgi/aes-programs/results/resultsarchive.htm" target=_blank>New York Road Runners</a> using Mechanize. (see *lib/tasks/nyrr.rake*).

As results are pulled, three types of objects are created: races, runners, and results. The models are structured so that it is easy to find all of a runner's results and races, find a race's results and runners, and find the race and runner a result belongs to.

The Team table was created in the console by finding all the teams from the *team* field in the runner table. Full team names are kept track of in *config/initializer/constant.rb*. That hash is used to populate full team names when available.

####Race and Runner Search
The Race and Runner models are searchable through Elasticsearch. See the models for the specific searches. The results are then combined and ranked for the user to choose.

####Race Results
Race results were displayed using Datatables.js with customizations to filter and sort. Asynchonrous requests are made by the datatable to only load the data currently being displayed on the table. See *show.html.erb* for races.

####Runner Stats
The runner *show* page displays a runner's info as well as a runner's races.

####Predicted Races
Predictions for future races are made by *projection.rake* by retrieving data from NYRR's <a href="http://liveresults.nyrr.org/" target=_blank>race tracker api</a> More details are here: <a href="https://github.com/loganyu/nyrr_scrape_race_roster " target=_blank>https://github.com/loganyu/nyrr_scrape_race_roster </a>. The runner names are compared with those in the database and using a runner's most recent team and races, a prediction is made for team performance.

####Team Records
The teams index page lists all teams within New York Road Runners. The show page for each team displays the teams best performances for each distance. SQL searches are used to find the best times for each distance.

####Todo
-	Use frontend JS framework
-	Refactor repeated code between races and projected_races
-   Runner stats pages will also display a runner's best performances in different distances
-   Race result pages will include stats and analysis. Such as course records, number of men and women, avg finish time, data visualizations showing mean and standard deviation by age and sex, yearly participation of specific races, yearly differences in weather, team particiation in races
-   A **Versus** tab to search for two runners and compare best times across various distances
-   A **Team Versus** tab to simulate a race between two teams
-   Team stats and analysis (number of runners, join date of each runner, changes in number of runners per race)
-   Display Options/Infinite scroll for race and team pages
-   change loading to load results on race show pages after rendering to speed up rendering when complete race results are added

####Testing
-   Unit tests will be created using RSpec, FactoryGirl, and Faker.
-   Behavioral tests will be created using Cucumber
