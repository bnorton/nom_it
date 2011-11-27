class NomRank
  
  def process
    @locations = NomRank.fetch_all
    @locations.each do |l|
      meta = Metadata.for_nid(l.nid)
    end
  end
  
  def fetch_all(lim=50)
    Location.limit(lim).offset(@offset).find(:all)
  end
  
  
  
end