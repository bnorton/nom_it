class RankingAverage < MongoRuby
  
  #          | nom_id | average | count
  attr_accessor :nid,     :a,      :c
  
  def self.dbcollection
    "ranking_averages"
  end
  
  ## methods called from initializers/ratings.rb and are thus
  ##   defined into the mongo db instance.
  def self.add_new_rating
    collection.db.add_stored_function('new_rating', "function(feature_id,content_item_id,rating) {
      try {
        item = db.#{dbcollection}.findOne({f:feature_id,c:content_item_id});
        if (item == null) {
          db.#{dbcollection}.save({f:feature_id,c:content_item_id,t:1,r:rating});
        } else {
          item.r = item.r + (( rating - item.r) / ++item.t );
          db.#{dbcollection}.save(item); }
        return true;
      } catch (ex) {
        return false } }")
  end
  
  def self.add_update_rating
    collection.db.add_stored_function('update_rating', "function(feature_id,content_item_id,old_r,new_r) {
      try {
        item = db.#{dbcollection}.findOne({ f:feature_id,c:content_item_id });
        item.r = item.r + (( new_r - old_r ) / item.t);
        db.#{dbcollection}.save(item);
        return true;
      } catch (ex) {
        return false; } }")
  end
  
  ## methods that add new data
  def self.new_rating(feature_id,content_item_id,rating)
    collection.db.eval("new_rating(#{feature_id},#{content_item_id},#{rating})")
  end
  
  def self.update_rating(feature_id,content_item_id,old_r,new_r)
    collection.db.eval("update_rating(#{feature_id},#{content_item_id},#{old_r},#{new_r})")
  end
  
  ## methods that find ratings or totals
  def self.find_by_fid_cid(feature_id,content_item_id,key,options={})
    item = collection.db.eval("return db.#{dbcollection}.findOne({f:#{feature_id},c:#{content_item_id}})")
    return 0 if item.nil?
    options[:rating_total] ? [item['r'], item['t']] : item[key]
  end
  
  def self.rating(feature_id,content_item_id)
    find_by_fid_cid(feature_id,content_item_id,'r')
  end
  
  def self.total(feature_id,content_item_id)
    find_by_fid_cid(feature_id,content_item_id,'t')
  end
  
  def self.rating_total(feature_id,content_item_id)
    find_by_fid_cid(feature_id,content_item_id,'',{:rating_total=>true})
  end
end

