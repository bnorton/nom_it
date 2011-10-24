class Follower < ActiveRecord::Base
  
  IDS = "follower"
  SINGLE_TABLE = "follower as id,follower_name as name,user_city as city,undirected"
  
  scope :ids_only, lambda {
    select(IDS) }
  scope :info, lambda {
    select(SINGLE_TABLE) }
  scope :followers, lambda {|from|
    where(["user=?",from]) }
  scope :followers_ids, lambda {|from|
    ids_only.followers(from) }
  scope :my_followers, lambda {|me|
    info.followers(me) }
  
  def self.find_or_create(id,their_identifier,items)
    other = User.find_by_any_means_necessary(their_identifier)
    if other.blank?
      joined = User.create_should_join(items)
      return false if joined.blank?
      Follower.new_follower(id,joined)
    else
      other
    end
  end
  
  private
  
  def self.new_follower(myid,other)
    me = User.private_id(myid).first
    return false if me.blank?
    my_name    = me.name || me.screen_name
    other_name = other.name || other.screen_name
    nfollower  = Follower.new do |f|
      f.user         = me.id
      f.user_name    = my_name
      f.user_city    = me.city
      f.follower     = other.id
      f.follower_name= other_name
    end
    if nfollower.save!
      User.detail(other.id)
    end
  end
  
end

  # The schema for Follower
  # create_table "followers", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.integer  "user",                             :null => false
  #   t.string   "user_name"
  #   t.string   "user_city"
  #   t.integer  "follower",                         :null => false
  #   t.string   "follower_name"
  #   t.boolean  "approved",      :default => true,  :null => false
  #   t.boolean  "undirected",    :default => false, :null => false
  #   t.binary   "schemaless"
  # end  
  
  