class Follower < ActiveRecord::Base
  
  IFOLLOW      = "follower"
  FOLLOWS_ME   = "user"
  SINGLE_TABLE = "follower,follower_name,user,user_name,user_city,undirected"
  
  ##  follower_3
  ##      ^                       follower_3 is followed by me
  ##     |                        follower_2 is undirected to me
  ##   ----  <---> follower_2     follower_1 is ALSO undirected to me
  ##  | me | <---> follower_1
  ##   ----
  ##
  scope :iids, lambda {
    select(IFOLLOW) }
  scope :fids, lambda {
    select(FOLLOWS_ME) }
  scope :info, lambda {
    select(SINGLE_TABLE) }
  
  scope :followers__, lambda {|me|
    where(["user in (?)",me.split(',')]) }
  scope :followers, lambda {|me|
    info.followers__(me) }
  scope :followers_ids, lambda {|me|
    iids.followers__(me) }
  
  scope :follows_id__, lambda {|id|
    where(["follower in (?)",id.split(',')]) }
  scope :follows_id, lambda {|id|
    info.follows_id__(id) }
  scope :follows_id_ids, lambda {|id|
    fids.follows_id__(id) }
  
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
  
  