class Location < ActiveRecord::Base
  
  COMPACT = "name,revision,address,cross_street,street,city,state"
  
  scope :compact, lambda {
    Location.select(COMPACT)
  }
  scope :detail_for_id, lambda {|id| 
    detail_for_ids([id])
  }
  scope :detail_for_ids, lambda {|ids| 
    compact.where(["id in (?)", ids])
  }
  scope :find_by_name, lambda {|name|
    compact.where(["name like ?", "%#{name}%"])
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
  
  def self.parse_ids(search)
    locations = []
    search.each do |locid|
      locations << locid.location
    end
    locations.join(',')
  end
  
end

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
  #
  #
  
  
  