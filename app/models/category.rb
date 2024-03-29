require 'mongo_ruby'

class Category < MongoRuby
  
  ############    primary | secondary | alias | the parent of this
  attr_accessor  :p,       :s,         :a,         :parent
  
  def self.dbcollection
    "categories"
  end
  
  # try ID first
  def self.find(nid_or_name,opt={})
    unless (result = Category.find_by_nid(nid_or_name))
      Category.find_by_name(nid_or_name,opt)
    else
      result
    end
  end
  
  # @required n
  # @optional secondary
  def self.find_by_name(primary,opt={})
    Category.normalize!(primary)
    Category.normalize!(opt)
    return false if primary.blank?
    secondary = opt[:s]
    if secondary && (ali = opt[:a])
      Category.find_one({ :p => primary, :s => secondary, :a => ali })
    elsif secondary
      Category.find_one({ :p => primary, :s => secondary })
    else
      if (found = Category.find_one({ :p => primary }))
        found
      else
        Category.find_one({ :s => primary })
      end
    end
  end
  
  # @required nid
  def self.find_by_nid(nid)
    return unless (nid = Util.STRINGify(nid))
    Category.find_one({ :_id => nid })
  end
  
  # @required_for_find primary
  # @required_for_create primary
  # @optional secondary
  # @optional alias
  def self.find_or_create_by_name(primary,opt={})
    return false if primary.blank?
    category = Category.find_by_name(primary,opt)
    unless category.blank?
      Util.STRINGify(category['_id'])
    else
      items = Category.params(opt, primary)
      Category.save_item(items)
    end
  end
  
  def self.find_or_create_by_primary_and_secordary(pnid,s)
    return false if s.blank? || (top = Category.find_by_nid(pnid)).blank?
    Category.normalize!(s)
    pcid = Util.STRINGify(top['_id'])
    sec = Category.find_one({ :parent => pcid, :p => s })
    
    return Util.STRINGify(sec['_id']) unless sec.blank?
    Category.save_item({ :p => s, :parent => pcid })
  end
  
  def self.new_categories(top_level,cats=[],assoc=:none)
    return if top_level.blank?
    cats = [] unless cats.respond_to?(:each)
    ids  = []
    top  = Category.find_or_create_by_name(top_level)
    cats.each do |c|
      ids << Category.find_or_create_by_primary_and_secordary(top, c)
    end
    [top, ids]
  end
  
  private
  
  # @required id
  def self.destroy_by_nid(nid)
    return unless (nid = Util.STRINGify(nid))
    Category.remove({ :_id => nid })
  end
  
  def self.normalize!(denorm)
    if denorm.respond_to? :downcase!
      denorm.downcase!
    elsif denorm.respond_to? :keys
      denorm.each_pair do |k,v|
        normalize!(v)
      end
    elsif denorm.respond_to? :each
      denorm.each do |o|
        normalize!(o)
      end
    end
  end
  
  def self.params(opt,primary=nil)
    Category.normalize!(opt)
    Category.normalize!(primary)
    opt.merge!({:p => primary}) if primary.present?
    opt
  end
  
  def self.save_item(what)
    Util.STRINGify(Category.save(what.merge(Category.ID)))
  end
  
  def self.ID
    { :_id => Util.ID }
  end
  
end