class User < ActiveRecord::Base
  
  has_many :revisions
  has_many :followers
  has_many :images
  has_many :recommendations
  
  scope :public_fields, lambda {
    select(User.fields)
  }
  scope :private_fields, lambda {
    select(User.fields(:private))
  }
  scope :private_id, lambda {|id|
    private_fields.where(["id=?",id])
  }
  scope :me, lambda {|token|
    private_fields.where(["session_id=?",token])
  }
  scope :has_joined, lambda {
    where(["has_joined=1"])
  }
  scope :hasnt_joined, lambda {
    where(["has_joined=0"])
  }
  scope :find_by_id_or_email, lambda {|id|
    public_fields.where(["id=? or email=?", id, id]).has_joined
  }
  scope :login_with_id_or_email, lambda {|i|
    select("salt,password").where(["id=? or email=?",i,i]).has_joined
  }
  scope :find_by_any_means, lambda {|id|
    items = [id,id,id,id,id]
    public_fields.where(["id=? or screen_name=? or email=? or facebook=? or twitter=?",*items])
  }
  scope :find_by_not_yet_joined, lambda {|identifier|
    find_by_any_means(identifier).hasnt_joined
  }
  scope :detail, lambda {|id|
    find_by_id_or_email(id)
  }
  scope :detail_for_ids, lambda {|ids|
    public_fields.where(["id in (?)", ids.split(',')])
  }
  scope :find_by_name, lambda {|name|
    public_fields.where(["name like ?", "%#{name}%"]).has_joined
  }
  scope :find_by_username, lambda {|username|
    public_fields.where(["screen_name=?", username]).has_joined
  }
  scope :search_by_all, lambda {|query|
    items = ["%#{query}%",query,query]
    public_fields.where(["name like ? or email=? or screen_name=?", *items]).has_joined
  }
  
  def self.token_match?(id, token)
    begin
      id == me(token).id
    rescue Exception
      false
    end
  end
  
  def self.find_by_any_means_necessary(id)
    user = User.find_by_any_means(id).has_joined
    user.first unless user.blank?
  end
  
  def self.login(id_or_email,password,vname='')
    unless id_or_email.blank?
      user = User.login_with_id_or_email(id_or_email).first
      if user && user.password == Digest::SHA2.hexdigest(user[:salt] + password)
        user.session_id = Digest::SHA2.hexdigest(rand(1<<16).to_s)
        user.last_seen  = Time.now
        return true if user.save!
      end
    end
  end
  
  def self.register(email, pass, username)
    user = new_or_hasnt_joined(email)
    user.email    = email
    user.salt     = rand(1<<32).to_s
    user.password = Digest::SHA2.hexdigest(user[:salt] + pass, 256)
    user.last_seen= Time.now
    user.has_joined= true
    user.screen_name=username
    user.nid      = Util.ID
    begin
      user.save!
    rescue ActiveRecord::RecordNotUnique
    end
    User.find_by_email(email)
  end
  
  def self.register_with_facebook(fbHash,username='')
    user = new_or_hasnt_joined(fbHash['id'])
    user.screen_name = username
    user.facebook = fbHash['id']
    user.name     = fbHash['name']
    user.token    = email_token
    user.url      = "https://graph.facebook.com/#{user.facebook}/picture"
    user.last_seen= Time.now
    location      = fbHash['locaton']
    user.city, user.state = Util.parse_location(location)
    user.token_expires = Time.now + 14.days
    user.has_joined= true
    user.save!
  end
  
  def self.register_with_twitter(twHash,username='',email='')
    user = new_or_hasnt_joined(twHash['id'])
    user.screen_name = username
    user.email    = email
    user.twitter  = twHash['id']
    user.name     = twHash['name']
    user.url      = twHash['profile_image_url']
    user.token    = email_token
    user.last_seen= Time.now
    user.city, user.state = Util.parse_location(twHash['location'])
    user.token_expires = Time.now + 14.days
    user.has_joined= true
    user.save!
  end
    
  def self.new_or_hasnt_joined(identifier)
    user = User.find_by_not_yet_joined(identifier).try(:first)
    if user.blank?
      user = User.find_by_email(identifier)
      if user.blank?
        user = User.new
      end
    else
      Follower.user_has_joined(user.id)
    end
    user
  end
  
  def self.create_should_join(items)
    user = User.new
    user.email        = items[:email]
    user.twitter      = items[:twid]
    user.facebook     = items[:fbid]
    token = email_token
    user.token        = token
    user.token_expires= email_token_expires
    user.nid          = Util.ID
    ## - warning   #####################################################
    ## - make sure that we know this is not a valid user as they      ##
    ##    are here because someone followed them via some identifier  ##
    user.has_joined = false                                           ##
    ## end warning #####################################################
    if user.save!
      User.find_by_token(token)
    end
  end
  
  def self.email_token(email=rand(1<<16).to_s)
    Digest::SHA2.hexdigest(email.to_s + Time.now.to_s, 256)
  end
  
  def self.email_token_expires
    Time.now + 14.days
  end
  
  def self.fields(opt=:public)
    fields = "id,nid,name,last_seen,city,screen_name,follower_count,description,created_at"
    if opt == :private
      fields << ",street,country,email,phone,facebook,twitter"
    end
    fields
  end
  
