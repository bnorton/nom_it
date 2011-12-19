class Thumb < MongoRuby
  
  #          | nom_id | user_nid | value
  attr_accessor :nid, :unid, :value

  def self.dbcollection
    "thumbs"
  end

  def self.add_new_thumb
    Thumb.store_function('new_thumb', "function( nid,unid,value ) {
      diff = 0;
      try { item = db.#{Thumb.dbcollection}.findOne({ nid:nid, unid:unid });
        if ( item == null ) {
          db.#{Thumb.dbcollection}.save({ nid:nid, unid:unid, value:value });
        } else {
          if (item.value == value) { return -1; }
          diff = item.value;
          item.value = value;
          db.#{Thumb.dbcollection}.save( item );
        } } catch ( ex ) { ; }
      return diff; }")
  end

  def self.new_thumb(nid,unid,value)
    nid = Util.STRINGify(nid)
    return false unless (value = value.to_i) > 0
    if (old_value = Thumb.eval("new_thumb('#{nid}','#{unid}', #{value})")) != -1
      ThumbCount.update_thumb_count(nid,value,old_value)
    else
      false # dont need to update
    end
  end

  def self.for_unids(unid,lim=30)
    unid = [unid] unless unid.kind_of? Array
    Thumb.find_by({ :unid => {'$in' => unid }}, lim).map{|thumb|
      thumb = Thumb.build_location(thumb)
      thumb
    }
  end

  # an individual item such as a user or location
  def self.detail_for_nid(nid,lim=10,what=:user_nid)
    result = if(what == :user_nid)
      Thumb.for_nid(nid,lim).map{|thumb|
        thumb = Thumb.build_user(thumb)
        thumb
      }
    else
      Thumb.for_nid(nid,lim).map{|thumb|
        thumb = Thumb.build_location(thumb)
        thumb
      }
    end
    {
      :thumbs => result,
      :thumb_count => ThumbCount.for_nid(nid)
    }
  end

  private

  def self.for_nid(nid,lim=30)
    lim = Util.limit(lim,30)
    nid = Util.STRINGify(nid)
    Thumb.find_by({ :nid => nid }, lim)
  end

  def self.find_by(finder,lim=30)
    lim = Util.limit(lim,30)
    Thumb.find(finder).limit(lim)
  end

  def self.build_common(thumb)
    thumb = Util.created_atify(thumb)
    thumb = Util.de_nid(thumb.as_json, '_id')
    thumb
  end

  def self.build_user(thumb)
    thumb = Thumb.build_common(thumb)
    user_nid = thumb.delete 'unid'
    thumb[:user] = User.for_nid(user_nid)
    thumb
  end

  def self.build_location(thumb)
    thumb = Thumb.build_common(thumb)
    location_nid = thumb.delete 'nid'
    thumb[:location] = Location.compact_detail_for_nid(location_nid)
    thumb
  end

  def self.max_limit(lim)
    lim > 50 ? 50 : lim < 5 ? 5 : lim
  end
end
