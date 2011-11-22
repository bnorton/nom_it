class MongoRuby
    
  #####################################################################
  ### Ruby MongoDB Driver Wrapper
  def self.dbdatabase
    "production"
  end
  
  def self.dbcollection
    raise "subclasses must have a dbcollection method"
  end
  
  def self.collection
    @collection ||= self.db[self.dbcollection]
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
  
  def self.update(*args)
    self.collection.update(*args)
  end
  
  def self.ensure_index(*args)
    self.collection.ensure_index(*args)
  end
  
  def self.incr(nid,what,ct=1)
    return false unless nid && what
    nid = Util.STRINGify(nid)
    begin
      self.collection.update({ :_id => nid }, { '$inc' => { what => ct }}, {:upsert => true}) ? true : false
    rescue Exception
      false
    end
  end
  
  def self.set(nid,what,val)
    return false unless nid && what && val
    nid = Util.STRINGify(nid)
    begin
      self.collection.update({ :_id => nid }, {'$set' => { what => val }}) ? true : false
    rescue Exception
      false
    end
  end
  
  def self.eval(*args)
    self.db.eval(*args)
  end
  
  def self.store_function(name,function)
    self.db.eval("db.system.js.save({ _id : '#{name.to_s}', value : #{function} })")
  end
  
  def self.db
    @db ||= Mongo::Connection.new.db(self.dbdatabase)
  end
  
  ### End Ruby MongoDB Driver Wrapper
  #####################################################################

end