class Detail < MongoRuby
  
    #        | token | recommendation_nid | location_nid
  attr_accessor :_id, :rnid, :lnid
  
  def self.dbcollection
    "tokens"
  end

  def self.new_token(token,recommendation_nid, location_nid)
    Detail.save({:_id => token, :rnid => recommendation_nid, :lnid => location_nid})
  end

  def self.for_whatever(key,item,lim)
    found = Detail.find({key => item}).limit(lim)
    Util.parse(found,{:key=>:token}) if found
  end

  def self.for_token(token,lim=20)
    Detail.for_whatever(:_id,token,lim)
  end

  def self.for_recommendation(rnid,lim=20)
    Detail.for_whatever(:rnid,rnid,lim)
  end

  def self.for_location(lnid,lim=20)
    Detail.for_whatever(:lnid,lnid,lim)
  end

  # Coordinate the full capture of all data for a detail
  def self.build_detail_for_token(token, limit)
    record = Detail.for_token(token).try(:first)
    return {
      :location => {},
      :recommendation => {} } unless record.present?
    {
      :location => Location.compact_detail_for_nid(record['lnid']),
      :recommendation => Recommendation.compact_for_nid(record['rnid'])
    }
  end
  
end