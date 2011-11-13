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
  
  scope :followers__, lambda {|me|
    valid.where(["user_nid in (?)",me.split(',')]) }
  scope :followers, lambda {|me|
    info.followers__(me) }
  scope :followers_nids, lambda {|me|
    iids.followers__(me) }
  
  scope :follows_nid__, lambda {|nid|
    valid.where(["to_user_nid in (?)",nid.split(',')]) }
  scope :follows_nid, lambda {|nid|
    info.follows_nid__(nid) }
  scope :follows_nid_nids, lambda {|nid|
    fids.follows_nid__(nid) }
  
  scope :find_by_me_them_who_ifollow, lambda {|me,them|
    valid.where(["user_nid=? and to_user_nid=?",me,them])
  }
  scope :find_by_me_them_follows_me, lambda {|me,them|
    valid.where(["to_user_nid=? and user_nid=?",me,them])
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
  
  def self.new_follower(mynid,other,options={})
    me = User.private_nid(mynid).try(:first)
    return false if me.blank? || other.blank?
    my_name   = me.name || me.screen_name
    other_name= other.name || other.screen_name
    f = Follower.new_or_old(mynid,other.nid)
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
  
  def self.unfollow(me,them)
    them     = User.find_by_any_means_necessary(them)
    follower = Follower.find_by_me_them_who_ifollow(me,them.try(:nid))
    return false if follower.blank? || them.blank?
    follower.delete!
  end
  
  def self.block_follower(me,them)
    me = Util.STRINGify(me)
    them = Util.STRINGify(them)
    them     = User.find_by_any_means_necessary(them)
    follower = Follower.find_by_me_them_follows_me(me,them.try(:nid))
    return false if follower.blank? || them.blank?
    follower.approved = false
    follower.save!
  end
  
  def self.users_that_follow_me(me)
    return [] if me.blank?
    me = Util.STRINGify(me)
    Follower.follows_nid_nids(me)
  end
  
  def self.users_that_i_follow(me)
    return [] if me.blank?
    me = Util.STRINGify(me)
    Follower.followers_nids(me)
  end
  
  def self.new_or_old(mynid,othernid)
    mynid = Util.STRINGify(mynid)
    othernid = Util.STRINGify(mynid)
    Follower.find_by_me_them_follows_me(mynid,othernid).try(:first) || Follower.new
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
