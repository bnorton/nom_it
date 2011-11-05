#!/usr/bin/ruby
# coding: utf-8

APP_PATH = File.expand_path('../../config/application',  __FILE__)
require File.expand_path('../../config/boot',  __FILE__)
require APP_PATH
# set Rails.env here if desired
Rails.application.require_environment!

require 'json/add/rails'

class Correlate
  def self.run
    
    filename = 'data/correlate.out'
    s = IO.read(filename)
    locations__ = JSON.parse(s)
    
    trends = {}
    
    locations = locations__.keys
    i = 0
    locations.each do |fsqid|
      i += 1
      location = locations__[fsqid]
      corr = location['location']
      
      this = Location.find_or_initialize_by_fsq_id(fsqid)
      this.name = corr['name']
      this.gowalla_url = corr['gowurl']
      this.gowalla_name = corr['gowalla_name']
      this.address = corr['addr']
      this.street = corr['street']
      this.city = corr['city']
      this.state = corr['state']
      this.area_code = corr['zipc']
      this.country = corr['country']
      this.nid = Util.ID;
      begin
        this.save!
      rescue ActiveRecord::RecordNotUnique
      end
      
      location_id = Location.find_by_fsq_id(fsqid)
      
      corr = location['geolocation']
      
      this = Geolocation.find_or_initialize_by_location_id(location_id)
      this.lat = corr['lat']
      this.lng = corr['lng']
      begin
        this.save!
      rescue ActiveRecord::RecordNotUnique
      end
      
      corr = location['statistics']
      
      this = Statistic.find_or_initialize_by_location_id(location_id)
      this.yelp_reviews = corr['yelp']
      this.yelp_rating  = corr['rating']
      this.gowalla_checkins = corr['gowcheckins']
      this.gowalla_users = corr['gowusers']
      begin
        this.save!
      rescue ActiveRecord::RecordNotUnique
      end
      
      trends[fsqid] = {
        :checkins => corr['fsqcheckins'],
        :users => corr['fsqusers'],
        :tips => corr['fsqtips']
      }
    end
    
    fi = File.open('data/trends.out', 'w')
    fi.write(trends.to_json)
    fi.close()
  end
end

Correlate.run
    # stat  = {
    #     'gowcheckins':statistic__['gowcheckins'],
    #     'gowusers'   :statistic__['gowusers'],
    #     'yelp'       :statistic__['yelp'],
    #     'rating'     :statistic__['rating'],
    #     'fsqcheckins':statistic__['fsqcheckins'],
    #     'fsqusers'   :statistic__['fsqusers'],
    #     'fsqtips'    :statistic__['fsqtips']}
    # create_table "statistics", :force => true do |t|
    #   t.datetime "created_at"
    #   t.datetime "updated_at"
    #   t.integer  "location_id",                                       :null => false
    #   t.integer  "recommendations"
    #   t.integer  "recommends_count"
    #   t.integer  "rrr"
    #   t.integer  "rrt"
    #   t.integer  "quarter"
    #   t.integer  "half",                               :default => 0, :null => false
    #   t.integer  "mile",                               :default => 0, :null => false
    #   t.integer  "two"
    #   t.integer  "quarter_total"
    #   t.integer  "halmile_total"
    #   t.integer  "mile_total"
    #   t.integer  "two_mile_total"
    #   t.date     "established"
    #   t.integer  "yelp_reviews"
    #   t.float    "yelp_rating"
    #   t.integer  "opentable_reviews"
    #   t.float    "opentable_rating"
    #   t.integer  "gowalla_checkins"
    #   t.integer  "gowalla_users"
    #   t.integer  "fsq_checkins"
    #   t.integer  "fsq_users"
    #   t.integer  "fsq_tips"
    #   t.integer  "tweets"
    #   t.integer  "nom_facebook_posts"
    #   t.integer  "view_count"
    #   t.string   "json_encode",        :limit => 1022
    #   t.binary   "schemaless"
    #   t.string   "nid"
    # end
  
    # create_table "geolocations", :force => true do |t|
    #   t.datetime "created_at"
    #   t.datetime "updated_at"
    #   t.integer  "location_id",                  :null => false
    #   t.float    "lat",         :default => 0.0
    #   t.float    "lng",         :default => 0.0
    #   t.string   "nid"
    # end
    # 
    # geol = {
    #     'lat'        :geolocation__['lat'],
    #     'lon'        :geolocation__['lon']}

    # loca     = {
    #     'name'        :location__['name'],
    #     'addr'        :location__['addr'],
    #     'street'      :location__['street'],
    #     'city'        :location__['city'],
    #     'zipc'        :location__['zipc'],
    #     'state'       :location__['state'],
    #     'country'     :location__['country'],
    #     'fsqid'       :location__['fsqid'],
    #     'fsqname'     :location__['fsqname'],
    #     'name'        :revision__['name'],
    #     'gowurl'      :location__['gowurl'],
    #    'neighborhoods':revision__['neighborhoods'],
    #      'hours'      :revision__['hours'],
    #      'phone'      :revision__['phone'],
    #      'cost'       :revision__['cost'],
    #      'tags'       :revision__['tags'],
    #      'url'        :url}

    # create_table "locations", :force => true do |t|
    #   t.datetime "created_at"
    #   t.datetime "updated_at"
    #   t.string   "name"
    #   t.integer  "revision",                                     :null => false
    #   t.string   "fsq_name"
    #   t.string   "fsq_id"
    #   t.string   "gowalla_url"
    #   t.string   "gowalla_name"
    #   t.string   "address"
    #   t.string   "cross_street"
    #   t.string   "street"
    #   t.string   "street2"
    #   t.string   "city"
    #   t.string   "state"
    #   t.string   "area_code",    :limit => 7
    #   t.string   "country"
    #   t.text     "json_encode"
    #   t.boolean  "is_new",                    :default => false, :null => false
    #   t.string   "code"
    #   t.binary   "schemaless"
    #   t.string   "primary"
    #   t.string   "secondary"
    #   t.string   "nid"
    # end
