class User < ActiveRecord::Base
  
  has_many :followers
  has_many :images
  has_many :recommendations
  
  scope :OL, lambda {|offset,limit|
    offset(offset).limit(limit)
  }
  scope :follower_fields, lambda {
    select("user_nid,name,image_url,city,screen_name,facebook,follower_count,created_at,updated_at")
  }
  scope :public_fields, lambda {
    select(User.fields)
  }
  scope :private_fields, lambda {
    select(User.fields(:private))
  }
  scope :private_nid, lambda {|nid|
    private_fields.where(["user_nid=?",nid])
  }
  scope :me, lambda {|token|
    private_fields.where(["auth_token=?",token])
  }
  scope :has_joined, lambda {
    where(["has_joined=1"])
  }
  scope :hasnt_joined, lambda {
    where(["has_joined=0"])
  }
  scope :find_by_nid_or_email, lambda {|nid|
    public_fields.where(["user_nid=? or email=?", nid, nid]).has_joined
  }
  scope :find_by_email_or_screen_name, lambda {|e,s|
    private_fields.where(["email=? or screen_name=?",e,s])
  }
  scope :login_with_nid_or_email, lambda {|nid|
    select("salt,password").where(["user_nid=? or email=?",nid,nid]).has_joined
  }
  scope :login_with_email_or_screen_name, lambda {|email,sn|
    select("salt,password").where(["email=? or screen_name=?",email,sn]).has_joined
  }
  scope :find_by_any_means, lambda {|id|
    items = [id,id,id,id.to_s,id]
    where(["user_nid=? or screen_name=? or email=? or facebook=? or twitter=?",*items])
  }
  scope :find_by_not_yet_joined, lambda {|identifier|
    public_fields.find_by_any_means(identifier).hasnt_joined
  }
  scope :detail_for_nids, lambda {|nids,lim|
    public_fields.where(["user_nid in (?)", nids.split(',')]).limit(lim)
  }
  scope :find_by_like_name, lambda {|name,lim|
    public_fields.where(["name like ?", "%#{name}%"]).has_joined.limit(lim)
  }
  scope :search_by_all, lambda {|identifier,limit|
    list = [identifier,identifier,identifier]
    public_fields.where(["name like ? or user_nid=? or email=? or screen_name=?", "%#{identifier}%",*list]).has_joined
  }
  
  def self.for_nid(nid)
    return {} if nid.blank?
    Rails.cache.fetch("user_for_nid_#{nid}", :expires_in => 30.minutes) do
      public_fields.find_by_user_nid(nid)
    end
  end
  
  def self.follower(list_of)
    User.follower_fields.find_all_by_user_nid(list_of)
  end
  
  def self.valid_session?(user_nid, token)
    Rails.cache.fetch("user_valid_session_#{user_nid}_#{token}", :expires_in => 3.hours) do
      begin
        return false unless user_nid.present? && token.present?
        User.select('auth_token').find_by_user_nid(user_nid).try(:auth_token) == token
      rescue Exception
        false
      end
    end
  end
  
  def self.find_by_any_means_necessary(nid)
    User.public_fields.has_joined.find_by_any_means(nid).try(:first)
  end
  
  def self.login(nid_or_email,password,vname='')
    if nid_or_email.present? && vname.blank?
      user = User.login_with_nid_or_email(nid_or_email).first
    elsif vname.present?
      user = User.login_with_email_or_screen_name(nid_or_email, vname).first
    else
      user = User.login_with_nid_or_email(nid_or_email).first
    end
    if user.present?
      if user.password == Digest::SHA2.hexdigest(user.salt.to_s + password, 256)
        user.updated_at = Time.now
        user.save
        true
      else
        return 'login_failed'
      end
    end
  end
  
  def self.register(email, pass, username, name='', city='')
    return false if pass.blank?
    username = nil unless username.present?
    if log = User.login(email,pass,username)
      return log if log == 'login_failed'
      return User.find_by_email_or_screen_name(email,username)
    end
    user,flag = new_or_hasnt_joined(email)
    return user unless flag
    user.email = email
    user.salt = rand(1<<32).to_s
    user.password = Digest::SHA2.hexdigest(user.salt.to_s + pass, 256)
    user.last_seen = Time.now
    user.has_joined = true
    user.screen_name = username
    user.name = name
    user.city = city
    user.auth_token = User.new_auth_token
    user.user_nid ||= Util.ID
    if user.save
      UserMailer.welcome_email(user).try(:deliver)
      User.private_fields.find_by_email(email)
    end
  end
  
  def self.register_with_facebook(fbHash,user_nid,email,access_token='',username='')
    fbHash_str = fbHash
    if fbHash.kind_of? String
      fbHash = begin
        JSON.parse(fbHash)
      rescue Exception
        {}
      end
    end
    return false if (fb_id = fbHash['id']).blank?
    user = User.find_by_user_nid(user_nid) if user_nid.present?
    user ||= User.find_by_email([email,fbHash['email']].compact) if email.present? || fbHash['email'].present?
    return user if user.present?
    u,flag = new_or_hasnt_joined(fb_id)
    user ||= u
    return user unless flag
    user.facebook_hash = fbHash_str
    user.screen_name ||= username || fbHash['user_name']
    user.facebook = fb_id
    user.name ||= fbHash['name']
    user.fb_access_token = access_token
    user.token = email_token
    user.email ||= fbHash['email']
    user.image_url ||= "https://graph.facebook.com/#{user.facebook}/picture?type=large"
    user.last_seen = Time.now
    location = fbHash['locaton']
    user.city, user.state = Util.parse_location(location)
    user.token_expires = Time.now + 14.days
    user.has_joined = true
    user.auth_token ||= User.new_auth_token
    user.user_nid ||= Util.ID
    if user.save
      UserMailer.welcome_email(user).try(:deliver)
      User.private_fields.find_by_user_nid(user.user_nid)
    end
  end
  
  def self.register_with_twitter(twHash,username='',email='')
    return false if (tw_id = twHash['id']).blank?
    user = new_or_hasnt_joined(tw_id)
    return false if user.blank?
    user.twitter_hash = twHash
    user.screen_name = username
    user.email = email
    user.twitter = tw_id
    user.name = twHash['name']
    user.image_url = twHash['profile_image_url']
    user.token = email_token
    user.last_seen = Time.now
    user.city, user.state = Util.parse_location(twHash['location'])
    user.token_expires = Time.now + 14.days
    user.has_joined = true
    user.user_nid ||= Util.ID
    if user.save
      UserMailer.welcome_email(user).try(:deliver)
      User.private_fields.find_by_user_nid(user.user_nid)
    end
  end
    
  def self.new_or_hasnt_joined(identifier)
    user = User.find_by_any_means(identifier).first
    if user.blank?
      return [User.new, true]
    else 
      return [user,false] if user.has_joined == true
      Follower.user_has_joined(user.user_nid)
    end
    return [user, true]
  end
  
  def self.create_should_join(items)
    user = User.new
    user.email = items[:email]
    user.twitter = items[:twid]
    user.facebook = items[:fbid]
    token = email_token
    user.token = token
    user.token_expires = email_token_expires
    user.user_nid = Util.ID
    ## - warning   #####################################################
    ## - make sure that we know this is not a valid user as they      ##
    ##    are here because someone followed them via some identifier  ##
    user.has_joined = false                                           ##
    ## end warning #####################################################
    if user.save
      User.public_fields.find_by_user_nid(user.user_nid)
    end
  end
  
  def self.new_auth_token
    Digest::SHA2.hexdigest(rand(1<<16).to_s)
  end
  
  def self.email_token(email=rand(1<<16).to_s)
    Digest::SHA2.hexdigest(email.to_s + Time.now.to_s, 256)
  end
  
  def self.email_token_expires
    Time.now + 14.days
  end
  
  def self.fields(opt=:public)
    fields = "user_nid,name,image_url,url,city,screen_name,follower_count,description,created_at,updated_at,has_joined"
    if opt == :private
      fields << ",auth_token,street,country,email,phone,facebook,twitter"
    end
    fields
  end
  
