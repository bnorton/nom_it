class Thumb < MongoRuby
  
  #          | nom_id | user_id | value
  attr_accessor :nid, :uid, :value
  
  def self.dbcollection
    "thumbs"
  end
  
  def self.add_new_thumb
    Thumb.store_function('new_thumb', "function( nid,uid,value ) {
      try { item = db.#{Thumb.dbcollection}.findOne({ nid:nid, uid:uid });
        if ( item == null ) {
          db.#{Thumb.dbcollection}.save({ nid:nid, uid:uid, value:value });
        } else {
          if (item.value == value) { return false; }
          item.value = value;
          db.#{Thumb.dbcollection}.save( item );
        }
      } catch ( ex ) { return false; }
      return true; }")
  end
    
  ## methods that add new data
  def self.new_thumb(nid,uid,value)
    nid = Util.STRINGify(nid)
    if Thumb.eval("new_thumb('#{nid}','#{uid}',#{value})")
      ThumbCount.update_thumb_count(nid,value)
    else
      false # dont need to update
    end
  end
  
  ## methods that find ratings or totals
  def self.for_uid(uid,lim=20)
    Thumb.find_by({ :uid => uid }, lim)
  end
  
  def self.detail_for_nid(nid,lim=10)
    result = []
    thumbs = Thumb.for_nid(nid,lim)
    while (thumb = thumbs.next).present?
      result << Util.nidify(thumb,:tid)
    end
    {
      :thumbs => result,
      :thumb_count => ThumbCount.for_nid(nid)
    }
  end
  
  private
  
  def self.for_nid(nid,lim=20)
    nid = Util.STRINGify(nid)
    Thumb.find_by({ :nid => nid }, lim)
  end

  def self.find_by(finder,lim)
    Thumb.find(finder).limit(lim)
  end
  
  def self.max_limit(lim)
    lim > 50 ? 50 : lim < 5 ? 5 : lim
  end
end
