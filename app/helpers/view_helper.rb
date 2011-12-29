module ViewHelper
  def nom_project_itunes_url
    "http://itunes.apple.com/us/app/nom-project/id488587906?ls=1&mt=8"
  end

  def nom_itunes_url
   "http://itunes.apple.com/us/app/nom/id463401211?ls=1&mt=8"
 end

 def nom_locations_api_example
   "https://justnom.it/locations/here.json?lat=37.7969398498535&lng=-122.399559020996"
 end

 def nom_activities_api_example
   "https://justnom.it/activities.json?user_nid=4eccc0fbeef0a64dcf000001"
 end

 def nom_search_api_example
   "https://justnom.it/locations/search.json?lng=-122.3898&lat=37.81273&query=sushi"
 end
end