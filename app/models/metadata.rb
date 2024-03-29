require 'mongo_ruby'

class Metadata < MongoRuby
  
  VALID_YELP = [:yelp_rating,:yelp_count,:categories]
  VALID_COUNTS = [:hrank, :hcount, :mrank, :mcount, :tmrank, :tmcount]
  VALID_FSQ = [:fsq_checkins, :fsq_users, :fsq_tips, :fsq_categories]
  
  #                    view_count | returned | up_count | meh_count | nom_rank | nom_rank_count | recommendations_count
  attr_accessor :_id, :views,      :ret,      :up,       :meh,       :rank,     :rank_ct,        :rec_ct
  #              h == half    m == mile  tm == two mile
  attr_accessor :hrank, :hcount, :mrank, :mcount, :tmrank, :tmcount
  #              misc checkins and reviews
  attr_accessor :fsq_checkins, :fsq_users, :fsq_tips
  attr_accessor :yelp_rating, :yelp_count
  
  def self.dbcollection
    "metadatas"
  end
  
  def self.create(nids)
    nids = Array(nids)
    nids.each do |nid|
      unless (Metadata.for_nid(nid))
        Metadata.save({ :_id => nid, :views => 1, :ret => 0, :up => 0, :meh => 0,:rank => 0, :rank_c => 0, :rec_c => 0 })
      end
    end
  end
  
  def self.for_nid(nid)
    Rails.cache.fetch("metadata_for_nid_#{nid}", :expires_in => 10.minutes) do
      meta = Metadata.find_one({ :_id => nid })
      Util.nidify(meta,:location_nid) unless meta.blank?
    end
  end

  def self.update_attributes(attribs,valid_items)
    return false unless (nid = attribs[:location_nid])
    item = Metadata.find_one({ :_id => nid })
    if attribs.keys.present?
      attribs.keys.each do |k|
        if valid_items.include?(k) || valid_items.include?(k.to_sym)
          item[k] = attribs[k]
        end
      end
      Metadata.save(item)
    end
  end
  
  def self.set_region_counts(attribs)
    return false unless attribs[:location_nid]
    Metadata.update_attributes(attribs,VALID_COUNTS)
  end
  
  def self.set_yelp_items(attribs)
    return false unless attribs[:location_nid]
    Metadata.update_attributes(attribs,VALID_YELP)
  end
  
  def self.viewed(nid,by=1)
    by = Metadata.gt_zero(by)
    Metadata.incr(nid,:views,by)
  end
  
  def self.returned(nid)
    Metadata.incr(nid,:ret)
  end
  
  def self.upped(nid)
    Metadata.incr(nid,:up)
  end
  
  def self.mehed(nid)
    Metadata.incr(nid,:meh)
  end
  
  def self.ranked(nid)
    Metadata.incr(nid,:rank_ct)
  end
  
  def self.recommended(nid)
    Metadata.incr(nid,:rec_ct)
  end
  
  def self.new_fsq_checkins(nid,checkins)
    Metadata.set(nid,:fsqcheckins,checkins)
  end
  
  def self.new_fsq_users(nid,users)
    Metadata.set(nid,:fsqusers,users)
  end
  
  def self.gt_zero(chk)
    chk < 1 ? 1 : chk
  end
  
end