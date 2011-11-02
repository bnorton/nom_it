#!/usr/bin/ruby
# coding: utf8

fi = File.open('../data/correlate.out')
locations__ = JSON.parse(fi.read())
fi.close()

locations = locations__.keys

locations.each do |fsqid|
  
  corr = locations__[fsqid]
  this = Location.find_by_fsq_id(fsqid)
  this.name = corr['name']
  this.gowalla_url = corr['gowurl']
  this.gowalla_name = corr['gowalla_name']
  this.address = corr['addr']
  this.street = corr['street']
  this.city = corr['city']
  this.state = corr['state']
  this.area_code = corr['zipc']
  this.country = corr['country']
  
  
  
  
  
  
end  

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
