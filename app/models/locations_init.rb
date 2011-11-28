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
        :location_nid => nid1,
        :name => 'location name 1',
        :address => '14 darrell pl',
        :primary => cat1
      })
      Location.create({
        :location_nid => nid2,
        :name => 'location name 2',
        :address => '2670 parker st',
        :primary => cat2
      })
      Location.create({
        :location_nid => nid3,
        :name => 'location name 3',
        :address => '201 11th st',
        :primary => cat3
      })
      Geolocation.create({
        :location_nid => nid1,
        :primary => cat1,
        :lat => 33.3311,
        :lng => -122.2211
      })
      Geolocation.create({
        :location_nid => nid2,
        :primary => cat2,
        :lat => 33.3322,
        :lng => -122.2222
      })
      Geolocation.create({
        :location_nid => nid3,
        :primary => cat3,
        :lat => 33.3333,
        :lng => -122.2233
      })
      
      ThumbCount.update_thumb_count(nid1,2) # meh
      ThumbCount.update_thumb_count(nid2,2) # meh
      ThumbCount.update_thumb_count(nid3,1) # up
      
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
