require 'mongo_ruby'

class Comment < MongoRuby
  
  ############ user_id  |  location_id  |  recommendation_id  |  parent_comment_id
  attr_accessor :uid,         :lid,              :rid,                 :pcid
  attr_accessor :text, :time, :hash
  
  def self.dbcollection
    "comments"
  end
  
  def self.check_params(opt)
    return false if ((uid = opt[:uid]).blank?  ||
                     (lid = opt[:lid]).blank?  || (rid = opt[:rid]).blank?)
    true
  end
  
  def self.create(opt={})
    return false unless Comment.check_params(opt)
    unless Comment.search_id(opt[:nomid])
      Comment.save({
        :uid  => opt[:uid],
        :lid  => opt[:lid],
        :rid  => opt[:rid],
        :pcid => opt[:pcid] || 0,
        :text => opt[:text],
        :time => opt[:time] || Time.now,
        :hash => opt[:hash]
      })
    end
  end
  
  def self.destroy_id(id)
    return false if id.blank?
    Comment.remove({:_id => id})
  end
  
  def self.destroy(opt={})
    return false unless Comment.check_params(opt)
    Comment.remove({
      :uid => opt[:uid],
      :lid => opt[:lid],
      :rid => opt[:rid]
    })
  end
  
  def self.search(uid,lid,rid)
    Comment.collection.find({ :uid => uid, :lid => lid, :rid => rid })
  end
  
  def self.search_id(_id)
    return false if _id.blank?
    Comment.collection.find_one({ :_id => _id})
  end
  
  def self.for_user_id(uid,options={})
    the_limit = options[:limit] || 20
    Comment.collection.find({:uid => uid}).sort([[ :time, ASC ]]).limit(the_limit)
  end
  
  def self.for_location_id(lid,options={})
    the_limit = options[:limit] || 20
    Comment.collection.find({:lid => lid}).sort([[ :time, ASC ]]).limit(the_limit)
  end
  
  def self.for_recommendation_id(rid,options={})
    the_limit = options[:limit] || 20
    Comment.collection.find({:rid => rid}).sort([[ :time, ASC ]]).limit(the_limit)
  end

end