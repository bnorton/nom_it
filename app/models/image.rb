class Image < ActiveRecord::Base
  
  COMPACT = "link,created_at,description"
  
  has_one :location
  has_one :user
  
  scope :for_location, lambda {|id|
    Image.select(COMPACT).valid_only.where(["location=?",id])
  }
  
  scope :valid_only, lambda { where(["is_valid=1"]) }
end


  # create_table "images", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.string   "link"
  #   t.integer  "uid",                            :null => false
  #   t.integer  "location",                       :null => false
  #   t.string   "name"
  #   t.integer  "size"
  #   t.integer  "width"
  #   t.integer  "height"
  #   t.text     "metadata"
  #   t.string   "description"
  #   t.boolean  "is_valid",    :default => false, :null => false
  #   t.binary   "schemaless"
  # end
  #
  #
  