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
      Thumb.build_common(thumb)
    }
  end

  # an individual item such as a user or location
  def self.detail_for_nid(nid,lim=10,what=:user_nid)
    result = if(what == :user_nid)
      Thumb.for_nid(nid,lim).map{ |thumb|
        Thumb.build_common(thumb)
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
    Thumb.find(finder).limit(lim).sort([[:_id , -1]])
  end

  def self.build_common(thumb)
    thumb = Util.created_atify(thumb)
    thumb = Util.de_nid(thumb.as_json, '_id')
    user_nid = thumb.delete 'unid'
    thumb[:user] = User.for_nid(user_nid)
    location_nid = thumb.delete 'nid'
    thumb[:location] = Location.compact_detail_for_nid(location_nid)
    thumb
  end
end
