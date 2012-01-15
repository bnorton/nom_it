class NomRank
  class << self
    
    def rank_v1
      @rank_type = 'v1'
      @process_by = 'percentile'
      rank
    end

    def rank_v2
      @rank_type = 'v2'
      @process_by = 'absolute'
      rank
    end

    private

    def rank
      puts "setup"; setup
      puts "pre_process"; pre_process
      puts "order"; order
      puts "process"; send(:"process_by_#{@process_by}")
      puts "post_process"; post_process
      true
    end

    def pre_process
      @locations = _next
      while @locations.present?
        @locations.each do |l|
          meta = Metadata.for_nid(l.location_nid)
          prepare_for_extract(meta)
          value = send(:"extract_features_#{@rank_type}", meta)
          @all_items << {:nid => l.location_nid, :value => value}
        end
        @locations = _next
      end
    end

    def order
      @all_items.sort!{|x,y| y[:value] <=> x[:value]}
    end

    def process_by_absolute
      value = 1
      length = @all_items.length
      @all_items.each_with_index do |item,i|
        nid = item[:nid]
        loc = Location.find_by_location_nid(nid)
        rank = "#{value}/#{length}"
        loc.rank = rank
        loc.rank_value = value
        loc.save
        if loc = Geolocation.find_by_location_nid(nid)
          loc.rank = rank
          loc.rank_value = value
          loc.save
        end
        value += 1
      end
    end

    def process_by_percentile
      stride = (@all_items.length / 1000.0).ceil
      stride = 1 unless stride > 0
      i = 0; value = 1
      while i < @all_items.length
        j = i; limit = j + stride
        per = 0
        while j < limit && j < @all_items.length
          nid = @all_items[j][:nid]
          loc = Location.find_by_location_nid(nid)
          loc.rank = value
          loc.save
          if loc = Geolocation.find_by_location_nid(nid)
            loc.rank = value
            loc.save
          end
          per += 1
          j += 1
        end
        value -= 1
        i = j
        puts "stride #{j/stride} done, per stride #{per}"
      end
    end

    def post_process
      
    end

    def prepare_for_extract(meta)
      @value = 0
      unless meta.blank?
        @yelp_count = meta['yelp_count'].to_f
        @yelp_rating = meta['yelp_rating'].to_f
        @fsq_users = meta['fsq_users'].to_f
        @fsq_checkins = meta['fsq_checkins'].to_f
        @fsq_tips = meta['fsq_tips'].to_f
      end
    end
    
    def extract_features_v1(meta)
      ## YELP ##########################################
      ## 4.5's should contribute a lot
      scale = 1 # no scale
      if @yelp_rating > 4.4
        scale = 2
      elsif @yelp_rating > 3.9
        scale = 1.5
      end
      ##################################################
      @value += @yelp_count * @yelp_rating * scale #####
      ##################################################
      
      ## FOURSQUARE ###################
      begin 
        ratio = fsq_checkins / fsq_users
        normalize = 0.25
        multiplier = 0.0001
        
        # when the ratio is higher you have more repeat business (complex popularity)
        if ratio > 2.9
          multiplier += 0.2
        end
        if ratio > 1.9 # 21 st amendment
          multiplier += 0.1
        end
        if ratio > 0.9
          multiplier += 0.1
        end
        
        if fsq_checkins > 10000
          normalize = 0.05
        elsif fsq_checkins > 5000
          normalize = 0.75
        end
        
        ##################################################
        value += (@fsq_checkins * multiplier * normalize)#
        ##################################################
        
        tips_factor = @fsq_tips * 7
        
        ##################################################
        value += tips_factor #############################
        ##################################################
        
      rescue Exception
      end
      value
    end

    def extract_features_v2(meta)
      #####################################################
      ## capture the value of transient users
      fsq_total = 0

      if @fsq_checkins && @fsq_users && @fsq_checkins > 0
        if @fsq_users / @fsq_checkins > 0.42
          fsq_total += @fsq_checkins * 0.15
        end
        if @fsq_users / @fsq_checkins > 0.21
          fsq_total += @fsq_checkins * 0.075
        end
        ###
        #####################################################
        ## capture the value of the repeat (local customer)
        if @fsq_users / @fsq_checkins < 0.42
          fsq_total += @fsq_checkins * 0.35
        end
        if @fsq_users / @fsq_checkins < 0.21
          fsq_total += @fsq_checkins * 0.175
        end
      end
      ###

      if @fsq_tips && @fsq_tips > 16
        fsq_total += 2 * @fsq_tips
      end
      if @fsq_tips && @fsq_tips > 32
        fsq_total += 4 * @fsq_tips
      end
      if @fsq_tips && @fsq_tips > 64
        fsq_total += 8 * @fsq_tips
      end
      # too high signals boredom
      if @fsq_tips &&  @fsq_tips > 128
        fsq_total += 2 * @fsq_tips
      end

      @value += fsq_total
    end

    def _next(lim=50)
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