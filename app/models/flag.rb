class Flag < MongoRuby

  def self.dbcollection
    'flags'
  end

  def self.create(user_nid,nid,type,severity,lat,lng)
    Flag.save({
      :user_nid => user_nid,
      :type => type,
      :nid => nid,
      :sev => severity,
      :lat => lat,
      :lng => lng,
      :resolved => 0,
      :resolved_by => ''
    })
  end
end