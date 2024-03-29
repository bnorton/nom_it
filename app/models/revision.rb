class Revision < ActiveRecord::Base
  
  CATEGORY = "primary_category,secondary_category"
  BASIC = "id,nid,updated_at,location_nid,#{CATEGORY},title,text,phone,url"
  
  belongs_to :user
  belongs_to :location

  scope :OL, lambda {|offset,limit|
    offset(offset).limit(limit)
  }
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
    "revisions.updated_at,revisions.location_nid,revisions.title,
     revisions.text,revisions.phone,revisions.url,
     revisions.primary_category,revisions.secondary_category"
  end
  
end


  # create_table "revisions", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.integer  "location_id",                           :null => false
  #   t.string   "primary_category"
  #   t.string   "secondary_category"
  #   t.integer  "user_id",                               :null => false
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
  #   t.string   "nid"
  # end