class Follower < ActiveRecord::Base
  
# for every user that ""I follow"" there will be an entry for my 'id' in the user column
# for every user that ""follows me"" there will be an entry for my 'id' in the to column
  
  IFOLLOW      = "to_user_id"   # the field that is needed when looking for users that I follow
  FOLLOWS_ME   = "user_id"
  SINGLE_TABLE = "id,nid,to_user_id,to_name,user_name,user_name,user_city,undirected,updated_at"
  
  belongs_to :user
  
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
    valid.where(["user_id in (?)",me.split(',')]) }
  scope :followers, lambda {|me|
    info.followers__(me) }
  scope :followers_ids, lambda {|me|
    iids.followers__(me) }
  
  scope :follows_id__, lambda {|id|
    valid.where(["to_user_id in (?)",id.split(',')]) }
  scope :follows_id, lambda {|id|
    info.follows_id__(id) }
  scope :follows_id_ids, lambda {|id|
    fids.follows_id__(id) }
  
  scope :find_by_me_them_who_ifollow, lambda {|me,them|
    valid.where(["user_id=? and to_user_id=?",me,them])
  }
  scope :find_by_me_them_follows_me, lambda {|me,them|
    valid.where(["to_user_id=? and user_id=?",me,them])
  }
  
  def self.find_or_create(id,their_identifier,items)
    options = {}
    other = User.find_by_any_means_necessary(their_identifier)
    if other.blank?
      other = User.create_should_join(items)
      options.merge!({:hasnt_joined=>true})
      return if other.blank?
    end
    Follower.new_follower(id,other,options)
  end
  
  private
  
  def self.new_follower(myid,other,options={})
    me = User.private_id(myid).try(:first)
    return if me.blank? || other.blank?
    my_name   = me.name || me.screen_name
    other_name= other.name || other.screen_name
    f = Follower.new_or_old(other.id)
    f.user_id      = me.id
    f.user_name    = my_name
    f.user_city    = me.city
    f.to_user_id   = other.id
    f.to_name      = other_name
    if options[:hasnt_joined]
      f.approved = false
    else
      f.approved = true
    end
    begin
      if f.save!
        flag = true
      end
    rescue ActiveRecord::RecordNotUnique
      flag = true
    end
    User.detail(other.id) if flag
  end
  
  def self.user_has_joined(to_id)
    return if (to = Follower.find_by_to_user_id(to_id)).blank?
    Array(to).each do |t|
      t.approved = true
      t.save!
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
    Follower.follows_id_ids(me.to_s)
  end
  
  def self.users_that_i_follow(me)
    return if me.blank?
    Follower.followers_ids(me.to_s)
  end
  
  def self.new_or_old(id)
    Follower.find_by_user_id(id) || Follower.new
  end
end

  # The schema for Follower
  # create_table "followers", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.integer  "user_id",                       :null => false
  #   t.string   "user_name"
  #   t.string   "user_city"
  #   t.integer  "to_user_id",                    :null => false
  #   t.string   "to_name"
  #   t.boolean  "approved",   :default => true,  :null => false
  #   t.boolean  "undirected", :default => false, :null => false
  #   t.binary   "schemaless"
  # end