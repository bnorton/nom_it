class RankingAverage < MongoRuby
  
  #          | nom_id | average | count
  attr_accessor :nid,     :a,      :c
  
  def self.dbcollection
    "ranking_averages"
  end
  
  def self.max
    5
  end
  
  def self.min
    1
  end
  
  ## methods called from initializers/mongo_stored_functions.rb
  ##    and are thus defined into the mongo db instance.
  def self.add_new_ranking
    RankingAverage.store_function('new_average_rank', "function( nid,rating ) {
      try { item = db.#{RankingAverage.dbcollection}.findOne({ nid:nid });
        if ( item == null ) {
          db.#{RankingAverage.dbcollection}.save({ nid:nid, c:1, a:rating });
          return true;
        } else {
          item.a = item.a + (( rating - item.a) / ++item.c );
          db.#{RankingAverage.dbcollection}.save( item ); }
        return true;
      } catch ( ex ) { return false; } }")
  end
  
  def self.add_update_ranking
    RankingAverage.store_function('update_average_rank', "function( nid,old_r,new_r ) {
      try {
        item = db.#{RankingAverage.dbcollection}.findOne({ nid:nid });
        item.a = item.a + (( new_r - old_r ) / item.c);
        db.#{RankingAverage.dbcollection}.save( item );
        return true;
      } catch ( ex ) { return false; } }")
  end
  
  def self.add_remove_ranking
    MongoRuby.store_function("remove_average_rank","function( nid,old_r ) {
      try {
        item = db.#{RankingAverage.dbcollection}.findOne({ nid:nid });
        item.a = item.a - (( old_r ) / item.c);
        db.#{RankingAverage.dbcollection}.save( item );
        return true;
      } catch ( ex ) { return false; }
    }")
  end
  
  ## methods that add new data
  def self.new_ranking(nid,rating)
    RankingAverage.eval("new_average_rank('#{nid}',#{rating})")
  end

  def self.update_ranking(nid,old_r,new_r)
    old_r = self.valid(old_r); new_r = self.valid(new_r)
    RankingAverage.eval("update_average_rank('#{nid}',#{old_r},#{new_r})")
  end

  def self.remove_ranking(nid,old_value)
    old_value = self.valid(old_value)
    RankingAverage.eval("remove_average_rank('#{nid}',#{old_value})")
  end

  def self.ranking(nid)
    Rails.cache.fetch("ranking_average_ranking_#{nid}", :expires_in => 10.minutes) do
      RankingAverage.for_location_nid(nid,key='a')
    end
  end

  def self.total(nid)
    Rails.cache.fetch("ranking_average_total_#{nid}", :expires_in => 10.minutes) do
      RankingAverage.for_location_nid(nid,key='c')
    end
  end

  def self.ranking_total(nid)
    Rails.cache.fetch("ranking_average_ranking_total_#{nid}", :expires_in => 10.minutes) do
      RankingAverage.for_location_nid(nid,nil,options={:total=>true})
    end
  end

  private

    ## methods that find ratings or totals
  def self.for_location_nid(nid,key='',options={})
    item = RankingAverage.find_one({ :nid => nid })
    return {} if item.nil?
    return {:average => item['a'], :total => item['c']} if options[:total]
    tkey = key == 'a' ? :average : :total
    return { tkey => item[key] }
  end

  def self.valid(value)
    value = self.max if value > self.max
    value = self.min if value < self.min
    value.to_f
  end

end

