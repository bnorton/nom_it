class Location < ActiveRecord::Base
  
  COMPACT = "id,nid,name,revision,address,cross_street,street,city,state,fsq_id,gowalla_url"
  
  has_many :revisions
  has_many :images
  has_one  :geolocation
  has_one  :statistic
  
  scope :compact, lambda {
    Location.select(COMPACT)
  }
  scope :detail_for_id, lambda {|id| 
    detail_for_ids(id.to_s)
  }
  scope :detail_for_ids, lambda {|ids| 
    compact.where(["id in (?)", ids.split(',')])
  }
  scope :detail_for_nid, lambda {|nid| 
    fields = "#{Location.join_fields},#{Revision.join_fields}"
    puts "fields #{fields.inspect}"
    select(fields).joins(:revisions).where(["nid=?", nid])
  }
  scope :detail_for_nids, lambda {|nids| 
    fields = "#{Location.join_fields},#{Revision.join_fields}"
    select(fields).joins(:revisions).where(["nid in (?)", nids.join(',')])
  }
  scope :full_detail_for_ids, lambda {|ids| 
    fields = "#{Location.join_fields},#{Revision.join_fields}"
    select(fields).joins(:revisions).where(["locations.id in (?)", ids.join(',')])
  }
  scope :full_statistics_detail_for_ids, lambda {|ids|
    fields = "#{Location.join_fields},#{Revision.join_fields},#{Statistic.join_fields}"
    select(fields).joins(:revision).joins(:statistic).where(["locations.id in (?)", ids.join(',')])
  }
  scope :find_by_name, lambda {|name|
    compact.where(["name like ?","%#{name}%"])
  }
  scope :find_by_address_parts, lambda {|street,city|
    unless city.blank?
      compact.where(["street like ? and city like ?","%#{street}%","%#{city}%"])
    else
      compact.where(["street like ?","%#{street}%"])
    end
  }
  
  def self.details_from_search(search)
      locations = Location.parse_ids search
      details   = Location.detail_for_ids(locations)
    end
    
  def self.full_details_from_search(search)
    locations = Location.parse_ids search
    details   = Location.full_statistics_detail_for_ids(locations)
  end
  
  def self.parse_ids(search)
    locations = []
    search.each do |locid|
      locations << locid.location_id
    end
    locations.join(',')
  end
  
  def self.join_fields
    "locations.name,locations.revision,locations.address,locations.cross_street,
     locations.street,locations.city,locations.state,locations.fsq_id,locations.gowalla_url"
  end
end

  # create_table "locations", :force => true do |t|
  # create_table "locations", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.string   "name"
  #   t.integer  "revision",                                     :null => false
  #   t.string   "fsq_name"
  #   t.string   "fsq_id"
  #   t.string   "gowalla_url"
  #   t.string   "gowalla_name"
  #   t.string   "address"
  #   t.string   "cross_street"
  #   t.string   "street"
  #   t.string   "street2"
  #   t.string   "city"
  #   t.string   "state"
  #   t.string   "area_code",    :limit => 7
  #   t.string   "country"
  #   t.text     "json_encode"
  #   t.boolean  "is_new",                    :default => false, :null => false
  #   t.string   "code"
  #   t.binary   "schemaless"
  #   t.string   "primary"
  #   t.string   "secondary"
  #   t.string   "nid"
  # end
  #
  