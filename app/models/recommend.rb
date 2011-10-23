class Recommend < ActiveRecord::Base
  scope :item, lambda { |id|
    Recommend.where(["id=?", id]) }
end