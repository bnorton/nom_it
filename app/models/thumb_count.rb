class ThumbCount < MongoRuby
  
  #          | nom_id | user_id | value
  attr_accessor :nid, :up, :meh
  
  def self.dbcollection
    "thumb_counts"
  end
  
  def self.up
    1
  end
  def self.meh
    2
  end
  
  def self.add_new_thumb_count
    ThumbCount.store_function("update_thumb_count", "function( nid, value ) {
      try { item = db.#{ThumbCount.dbcollection}.findOne({ _id:nid });
        if ( item == null ) {
          if (value == #{ThumbCount.up}) {
            db.#{ThumbCount.dbcollection}.save({ _id:nid, up:1, meh:0 });
          } else {
            db.#{ThumbCount.dbcollection}.save({ _id:nid, up:0, meh:1 });}
        } else {
          if (value == #{ThumbCount.up}) {
            ++item.up;
          } else {
            ++item.meh; }
          db.#{ThumbCount.dbcollection}.save( item ); }
      } catch ( ex ) { return false; }
      return true; }")
  end
    
  def self.update_thumb_count(nid,value)
    if value == ThumbCount.meh || value == ThumbCount.up
      if (nid = Util.BSONify(nid))
        if ThumbCount.eval("update_thumb_count('#{nid}',#{value})")
          Metadata.upped(nid) if value == ThumbCount.up
          return true
        end
      end
    end
    false
  end
  
  ## methods that find ratings or totals
  def self.find_by_nid(nid)
    if (nid = Util.BSONify(nid))
      item = ThumbCount.find_one({ :_id => nid })
      return {} if item.nil?
      { :up => item['up'], :meh => item['meh'], :_id => nid }
    else
      {}
    end
  end
  
end