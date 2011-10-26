class Comment
  include LightMongo::Document
  
  # recommendation id
  attr_accessor   :id, :user_id, :location_id, :text, :time, :hash
  
end