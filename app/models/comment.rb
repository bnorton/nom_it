require 'mongo_ruby'

class Comment < MongoRuby
  
  ############ user_id  |  location_id  |  recommendation_id  |  parent_comment_id
  attr_accessor :uid,         :lid,              :rid,                 :pcid
  attr_accessor :text, :hash
  
  def self.dbcollection
    "comments"
  end
  
  def self.removed_content_message
    "the user has removed this comment."
  end
  
  def self.create_comment_for_location(opt={})
    return false unless Comment.check_params(opt) && opt[:text]
    self.create(opt)
  end
  
  def self.create_comment_for_recommendation(opt={})
    return false unless Comment.check_params_full(opt) && opt[:text]
    self.create(opt)
  end
  
  def self.create_comment_for_nid(opt={})
    return false unless opt[:nid]
    self.create(opt)
  end
  
  # can only destroy one since the id is globally unique
  def self.destroy_id(id)
    return false unless (id = Util.BSONify(id))
    Comment.set(id,:text,Comment.removed_content_message)
  end
  
  def self.destroy_uid_lid_rid(opt)
    return false unless Comment.check_params_full(opt)
    self.destroy(opt)
  end
  
  def self.destroy_uid_lid(opt)
    return false unless Comment.check_params(opt)
    self.destroy(opt)
  end
  
  def self.text_search(opt={})
    false
  end
  
  # find all my comments on a specific item
  def self.search_by_uid_lid_rid(uid,lid,rid)
    Comment.find({ :uid => uid.to_i, :lid => lid.to_i, :rid => rid.to_i })
  end
  
  def self.search_by_uid_lid(uid,lid)
    Comment.find({ :uid => uid.to_i, :lid => lid.to_i })
  end
  
  # simply find a comments id
  def self.search_id(_id)
    return false if (_id = _id.to_s).blank?
    Comment.find({ :_id => BSON::ObjectId.from_string(_id)})
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
  
  private
  
  # The most granular can only be user comments on a recommendation about a location
  def self.check_params_full(opt)
    return false if ((uid = opt[:uid]).blank?  || (lid = opt[:lid]).blank?  || (rid = opt[:rid]).blank?)
    true
  end
  
  # user comments on a location only
  def self.check_params(opt)
    return false if ((uid = opt[:uid]).blank?  || (lid = opt[:lid]).blank?)
    true
  end
  
  private
  # parent_comment_id is for threadding (hit the reply button)
  def self.create(opt={})
    unless (nid = opt[:nid]) && (Comment.search_id(opt[:nid]).count > 0)
      hash = {
        :text => opt[:text],
        :hash => opt[:hash]
      }
      if nid
        hash.merge!({
          :nid => nid
        })
      else
        hash.merge!({
          :uid  => opt[:uid],
          :lid  => opt[:lid]
        })
      end
      hash.merge!({:pcid => opt[:pcid]}) if opt[:pcid]
      hash.merge!({:rid  => opt[:rid]})  if opt[:rid]
      Comment.save(hash)
    end
  end
  
  # removes all comments (could be more than one)
  def self.destroy(opt={})
    return false unless Comment.check_params(opt)
    finder = {
      :uid => opt[:uid],
      :lid => opt[:lid] }
    finder.merge!({:rid => opt[:rid]}) if opt[:rid]
    Comment.update(finder,{'$set'=>{:text => Comment.removed_content_message}})
  end
  
  def self.for_all(finder,options={})
    the_limit = options[:limit] || 20
    Comment.find(finder).sort([[ :_id, MONGO_ASC ]]).limit(the_limit)
  end
  
  # precedence nid > text > uid,lid,rid > uid,lid > uid > lid > rid
  #
  def self.search(opt={})
    if fn = opt[:nid]
      Comment.search_id(fn)
    elsif fn = opt[:text]
      Comment.text_search(fn)
    elsif check_params_full(opt)
      Comment.search_by_uid_lid_rid(opt[:uid],opt[:lid],opt[:rid])
    elsif check_params(opt)
      Comment.search_by_uid_lid(opt[:uid],opt[:lid])
    elsif val = opt[:uid]
      Comment.for_user_id(val)
    elsif val = opt[:lid]
      Comment.for_location_id(val)
    elsif val = opt[:rid]
      Comment.for_recommendation_id(val)
    else
      false
    end
  end
  
end