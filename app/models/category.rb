require 'mongo_ruby'

class Category < MongoRuby
  
  ############    primary | secondary | alias | the parent of this
  attr_accessor  :p,       :s,         :a,         :parent
  
  def self.dbcollection
    "categories"
  end
  
  # @required n
  # @optional secondary
  def self.find_by_name(primary,opt={})
    return false if primary.blank?
    secondary = opt[:s]
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
    return false unless (id = Util.BSONify(id))
    Category.find_one({ :_id => id })
  end
  
  # @required_for_find id
  # @required_for_create primary
  # @optional secondary
  # @optional alias
  def self.find_or_create_by_id(id,opt={})
    found = Category.find_by_id(id)
    if found.blank?
      options = Category.params(opt)
      unless (options).blank? || options[:p].blank?
        return Category.save({ :_id => id }.merge(options))
      end
    end
    found
  end
  
  # @required_for_find primary
  # @required_for_create primary
  # @optional secondary
  # @optional alias
  def self.find_or_create_by_name(primary,opt={})
    return false if primary.blank?
    Category.normalize!(primary)
    Category.normalize!(opt)
    category = Category.find_by_name(primary,opt)
    if category.blank?
      items = Category.params(opt, primary)
      Category.save(items)
    else
      category['_id']
    end
  end
  
  def self.find_or_create_by_primary_and_secordary(pid,s)
    Category.normalize!(s)
    return false if s.blank? || (top = Category.find_by_id(pid)).blank?
    sec = Category.find_one({ :parent => top['_id'], :p => s })
    return sec['_id'] unless sec.blank?
    Category.save({ :p => s, :parent => top['_id']})
  end
  
  def self.new_categories(top_level,cats=[])
    return false if cats.blank?
    ids = []
    top = Category.find_or_create_by_name(top_level)
    ids << top
    cats.each do |c|
      ids << Category.find_or_create_by_primary_and_secordary(top, c)
    end
    ids
  end
  
  private
  
  # @required id
  def self.destroy_by_id(id)
    return false unless (id = Util.BSONify(id))
    Category.remove({ :_id => id })
  end
  
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
    Category.normalize!(opt)
    Category.normalize!(primary)
    op = {:p => (primary || opt[:p])}
    op.merge!({:s => opt[:s]}) if opt[:s]
    op.merge!({:a => opt[:a]}) if opt[:a]
    op
  end
  
end