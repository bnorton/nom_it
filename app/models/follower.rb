class Follower < ActiveRecord::Base
  
  IDS = "fromid"
  SINGLE_TABLE = "follower as id,follower_name as name,from_city as city,undirected"
  
  scope :ids_only, lambda {
    select(IDS)
  }
  scope :info, lambda {
    select(SINGLE_TABLE)
  }
  scope :followers, lambda {|from|
    where(["to=?",from])
  }
  scope :followers_ids, lambda {|from|
    ids_only.followers(from)
  }
  scope :my_followers, lambda {|me|
    info.followers(me)
  }
  
  def self.find_or_create(id,their_identifier,items)
    other = User.find_by_any_means_necessary(their_identifier)
    puts "OTHER #{other.inspect}"
    if other.blank?
      other = User.create_should_join(items)
      puts "OTHER@ #{other.inspect}"
      return false if other.blank? || other.try(:empty?)
      worked = Follower.new_follower(me.id,other)
      puts "did it work #{worked.inspect}"
      worked
    end
    other
  end
  
  private
  
  def self.new_follower(myid,other)
    me = User.find_by_id_or_email(myid)
    my_name    = me.name || me.screen_name
    other_name = other.name || other.screen_name
    nfollower  = Follower.new do |f|
      f.from      = me.id
      f.from_name = my_name
      f.from_city = me.city
      f.to        = other.id
      f.to_name   = other_name
    end
    if nfollower.save!
      nfollower
    end
  end
  
end

  # The schema for Follower
  # create_table "followers", :force => true do |t|
  # t.datetime "created_at"
  # t.datetime "updated_at"
  # t.integer  "from",                          :null => false
  # t.string   "from_name"
  # t.string   "from_city"
  # t.integer  "to",                            :null => false
  # t.string   "to_name"
  # t.boolean  "approved",   :default => true,  :null => false
  # t.boolean  "undirected", :default => false, :null => false
  # t.binary   "schemaless"
  # end