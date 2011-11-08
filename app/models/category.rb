require 'mongo_ruby'

class Category < MongoRuby
  
  ############    primary | secondary | alias
  attr_accessor  :p,       :s,         :a
  
  def self.dbcollection
    "categories"
  end
  
  # @required n
  # @optional secondary
  def self.find_by_name(primary,opt={})
    return false if primary.blank?
    secondary = opt[:s]
    puts "what is secondary #{secondary}"
    if secondary && (ali = opt[:a])
      Category.find_one({ :p => primary, :s => secondary, :a => ali })
    elsif secondary
      Category.find_one({ :p => primary, :s => secondary })
    else
      Category.find_one({ :p => primary })
    end
  end
  
  # @required id
  def self.find_by_id(id)
    return false if id.blank?
    Category.find_one({:_id => id})
  end
  
  # @required_for_find id
  # @required_for_create primary
  # @optional secondary
  # @optional alias
  def self.find_or_create_by_id(id,opt={})
    unless Category.find_by_id(id)
      options = Category.params(opt)
      unless (options).blank? || options[:p].blank?
        return Category.save({:_id => id}.merge(options))
      end
    end
    false
  end
  
  # @required_for_find primary
  # @required_for_create primary
  # @optional secondary
  # @optional alias
  def self.find_or_create_by_name(primary,opt={})
    return false if primary.blank?
    puts "PRIMARY #{primary} and opt #{opt.inspect}"
    Category.normalize!(primary)
    Category.normalize!(opt)
    puts "PRIMARY #{primary}"
    unless Category.find_by_name(primary,opt)
      items = Category.params(opt, primary)
      return Category.save(items)
    end
    false
  end
  
  def self.find_or_create_by_primary_and_secordary(p,s)
    return false if s.blank?
    Category.find_or_create_by_name(p,{ :s => s })
  end
  
  # @required id
  def self.destroy_by_id(id)
    return false if id.blank?
    Category.remove({ :_id => id })
  end
  
  def self.new_categories(top_level,cats=[])
    return false if cats.blank?
    Category.find_or_create_by_name(top_level)
    cats.each do |c|
      Category.find_or_create_by_primary_and_secordary(top_level, c)
    end
    true
  end
  
  private 
  def self.normalize!(denorm)
    if denorm.respond_to? :keys
      denorm.each do |k,v|
        v.downcase!
      end
    elsif denorm.respond_to? :each
      denorm.each do |o|
        o.downcase!
      end
    elsif denorm.respond_to? :downcase!
       denorm.downcase!
    end
    
  end
  
  def self.params(opt,primary=nil)
    op = {}
    puts "OP primary #{opt.inspect}"
    op.merge!({:p => (primary || opt[:p])})
    op.merge!({:s => opt[:s]}) if opt[:s]
    op.merge!({:a => opt[:a]}) if opt[:a]
    puts "OP after #{op.inspect}"
    op
  end
  
end