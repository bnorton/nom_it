class Revision < ActiveRecord::Base
  
  CATEGORY = "primary_category,secondary_category"
  BASIC = "updated_at,location_id,#{CATEGORY},title,text,phone,url"
  
  has_one :user
  has_one :location
  
  scope :basic, lambda {
    select(BASIC)
  }
  scope :detail, lambda {|ids|
    where(["id in (?)",ids])
  }  
  scope :compact_detail, lambda {|ids|
    compact.detail(ids)
  }
  
  def self.detail(ids,lim=20)
    locations = compact_detail.limit(lim)
    return false if locations.blank?
    locations
  end
  
  def self.join_fields
    "revisions.updated_at,revisions.location_id,revisions.title,
     revisions.text,revisions.phone,revisions.url,
     revisions.primary_category,revisions.secondary_category
    "
  end
  
end


  # create_table "revisions", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.integer  "location",                              :null => false
  #   t.string   "primary_category"
  #   t.string   "secondary_category"
  #   t.integer  "uid",                                   :null => false
  #   t.string   "title"
  #   t.text     "text"
  #   t.text     "best"
  #   t.text     "meh"
  #   t.string   "comment"
  #   t.boolean  "deleted",            :default => false, :null => false
  #   t.string   "hours"
  #   t.string   "phone"
  #   t.string   "twitter"
  #   t.string   "neighborhoods"
  #   t.string   "url"
  #   t.integer  "walkability"
  #   t.binary   "schemaless"
  # end