end


  # create_table "users", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.string   "nid"
  #   t.string   "name"
  #   t.string   "screen_name"
  #   t.string   "email"
  #   t.string   "phone"
  #   t.string   "facebook"
  #   t.string   "twitter"
  #   t.string   "google"
  #   t.string   "last_seen"
  #   t.string   "udid"
  #   t.string   "url"
  #   t.string   "image_url"
  #   t.string   "street"
  #   t.string   "city"
  #   t.string   "state"
  #   t.string   "zip"
  #   t.string   "country"
  #   t.string   "password",                       :default => ""
  #   t.string   "salt"
  #   t.string   "auth_token"
  #   t.binary   "newpassword",    :limit => 255
  #   t.datetime "newpass_time"
  #   t.text     "description"
  #   t.datetime "authenticated"
  #   t.string   "token"
  #   t.date     "token_expires"
  #   t.string   "referral_code",  :limit => 32
  #   t.string   "referred_by",    :limit => 32
  #   t.string   "json_encode",    :limit => 1022
  #   t.integer  "follower_count"
  #   t.string   "oauth_token"
  #   t.string   "oauth_secret"
  #   t.binary   "facebook_hash"
  #   t.binary   "twitter_hash"
  #   t.boolean  "has_joined",                     :default => true
  #   t.binary   "schemaless"
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
