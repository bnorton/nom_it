class Detail < MongoRuby
  
    #        | token | recommendation_nid
  attr_accessor :_id, :rnid
  
  def self.dbcollection
    "tokens"
  end
  
  def self.new_token(token,recommendation_nid)
    recommendation_nid = Util.STRINGify(recommendation_nid)
    Detail.save({:_id => token, :rnid => recommendation_nid})
  end
  
  def self.for_whatever(key,item,lim)
    found = Detail.find({key => item}).limit(lim)
    Util.parse(found,{:key=>:token}) if found
  end
  
  def self.for_token(token,lim=20)
    Detail.for_whatever(:_id,token,lim)
  end
  
  def self.for_recommendation(rnid,lim=20)
    rnid = Util.STRINGify(rnid)
    Detail.for_whatever(:rnid,rnid,lim)
  end
  
  # Coordinate the full capture of all data for a detail
  def self.build_detail_for_token(token)
    record = Detail.for_token(token)
    recommendation = Recommendation.for_nid(record['rnid'])
    nid = recommendation.recommendation_nid
    meta = Metadata.find_by_nid(nid)
    if recommendation && meta
      Metadata.viewed(nid)
      {
        :recommendation => recommendation,
        :metadata => meta
      }
    else
      {}
    end
  end
  
end