
class User < ActiveRecord::Base
  
  scope :public_fields, lambda {
    select(User.fields)
  }
  scope :private_fields, lambda {
    select(User.fields({:private => true}))
  }
  scope :me, lambda {|token|
    private_fields.where(["session_id=?",token])
  }
  scope :find_by_id_or_email, lambda {|id|
    public_fields.where(["id=? or email=?", id, id])
  }
  scope :find_by_any_means_necessary, lambda {|id|
    items = [id,id,id,id,id]
    public_fields.where(["id=? or screen_name=? or email=? or facebook=? or twitter=?",*items])
  }
  scope :find_by_not_yet_joined, lambda {|eamil|
    public_fields.where(["email=? and has_joined=0", email])
  }
  scope :detail, lambda {|id|
    find_by_id_or_email(id).select(User.fields)
  }
  scope :find_by_name, lambda {|name|
    public_fields.where(["name like ?", "%#{name}%"])
  }
  scope :find_by_username, lambda {|username|
    public_fields.where(["screen_name=?", username])
  }
  scope :search_by_all, lambda {|query|
    items = ["%#{query}%",query,query]
    public_fields.where(["name like ? or email=? or screen_name=?", *items])
  }
  
  def self.token_match?(id, token)
    begin
      id == me(token).id
    rescue Exception
      false
    end
  end
  
  def self.login(email,vname='',password)
    unless email.blank?
      user = User.find_by_email(email)
      if user && user.password == Digest::SHA2.hexdigest(user[:salt] + password)
        user.session_id = Digest::SHA2.hexdigest(rand(1<<16).to_s)
        user.last_seen  = Time.now
        user.save!
      end
    end
  end
  
  def self.register(email, pass, username='')
    new_user = new_or_hasnt_joined(email)
    nuser = new_user do |user|
      user.email    = email
      user.salt     = rand(1<<32).to_s
      user.password = Digest::SHA2.hexdigest(user[:salt] + pass, 256)
      user.last_seen= Time.now
      user.va
      user.screen_name=username
    end
    nuser.save!
  end
  
  def self.register_with_facebook(fbHash,username='')
    user = new_or_hasnt_joined(fbHash['email'])
    user.screen_name = username
    user.facebook = fbHash['id']
    user.name     = fbHash['name']
    user.token    = email_token
    user.url      = "https://graph.facebook.com/#{user.facebook}/picture"
    user.last_seen= Time.now
    location      = fbHash['locaton']
    user.city, user.state = parse_location(location)
    user.token_expires = Time.now + 14.days
    user.save!
  end
  
  def self.register_with_twitter(twHash,username='',email='')
    user = new_or_hasnt_joined(twHash['email'])
    user.screen_name = username
    user.email    = email
    user.twitter  = twHash['id']
    user.name     = twHash['name']
    user.url      = twHash['profile_image_url']
    user.token    = email_token
    user.last_seen= Time.now
    user.city, user.state = parse_location(twHash['location'])
    user.token_expires = Time.now + 14.days
    user.save!
  end
    
  def self.new_or_hasnt_joined(email)
    User.find_by_not_yet_joined(email) || User.new
  end
  
  def self.create_should_join(items)
    new_user = User.new do |user|
      user.email        = items[:email]
      user.twitter      = items[:twid]
      user.facebook     = items[:fbid]
      user.token        = email_token
      user.token_expires= email_token_expires
      ## - warning   #####################################################
      ## - make sure that we know this is not a valid user as they      ##
      ##    are here because someone followed them via some identifier  ##
      user.has_joined = false                                           ##
      ## end warning #####################################################
    end
    puts "NEW USER #{new_user.inspect}"
    new_user.save!
  end
  
  def self.parse_location(location)
    city_state = location['name']
    unless city_state.nil?
      parts = city_state.split
      if parts.length > 1
        [parts[0].strip, parts[1].strip]
      else
        city_state
      end
    end
  end
  
  def self.email_token(email)
    Digest::SHA2.hexdigest(email.to_s + Time.now.to_s, 256)
  end
  
  def self.email_token_expires
    Time.now + 14.days
  end
  
  def self.fields(opt=:public)
    fields = "name,last_seen,city,screen_name,follower_count,description,created_at"
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
  #   t.binary   "password",       :limit => 255,  :null => false
  #   t.string   "salt",                           :null => false
  #   t.string   "session_id"
  #   t.binary   "newpassword",    :limit => 255
  #   t.datetime "newpass_time"
  #   t.string   "email",                          :null => false
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
  #   t.boolean  "has_joined"     :default => true
  
  # Fields from the facebook hash that is sent to the facebook registration outlet  
  #   {
  #    "id": "679816146",
  #    "name": "Brian Norton",
  #    "first_name": "Brian",
  #    "last_name": "Norton",
  #    "link": "http://www.facebook.com/bnort",
  #    "username": "bnort",
  #    "birthday": "08/27/1987",
  #    "location": {
  #       "id": "114952118516947",
  #       "name": "San Francisco, California"
  #    },
  #    "education": [
  #       {
  #          "school": {
  #             "id": "10111634660",
  #             "name": "UC Berkeley"
  #          },
  #          "year": {
  #             "id": "144044875610606",
  #             "name": "2011"
  #          },
  #          "concentration": [
  #             {
  #                "id": "104076956295773",
  #                "name": "Computer Science"
  #             }
  #          ],
  #          "type": "College"
  #       },
  #       {
  #          "school": {
  #             "id": "110242592338268",
  #             "name": "University of California, Berkeley"
  #          },
  #          "type": "College",
  #          "with": [
  #             {
  #                "id": "1581904554",
  #                "name": "Horia Airoh"
  #             }
  #          ]
  #       }
  #    ],
  #    "gender": "male",
  #    "relationship_status": "In a relationship",
  #    "website": "about.me/nort\r\ntwitter.com/nort",
  #    "timezone": -7,
  #    "locale": "en_US",
  #    "verified": true,
  #    "updated_time": "2011-10-16T05:54:20+0000"
  # }
  
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
