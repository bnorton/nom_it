class Image < ActiveRecord::Base
  
  COMPACT = "id,nid,link,created_at,description"
  
  belongs_to :location
  belongs_to :user  ####### NEED TO CHANGE UID TO USER_ID to match htis relationship
  
  scope :valid_only, lambda { where(["is_valid=1"]) }
  scope :for_location, lambda {|id|
    Image.select(COMPACT).valid_only.where(["location=?",id])
  }
  
  
end

  # The schema for the Image model
  # create_table "images", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.string   "link"
  #   t.integer  "uid",                            :null => false
  #   t.integer  "location_nid",                    :null => false
  #   t.string   "name"
  #   t.integer  "size"
  #   t.integer  "width"
  #   t.integer  "height"
  #   t.text     "metadata"
  #   t.string   "description"
  #   t.boolean  "is_valid",    :default => false, :null => false
  #   t.binary   "schemaless"
  #   t.string   "nid"
  # end
  