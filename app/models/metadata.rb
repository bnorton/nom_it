require 'mongo_ruby'

class Metadata < MongoRuby
  
  VALID_COUNTS = [:hrank, :hcount, :mrank, :mcount, :tmrank, :tmcount]
  VALID_YELP   = [:yelp_rating, :yelp_count]
  VALID_FSQ    = [:fsq_checkins, :fsq_users]
  
  #                    view_count | returned | up_count | meh_count | nom_rank | nom_rank_count | recommendations_count
  attr_accessor :_id, :views,      :ret,      :up,       :meh,       :rank,     :rank_ct,        :rec_ct
  #              h == half    m == mile  tm == two mile
  attr_accessor *VALID_COUNTS
  #              misc checkins and reviews
  attr_accessor *VALID_FSQ, *VALID_YELP
  
  def self.dbcollection
    "metadatas"
  end
  
  def self.create(nids)
    nids = [nids] unless nids.respond_to?(:each)
    nids.each do |nid|
      nid = Util.BSONify(nid)  # TODO figure out how to incur on fields that may not be there in the document
      Metadata.save({ :_id => nid, :views => 0, :ret => 0, :up => 0, :meh => 0,:rank => 0, :rank_c => 0, :rec_c => 0 })
    end
  end
  
  def self.find_by_nid(nid)
    nid = Util.BSONify(nid)
    meta = Metadata.find_one({ :_id => nid })
    Util.nidify(meta) unless meta.blank?
  end
  
  def self.set_attributes(attrs,valid_items)
    return false unless (nid = Util.BSONify(attrs[:nid])) 
    item = Metadata.for_nid(nid)
    attrs do |k,v|
      if valid_items.include?(k)
        item.k = v
      end
    end
    Metadata.save(item)
  end
  
  def self.set_region_counts(attrs)
    set_attributes(attrs,VALID_COUNTS)
  end
  
  def self.set_yelp_items(attrs)
    set_attributes(attrs,VALID_YELP)
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