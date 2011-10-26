require 'mongo_ruby'

class Comment < MongoRuby
  
  ############ user_id  |  location_id  |  recommendation_id  |  parent_comment_id
  attr_accessor :uid,         :lid,              :rid,                 :pcid
  attr_accessor :text, :time, :hash
  
  def self.dbcollection
    "comments"
  end
  
  # The most granular can only be user comments on a recommendation about a location
  def self.check_params_full(opt)
    return false if ((uid = opt[:uid]).blank?  ||
                     (lid = opt[:lid]).blank?  || (rid = opt[:rid]).blank?)
    true
  end
  
  # user comments on a location only
  def self.check_params(opt)
    return false if ((uid = opt[:uid]).blank?  || (lid = opt[:lid]).blank?)
    true
  end
  
  # parent_comment_id is for threadding (hit the reply button)
  def self.create(opt={})
   unless Comment.search_id(opt[:nomid])
      hash = {
        :uid  => opt[:uid],
        :lid  => opt[:lid],
        :pcid => opt[:pcid] || nil,
        :text => opt[:text],
        :hash => opt[:hash]
      }
      hash.merge!({:rid  => opt[:rid]}) if opt[:rid]
      Comment.save(hash)
    end
  end
  
  def self.create_comment_for_location(opt={})
    puts "create_comment_for_location #{opt.inspect}"
    return false unless Comment.check_params(opt) && opt[:text]
    self.create(opt)
  end
  
  def self.create_comment_for_recommendation(opt={})
    puts "create_comment_for_recommendation #{opt.inspect}"
    return false unless Comment.check_params_full(opt) && opt[:text]
    self.create(opt)
  end
  
  # can only destroy one since the id is globally unique
  def self.destroy_id(id)
    puts "destroy_id #{opt.inspect}"
    return false if id.blank?
    Comment.remove({:_id => id})
  end
  
  # removes all comments (could be more than one) for a content item
  def self.destroy(opt={})
    puts "destroy #{opt.inspect}"
    return false unless Comment.check_params(opt)
    Comment.remove({
      :uid => opt[:uid],
      :lid => opt[:lid],
      :rid => opt[:rid]
    })
  end
  
  def self.text_search(opt={})
    puts "text_search #{opt.inspect}"
    false
  end
  
  # precedence nid > text > uid,lid,rid > uid,lid > uid > lid > rid
  #
  def self.search(opt={})
    puts "Comment search #{opt.inspect}"
    if fn = opt[:nid]
      puts "opt nid"
      Comment.search_id(fn)
    elsif fn = opt[:text]
      puts "opt text"
      Comment.text_search(fn)
    elsif check_params_full(opt)
      puts "check_params_full"
      Comment.search_by_uid_lid_rid(opt[:uid],opt[:lid],opt[:rid])
    elsif check_params(opt)
      puts "check_params"
      Comment.search_by_uid_lid(opt[:uid],opt[:lid])
    elsif val = opt[:uid]
      puts "opt uid"
      Comment.for_user_id(val)
    elsif val = opt[:lid]
      puts "opt lid"
      Comment.for_location_id(val)
    elsif val = opt[:rid]
      puts "opt rid"
      Comment.for_recommendation_id(val)
    else
      false
    end
  end
  
  # find all my comments on a specific item
  def self.search_by_uid_lid_rid(uid,lid,rid)
    Comment.collection.find({ :uid => uid.to_i, :lid => lid.to_i, :rid => rid.to_i })
  end
  
  def self.search_by_uid_lid_rid(uid,lid)
    Comment.collection.find({ :uid => uid.to_i, :lid => lid.to_i })
  end
  
  # simply find a comments id
  def self.search_id(_id)
    return false if (_id = _id.to_s).blank?
    Comment.collection.find({ :_id => BSON::ObjectId.from_string(_id)})
  end
  
  def self.for_all(finder,options={})
    the_limit = options[:limit] || 20
    Comment.collection.find(finder).sort([[ :_id, ASC ]]).limit(the_limit)
  end
  
  def self.for_user_id(uid,options={})
    Comment.for_all({:uid => uid.to_i},options)
  end
  
  def self.for_location_id(lid,options={})
    Comment.for_all({:lid => lid.to_i},options)
  end
  
  def self.for_recommendation_id(rid,options={})
    Comment.for_all({:rid => rid.to_i},options)
  end

end