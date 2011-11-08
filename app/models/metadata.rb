require 'mongo_ruby'

class Metadata < MongoRuby
  
  ############
  attr_accessor  :_id
  
  def self.dbcollection
    "metadatas"
  end
  
  # @required n
  # @optional secondary
  def self.find_by_name(primary,secondary=nil,ali=nil)
    return false if primary.blank?
    if secondary && ali
      Category.find_one({ :p => primary, :s => secondary, :a => ali })
    elsif secondary
      Category.find_one({ :p => primary, :s => secondary })
    else
      Category.find_one({ :p => primary })
    end
  end
  
  # @required id
  def self.find_by_nid(nid)
    return false if nid.blank?
    Category.find_one({:_id => nid})
  end
  
  # @required_for_find id
  # @required_for_create primary
  # @optional secondary
  # @optional alias

  def self.find_or_create_by_id(id,opt={})
    unless found = Category.find_by_id(id)
      if (options = Category.params(opt))
        found = Category.save({:_id => id}.merge(options))
      end
    end
    found
  end
  
  # @required_for_find primary
  # @required_for_create primary
  # @optional secondary
  # @optional alias
  def self.find_or_create_by_name(primary,opt={})
    unless found = Category.find_by_name(primary)
      items = Category.params(opt)
      found = Category.save(items)
    end
    found
  end
  
  # @required id
  def self.destroy_by_id(id)
    return false if id.blank?
    Category.remove({ :_id => id })
  end
  
  private 
  def self.params(opt)
    if p = opt[:primary]
      op = {:p => p}
      op.merge!(opt[:secondary] || {})
      op.merge!(opt[:alias] || {})
      op
    end
  end
  
end