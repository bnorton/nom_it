class Ranking < MongoRuby
  
  #        | nid | user_id | value | some description
  attr_accessor :nid, :uid, :v, :text, :cur
  
  def self.dbcollection
    "rankings"
  end
  
  def self.max
    5
  end
  
  def self.min
    1
  end
  
  def self.removed_content_message
    "the user has removed this rating."
  end
  
  def self.add_new_rank
    MongoRuby.store_function("new_rank","function(nid,uid,value,txt) {
      var val = 0; 
      var what = null;
      var last = db.#{Ranking.dbcollection}.findOne({ nid:nid, uid:uid, cur:true });
      if (last != null) {
        last.cur = false;
        val = last.v;
        what = last.nid;
        db.#{Ranking.dbcollection}.save( last );
      } else {
        rankings = db.#{Ranking.dbcollection}.find({ uid:uid, cur:true });
        for(i=0; i<rankings.count; ++i) {
          rank = rankings.next;
          if (value == rank.v) {
            rank.cur = false;
            val  = rank.v;
            what = rank.nid;
            db.#{Ranking.dbcollection}.save( rank );
          } 
        }
      }
      db.#{Ranking.dbcollection}.save({ nid:nid, uid:uid, v:value, text:txt, cur:true });
      return [what,val]; }")
  end
  
  def self.add_remove_rank
    MongoRuby.store_function("remove_rank","function(nid,uid){
      rank = db.#{Ranking.dbcollection}.findOne({ nid:nid, uid:uid, cur:true });
      if (rank) { rank.cur = false;
        db.#{Ranking.dbcollection}.save( rank );
        return true;
      } else { return false; }}")
  end
  
  def self.new_rank(nid,uid,value,text='')
    value = Ranking.valid(value)
    old_nid, old_val = Ranking.eval("new_rank('#{nid}','#{uid}',#{value},'#{text}')")
    if old_nid
      RankingAverage.update_ranking(old_nid, old_val, value)
    else
      RankingAverage.new_ranking(nid, value)
    end
  end
  
  # mark as not current
  def self.remove_rank(nid,uid)
    old_value = Ranking.eval("remove_rank('#{nid}','#{uid}')")
    RankingAverage.remove_ranking(nid, old_value)
  end
  
  def self.for_uid(uid,lim=10,key=:ranking_id)
    lim = Ranking.valid_limit(lim)
    unless (uid = uid.to_s).blank?
      found = Ranking.find({:uid => uid, :cur => true}).limit(lim)
      Util.parse(found,{:key => key})
    else
      false
    end
  end
  
  def self.for_nid(nid,lim=10,key=:location_id)
    lim = Ranking.valid_limit(lim)
    found = Ranking.find({:nid => nid, :cur => true}).limit(lim)
    Util.parse(found,{:key => key})
  end
  
  private
  
  def self.valid_limit(limit)
    limit = limit.to_i || 10
    limit > 50 ? 50 : limit < 10 ? 10 : limit
  end
  
  def self.valid(value)
    value = self.max if value > self.max
    value = self.min if value < self.min
    value.to_f
  end
  
    # returns the nids of the items passed to it (an array)
  def self.build_list(rankings, options={})
    rankings = [rankings] if (rankings.is_a? Hash)
    loc_rank = []
    rankings.each do |rank|
      nid = rank['nid'] || rank[:nid]
      loc = Location.detail_for_nid(nid)
      raise loc.inspect
      loc_rank << {
        :rank => rank,
        :location => loc
      }
    end
    return loc_rank[0] if (options[:one] && loc_rank.length == 1)
    loc_rank
  end

end
