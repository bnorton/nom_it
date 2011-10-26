class Like
  
  #####################################################################
  ### Ruby MongdDB Driver Wrapper
  def self.dbdatabase
    "nom_prod_test"
  end
  
  def self.dbcollection
    "likes"
  end
  
  def self.collection
    if @collection.nil?
      self.connect
    end
    @collection
  end
  
  def self.save(*args)
    self.collection.save(*args)
  end
  
  def self.remove(*args)
    self.collection.remove(*args)
  end
  
  def self.connect
  db = Mongo::Connection.new.db(self.dbdatabase)
  @collection = db[self.dbcollection]
  end
  ### End Ruby MongoDB Driver Wrapper
  #####################################################################
  

end