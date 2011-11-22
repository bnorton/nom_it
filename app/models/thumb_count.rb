class ThumbCount < MongoRuby
  
  #          | nom_id | up | meh
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
  
  private
  
  def self.update_thumb_count(nid,value)
    if value == ThumbCount.meh || value == ThumbCount.up
      if (nid = Util.STRINGify(nid))
        if ThumbCount.eval("update_thumb_count('#{nid}',#{value})")
          Metadata.upped(nid) if value == ThumbCount.up
          Metadata.mehed(nid) if value == ThumbCount.meh
          return true
        end
      end
    end
    false
  end
  
  ## methods that find ratings or totals
  def self.for_nid(nid)
    nid = Util.STRINGify(nid)
    item = ThumbCount.find_one({ :_id => nid })
    return { :up => 0, :meh => 0 } if item.nil?
    { :up => item['up'], :meh => item['meh'] }
  end
  
end