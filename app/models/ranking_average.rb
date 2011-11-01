class RankingAverage < MongoRuby
  
  #          | nom_id | average | count
  attr_accessor :nid,     :a,      :c
  
  def self.dbcollection
    "ranking_averages"
  end
  
  ## methods called from initializers/ratings.rb and are thus
  ##   defined into the mongo db instance.
  def self.add_new_ranking
    collection.db.add_stored_function('new_rating', "function(nid,rating) {
      try { item = db.#{dbcollection}.findOne({ nid:nid });
        if ( item == null ) {
          db.#{dbcollection}.save({ nid:nid, c:1, r:rating });
        } else {
          item.r = item.r + (( rating - item.r) / ++item.c );
          db.#{dbcollection}.save( item ); }
        return true;
      } catch ( ex ) {
        return false; } }")
  end
  
  def self.add_update_ranking
    collection.db.add_stored_function('update_rating', "function(nid,old_r,new_r) {
      try {
        item = db.#{dbcollection}.findOne({ nid:nid });
        item.r = item.r + (( new_r - old_r ) / item.c);
        db.#{dbcollection}.save( item );
        return true;
      } catch ( ex ) {
        return false; } }")
  end
  
  ## methods that add new data
  def self.new_ranking(nid,rating)
    collection.db.eval("new_ranking(#{nid},#{rating})")
  end
  
  def self.update_ranking(nid,old_r,new_r)
    collection.db.eval("update_ranking(#{nid},#{old_r},#{new_r})")
  end
  
  ## methods that find ratings or totals
  def self.find_by_nid(nid,key,options={})
    item = RankingAverage.find_one({ :nid => nid })
    return 0 if item.nil?
    options[:total] ? [item['r'], item['c']] : item[key]
  end
  
  def self.ranking(nid)
    find_by_nid(nid,'r')
  end
  
  def self.total(nid)
    find_by_nid(nid,'c')
  end
  
  def self.ranking_total(nid)
    find_by_nid(nid,'',{:total=>true})
  end
end

