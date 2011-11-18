class Follower < ActiveRecord::Base
  
# for every user that ""I follow"" there will be an entry for my 'id' in the user column
# for every user that ""follows me"" there will be an entry for my 'id' in the to column
  
  IFOLLOW      = "to_user_nid"   # the field that is needed when looking for users that I follow
  FOLLOWS_ME   = "user_nid"
  SINGLE_TABLE = "id,to_user_nid,to_name,user_nid,user_name,user_city,undirected,updated_at"
  
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
  
  scope :followers__, lambda {|user_nid|
    valid.where(["user_nid in (?)",user_nid.split(',')]) }
  scope :followers, lambda {|user_nid|
    info.followers__(user_nid) }
  scope :followers_nids, lambda {|user_nid|
    iids.followers__(user_nid) }
  
  scope :follows_nid__, lambda {|nid|
    valid.where(["to_user_nid in (?)",nid.split(',')]) }
  scope :follows_nid, lambda {|nid|
    info.follows_nid__(nid) }
  scope :follows_nid_nids, lambda {|nid|
    fids.follows_nid__(nid) }
  
  scope :find_by_me_them_who_ifollow, lambda {|user_nid,to_user_nid|
    valid.where(["user_nid=? and to_user_nid=?",user_nid,to_user_nid])
  }
  scope :find_by_me_them_follows_me, lambda {|user_nid,to_user_nid|
    valid.where(["to_user_nid=? and user_nid=?",user_nid,to_user_nid])
  }
  
  def self.find_or_create(nid,their_identifier,items)
    options = {}
    other = User.find_by_any_means_necessary(their_identifier)
    if other.blank?
      other = User.create_should_join(items)
      options.merge!({:hasnt_joined=>true})
      return if other.blank?
    end
    Follower.new_follower(nid,other,options)
  end
  
  private
  
  def self.new_follower(user_nid,other,options={})
    me = User.private_nid(user_nid).try(:first)
    return false if me.blank? || other.blank?
    my_name   = me.name || me.screen_name
    other_name= other.name || other.screen_name
    f = Follower.new_or_old(user_nid,other.nid)
    f.user_nid      = me.nid
    f.user_name    = my_name
    f.user_city    = me.city
    f.to_user_nid   = other.nid
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
    User.detail(other.nid) if flag
  end
  
  def self.user_has_joined(to_nid)
    return if (to = Follower.find_by_to_user_nid(to_nid)).blank?
    Array(to).each do |t|
      t.approved = true
      t.save!
    end
  end
  
  def self.unfollow(user_nid,to_user_nid)
    to_user_nid     = User.find_by_any_means_necessary(to_user_nid)
    follower = Follower.find_by_me_them_who_ifollow(user_nid,to_user_nid.try(:nid))
    return false if follower.blank? || to_user_nid.blank?
    follower.delete!
  end
  
  def self.block_follower(user_nid,to_user_nid)
    user_nid = Util.STRINGify(user_nid)
    to_user_nid = Util.STRINGify(to_user_nid)
    to_user_nid = User.find_by_any_means_necessary(to_user_nid)
    follower = Follower.find_by_me_them_follows_me(user_nid,to_user_nid.try(:nid))
    return false if follower.blank? || to_user_nid.blank?
    follower.approved = false
    follower.save!
  end
  
  def self.users_that_follow_me(user_nid)
    return [] if user_nid.blank?
    user_nid = Util.STRINGify(user_nid)
    Follower.follows_nid_nids(user_nid)
  end
  
  def self.users_that_i_follow(user_nid)
    return [] if user_nid.blank?
    user_nid = Util.STRINGify(user_nid)
    Follower.followers_nids(user_nid)
  end
  
  def self.new_or_old(user_nid,to_user_nid)
    user_nid = Util.STRINGify(user_nid)
    to_user_nid = Util.STRINGify(user_nid)
    Follower.find_by_me_them_follows_me(user_nid,to_user_nid).first || Follower.new
  end
end

  # The schema for Follower
  # create_table "followers", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.integer  "user_nid",                       :null => false
  #   t.string   "user_name"
  #   t.string   "user_city"
  #   t.integer  "to_user_nid",                    :null => false
  #   t.string   "to_name"
  #   t.boolean  "approved",    :default => true,  :null => false
  #   t.boolean  "undirected",  :default => false, :null => false
  #   t.binary   "schemaless"
  # end
