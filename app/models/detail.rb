class Detail < MongoRuby
  
    #        | token | recommendation_id | user_id
  attr_accessor :_id, :rnid
  
  def self.dbcollection
    "tokens"
  end
  
  def self.new_token(token,recommendation_id)
    Detail.save({:_id => token, :rnid => recommendation_id})
  end
  
  def self.for_whatever(key,item,lim)
    lim = lim > 50 ? 50 : lim < 5 ? 5 : lim.to_i
    found = Detail.find({key => item}).limit(lim)
    Util.parse(found,{:key=>:token}) if found
  end
  
  def self.for_token(token,lim=20)
    Detail.for_whatever(:_id,token,lim)
  end
  
  def self.for_recommendation(rid,lim=20)
    Detail.for_whatever(:rnid,rid,lim)
  end
  
  # Coordinate the full capture of all data for a detail
  def build_detail_for_token(token)
    record = Detail.for_token(token)
    recommendation = Recommendation.for_nid(record['rnid'])
    nid = recommendation['nid']
    meta = Metadata.find_by_nid(nid)
    [recommendation,meta]
  end
  
end