end


  # create_table "users", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.string   "name"
  #   t.string   "facebook"
  #   t.string   "twitter"
  #   t.string   "google"
  #   t.string   "last_seen"
  #   t.string   "udid"
  #   t.string   "url"
  #   t.string   "street"
  #   t.string   "city"
  #   t.string   "state"
  #   t.string   "zip"
  #   t.string   "country"
  #   t.string   "password",                       :default => ""
  #   t.string   "salt"
  #   t.string   "session_id"
  #   t.binary   "newpassword",    :limit => 255
  #   t.datetime "newpass_time"
  #   t.string   "email"
  #   t.string   "phone"
  #   t.string   "screen_name"
  #   t.text     "description"
  #   t.datetime "authenticated"
  #   t.string   "token"
  #   t.date     "token_expires"
  #   t.string   "referral_code",  :limit => 32
  #   t.string   "referred_by",    :limit => 32
  #   t.binary   "schemaless"
  #   t.string   "json_encode",    :limit => 1022
  #   t.integer  "follower_count"
  #   t.string   "oauth_token"
  #   t.string   "oauth_secret"
  #   t.binary   "facebook_hash"
  #   t.binary   "twitter_hash"
  #   t.boolean  "has_joined",                     :default => true
  # end  
  # what is returned from a twitter session
#   [
# 
#     {
#         "profile_sidebar_fill_color": "DDEEF6",
#         "protected": false,
#         "url": "http://www.gatesfoundation.org",
#         "statuses_count": 40,
#         "name": "Melinda Gates",
#         "show_all_inline_media": false,
#         "contributors_enabled": false,
#         "following": false,
#         "profile_sidebar_border_color": "C0DEED",
#         "default_profile_image": false,
#         "utc_offset": -28800,
#         "profile_image_url": "http://a1.twimg.com/profile_images/1533264126/NF232847_normal.jpg",
#         "description": "Co-chair of the Bill & Melinda Gates Foundation, businesswoman, and mother. Dedicated to helping all people lead healthy, productive lives.",
#         "verified": true,
#         "profile_use_background_image": true,
#         "time_zone": "Pacific Time (US & Canada)",
#         "created_at": "Thu Jul 01 20:32:42 +0000 2010",
#         "screen_name": "melindagates",
#         "is_translator": false,
#         "default_profile": false,
#         "profile_background_image_url_https": "https://si0.twimg.com/profile_background_images/326652473/Melinda_Twitter-bkgrd.jpg",
#         "profile_text_color": "333333",
#         "status": {
#             "retweet_count": 38,
#             "in_reply_to_status_id": null,
#             "favorited": false,
#             "geo": null,
#             "activities": {
#                 "repliers_count": "1",
#                 "retweeters_count": "3",
#                 "retweeters": [
#                     390155905,
#                     270566532,
#                     84014340
#                 ],
#                 "favoriters": [ ],
#                 "favoriters_count": "0",
#                 "repliers": [
#                     232161022
#                 ]
#             },
#             "coordinates": null,
#             "in_reply_to_screen_name": null,
#             "truncated": false,
#             "retweeted": false,
#             "created_at": "Wed Oct 19 00:43:52 +0000 2011",
#             "in_reply_to_status_id_str": null,
#             "in_reply_to_user_id_str": null,
#             "id_str": "126458509389856768",
#             "contributors": null,
#             "source": "<a href=\"http://cotweet.com/?utm_source=sp1\" rel=\"nofollow\">CoTweet</a>",
#             "place": null,
#             "in_reply_to_user_id": null,
#             "id": 126458509389856770,
#             "text": "Great to see all the pieces coming together at once today at the #malaria forum. We really are one community working hard to #endmalaria."
#         },
#         "follow_request_sent": false,
#         "geo_enabled": false,
#         "notifications": false,
#         "profile_background_image_url": "http://a2.twimg.com/profile_background_images/326652473/Melinda_Twitter-bkgrd.jpg",
#         "favourites_count": 0,
#         "friends_count": 137,
#         "id_str": "161801527",
#         "profile_link_color": "0084B4",
#         "followers_count": 32294,
#         "lang": "en",
#         "profile_image_url_https": "https://si0.twimg.com/profile_images/1533264126/NF232847_normal.jpg",
#         "profile_background_color": "C0DEED",
#         "location": "Seattle, WA",
#         "id": 161801527,
#         "listed_count": 519,
#         "profile_background_tile": false
#     }
# 
# ]
#
#
