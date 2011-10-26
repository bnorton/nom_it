class Follower < ActiveRecord::Base
  
# for every user that ""I follow"" there will be an entry for my 'id' in the user column
# for every user that ""follows me"" there will be an entry for my 'id' in the to column
  
  IFOLLOW      = "to_user"   # the field that is needed when looking for users that I follow
  FOLLOWS_ME   = "user"
  SINGLE_TABLE = "to_user,to_name,user,user_name,user_city,undirected"
  
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
  
  scope :valid, lambda {
    where(["approved=1"])
  }
  
  scope :followers__, lambda {|me|
    valid.where(["user in (?)",me.split(',')]) }
  scope :followers, lambda {|me|
    info.followers__(me) }
  scope :followers_ids, lambda {|me|
    iids.followers__(me) }
  
  scope :follows_id__, lambda {|id|
    valid.where(["to_user in (?)",id.split(',')]) }
  scope :follows_id, lambda {|id|
    info.follows_id__(id) }
  scope :follows_id_ids, lambda {|id|
    fids.follows_id__(id) }
  
  scope :find_by_me_them_who_ifollow, lambda {|me,them|
    valid.where(["user=? and to_user=?",me,them])
  }
  scope :find_by_me_them_follows_me, lambda {|me,them|
    valid.where(["to_user=? and user=?",me,them])
  }
  
  def self.find_or_create(id,their_identifier,items)
    other = User.find_by_any_means_necessary(their_identifier)
    if other.blank?
      other = User.create_should_join(items)
      return false if other.blank?
    end
    newf = Follower.new_follower(id,other.first)
    newf
  end
  
  private
  
  def self.new_follower(myid,other)
    me = User.private_id(myid).try(:first)
    return false if me.blank? || other.blank?
    my_name    = me.name || me.screen_name
    other_name = other.name || other.screen_name
    nfollower  = Follower.new do |f|
      f.user         = me.id
      f.user_name    = my_name
      f.user_city    = me.city
      f.to_user      = other.id
      f.to_name      = other_name
    end
    begin
      if nfollower.save!
        raise "OK"
      end
    rescue ActiveRecord::RecordNotUnique, "OK"
      User.detail(other.id)
    end
  end
  
  def self.unfollow(me,them)
    them     = User.find_by_any_means_necessary(them)
    follower = Follower.find_by_me_them_who_ifollow(me,them.try(:id))
    return false if follower.blank? || them.blank?
    follower.delete!
  end
  
  def self.block_follower(me,them)
    them     = User.find_by_any_means_necessary(them)
    follower = Follower.find_by_me_them_follows_me(me,them.try(:id))
    return false if follower.blank? || them.blank?
    follower.approved = false
    follower.save!
  end
  
  def self.users_that_follow_me(me)
    return if me.blank?
    Follower.follows_id_ids(me)
  end
  
end

  # The schema for Follower
  # create_table "followers", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.integer  "user",                             :null => false
  #   t.string   "user_name"
  #   t.string   "user_city"
  #   t.integer  "to",                         :null => false
  #   t.string   "to_name"
  #   t.boolean  "approved",      :default => true,  :null => false
  #   t.boolean  "undirected",    :default => false, :null => false
  #   t.binary   "schemaless"
  # end  
  
  