class NomRank
  class << self
    
    def rank
      puts "setup"
      setup
      puts "pre_process"
      pre_process
      puts "order"
      order
      puts "process"
      process
      puts "post_process"
      post_process
      puts "done #{@all_items.inspect}"
      true
    end

    def pre_process
      @locations = NomRank.next
      while @locations.present?
        @locations.each do |l|
          meta = Metadata.for_nid(l.nid)
          value = NomRank.extract_features(meta)
          @all_items << {:nid => l.nid, :value => value}
        end
        @locations = NomRank.next
      end
    end

    def order
      @all_items.sort!{|x,y| y[:value] <=> x[:value]}
    end

    def process
      stride = (@all_items.length / 100.0).ceil
      stride = 1 unless stride > 0
      i = 0; value = 100
      while i < @all_items.length
        j = i; limit = j + stride
        while j < limit && j < @all_items.length
          nid = @all_items[j][:nid]
          loc = Location.find_by_nid(nid)
          loc.rank = value
          loc.save
          loc = Geolocation.find_by_location_nid(nid)
          loc.rank = value
          loc.save
          j += 1
        end
        value -= 1
        i = j
        puts "stride #{j/stride} done"
      end
    end

    def post_process
      
    end

    def extract_features(meta)
      value = 0
      
      ## YELP #########################
      yelp_count = meta['yelp_count']
      yelp_rating = meta['yelp_rating']
      
      ##################################################
      value += yelp_count * yelp_rating ################
      ##################################################
      
      ## FOURSQUARE ###################
      begin 
        fsq_users = meta['fsq_users']
        fsq_checkins = meta['fsq_checkins']
        ratio = fsq_checkins / fsq_users
        normalize = 0.25
        multiplier = 1.0
        
        # when the ratio is higher you have more repeat business (complex popularity)
        if ratio > 2.9
          multiplier += 0.4
        end
        if ratio > 1.9 # 21 st amendment
          multiplier += 0.3
        end
        if ratio > 0.9
          multiplier += 0.2
        end
        
        if fsq_checkins > 10000
          normalize = 0.1
        elsif fsq_checkins > 5000
          normalize = 0.2
        end
        
        ##################################################
        value += (fsq_checkins * multiplier * normalize) #
        ##################################################
      rescue Exception
      end
      value
    end

    def next(lim=50)
      all = Location.limit(50).offset(@offset).find(:all)
      @offset += 50
      all
    end

    def setup
      @offset = 0
      @all_values = []
      @all_items = []
    end
    
  end
end