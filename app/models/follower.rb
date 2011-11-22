class Follower < ActiveRecord::Base
  
# for every user that ""I follow"" there will be an entry for my 'id' in the user column
# for every user that ""follows me"" there will be an entry for my 'id' in the to column
  
  FOLLOW_FIELDS = "to_user_nid,to_name,user_nid,user_name,user_city,undirected"   # the field that is needed when looking for users that I follow
  belongs_to :user
  
  ##  follower_3
  ##      ^                       follower_3 is followed by me
  ##     |                        follower_2 is undirected to me
  ##   ----  <---> follower_2     follower_1 is ALSO undirected to me
  ##  | me | <---> follower_1
  ##   ----
  ##
  scope :OL, lambda {|offset,limit|
    offset(offset).limit(limit)
  }
  scope :fields, lambda {
    select(FOLLOW_FIELDS) 
  }
  scope :valid, lambda {
    where(["`approved`=1"])
  }

  def self.find_or_create(nid,their_identifier,items)
    options = {}
    other = User.find_by_any_means_necessary(their_identifier)
    if other.blank?
      other = User.create_should_join(items)
      return if other.blank?
      options.merge!({ :hasnt_joined => true })
    end
    Follower.new_follower(nid,other,options)
  end

  def self.followers(user_nid,start=0,limit=50)
    start,limit = Util.ensure_limit(start,limit)
    return [] if user_nid.blank?
    user_nid = Util.STRINGify(user_nid)
    Follower.fields.valid.OL(start,limit).find_all_by_to_user_nid(user_nid)
  end

  def self.following(user_nid,start=0,limit=50)
    start,limit = Util.ensure_limit(start,limit)
    return [] if user_nid.blank?
    user_nid = Util.STRINGify(user_nid)
    Follower.fields.valid.OL(start,limit).find_all_by_user_nid(user_nid)
  end

  private
  
  def self.new_follower(user_nid,other,options={})
    me = User.private_nid(user_nid).try(:first)
    return false if me.blank? || other.blank?
    my_name = me.name || me.screen_name
    other_name = other.name || other.screen_name
    f = Follower.new_or_old(user_nid,other.nid)
    f.user_nid = me.nid
    f.user_name = my_name
    f.user_city = me.city
    f.to_user_nid = other.nid
    f.to_name = other_name
    if options[:hasnt_joined]
      f.approved = false
    else
      f.approved = true
    end
    f.save
    User.for_nid(other.nid)
  end
  
  def self.user_has_joined(to_nid)
    return if (to = Follower.find_by_to_user_nid(to_nid)).blank?
    Array(to).each do |t|
      t.approved = true
      t.save
    end
  end
  
  # user_nid is following to_user_nid
  def self.unfollow(user_nid,to_user_nid)
    to_user_nid     = User.find_by_any_means_necessary(to_user_nid)
    follower = Follower.find_by_user_nid_and_to_user_nid(user_nid,to_user_nid.nid)
    return false if follower.blank? || to_user_nid.blank?
    follower.delete!
  end
  
  def self.block_follower(user_nid,to_user_nid)
    user_nid = Util.STRINGify(user_nid)
    to_user_nid = Util.STRINGify(to_user_nid)
    to_user_nid = User.find_by_any_means_necessary(to_user_nid).nid
    follower = fields.find_by_to_user_nid_and_user_nid(user_nid,to_user_nid)
    return false if follower.blank? || to_user_nid.blank?
    follower.approved = false
    follower.save
  end
  
  def self.for_user_nid(user_nid,start=0,limit=20)
    {
      :followers => Follower.OL(start,limit).find_all_by_to_user_nid(user_nid),
      :following => Follower.OL(start,limit).find_all_by_user_nid(user_nid)
    }
  end
  
  def self.new_or_old(user_nid,to_user_nid)
    user_nid = Util.STRINGify(user_nid)
    to_user_nid = Util.STRINGify(to_user_nid)
    Follower.fields.valid.find_by_user_nid_and_to_user_nid(user_nid,to_user_nid) || Follower.new
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
