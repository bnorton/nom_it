class MongoRuby
  
  ASC  = 'ascending'
  DESC = 'descending'
  
  #####################################################################
  ### Ruby MongoDB Driver Wrapper
  def self.dbdatabase
    "nom_prod_test"
  end
  
  def self.dbcollection
    raise "subclasses must have a dbcollection method"
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
  
  def self.find(*args)
    self.collection.find(*args)
  end
  
  def self.find_one(*args)
    self.collection.find_one(*args)
  end
  
  def self.connect()
    puts "CONNECTIONG TO MongoRuby"
      db = Mongo::Connection.new.db(self.dbdatabase)
      @collection = db[self.dbcollection]
  end
  ### End Ruby MongoDB Driver Wrapper
  #####################################################################

end