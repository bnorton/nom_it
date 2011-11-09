class LocationsInit
  class << self
    def init
      cat1 = Category.find_or_create_by_name('food')
      cat2 = Category.find_or_create_by_name('eat')
      cat3 = Category.find_or_create_by_primary_and_secordary(cat1,'sushi')
      
      nid1 = Util.ID
      nid2 = Util.ID
      nid3 = Util.ID
      
      Location.create({
        :nid => nid1,
        :name => 'location name 1',
        :address => '14 darrell pl',
        :primary => cat1})
        
      Location.create({
        :nid => nid2,
        :name => 'location name 2',
        :address => '2670 parker st',
        :primary => cat2})
      
      Location.create({
        :nid => nid3,
        :name => 'location name 3',
        :address => '201 11th st',
        :primary => cat3})
        
      id1 = Location.find_by_nid(nid1)['id']
      id2 = Location.find_by_nid(nid2)['id']
      id3 = Location.find_by_nid(nid3)['id']
      
      Geolocation.create({
        :location_id => id1,
        :primary => cat1,
        :lat => 33.3311,
        :lng => -122.2211,
        :nid => nid1
      })
      Geolocation.create({
        :location_id => id2,
        :primary => cat2,
        :lat => 33.3322,
        :lng => -122.2222,
        :nid => nid2
      })
      Geolocation.create({:location_id => id3, :primary => cat3,:lat => 33.3333,:lng => -122.2233,:nid => nid3})
      
      
      ThumbCount.update_thumb_count(nid1,2) # up
      ThumbCount.update_thumb_count(nid2,2) # up
      ThumbCount.update_thumb_count(nid3,1) # meh
      
      Metadata.create([nid1,nid2,nid3])
      
      Metadata.viewed(nid1); Metadata.viewed(nid1); Metadata.viewed(nid1)
      Metadata.viewed(nid2);
      Metadata.viewed(nid3); Metadata.viewed(nid3)
      
      Metadata.upped(nid1)
      Metadata.upped(nid2)
      Metadata.upped(nid3); Metadata.upped(nid3)
      
      Metadata.mehed(nid1)
      Metadata.mehed(nid2)
      Metadata.mehed(nid3); Metadata.mehed(nid3)

      Metadata.ranked(nid1); Metadata.ranked(nid1)
      Metadata.ranked(nid2); Metadata.ranked(nid2); Metadata.ranked(nid2)

    end
  end
end


  # The schema for the geolocations model
  # create_table "geolocations", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.integer  "location_id",                  :null => false
  #   t.float    "lat",         :default => 0.0
  #   t.float    "lng",         :default => 0.0
  #   t.string   "nid"
  # end
  
  # create_table "locations", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.string   "name"
  #   t.string   "fsq_name"
  #   t.string   "fsq_id"
  #   t.string   "gowalla_url"
  #   t.string   "gowalla_name"
  #   t.string   "address"
  #   t.string   "cross_street"
  #   t.string   "street"
  #   t.string   "street2"
  #   t.string   "city"
  #   t.string   "state"
  #   t.string   "area_code",     :limit => 7
  #   t.string   "country"
  #   t.text     "json_encode"
  #   t.boolean  "is_new",                     :default => false, :null => false
  #   t.string   "code"
  #   t.binary   "schemaless"
  #   t.string   "primary"
  #   t.string   "secondary"
  #   t.string   "nid"
  #   t.string   "hash"
  #   t.string   "yid"
  #   t.string   "woeid"
  #   t.string   "neighborhoods"
  #   t.string   "url"
  #   t.string   "revision_id"
  #   t.string   "twitter"
  #   t.string   "facebook"
  #   t.string   "phone"
  #   t.string   "cost"
  #   t.string   "timeofday"
  #   t.string   "metadata_id"
  # end