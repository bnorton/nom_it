require 'mongo_ruby'

class Comment < MongoRuby
  
  ############ user_nid  |  location_nid  |  recommendation_nid  |  parent_comment_nid
  attr_accessor :unid,         :lnid,              :rnid,                 :pcid
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
  
  # precedence nid > text > uid,lid,rid > uid,lid > uid > lid > rid
  #
  def self.search(opt={})
    if fn = opt[:nid]
      Comment.search_nid(fn)
    elsif fn = opt[:text]
      Comment.text_search(fn)
    elsif check_params_full(opt)
      Comment.search_by_unid_lnid_rnid(opt[:unid],opt[:lnid],opt[:rnid])
    elsif check_params(opt)
      Comment.search_by_unid_lnid(opt[:unid],opt[:lnid])
    elsif val = opt[:unid]
      Comment.for_user_nid(val)
    elsif val = opt[:lnid]
      Comment.for_location_nid(val)
    elsif val = opt[:rnid]
      Comment.for_recommendation_nid(val)
    else
      false
    end
  end
  
  # can only destroy one since the id is globally unique
  def self.destroy_nid(nid)
    return false unless (nid = Util.BSONify(nid))
    Comment.set(nid,:text,Comment.removed_content_message)
  end
  
  def self.destroy_unid_lnid_rnid(opt)
    return false unless Comment.check_params_full(opt)
    self.destroy(opt)
  end
  
  def self.destroy_unid_lnid(opt)
    return false unless Comment.check_params(opt)
    self.destroy(opt)
  end
  
  def self.text_search(opt={})
    false
  end
  
  private
  # find all my comments on a specific item
  def self.search_by_unid_lnid_rnid(unid,lnid,rnid)
    unid = Util.STRINGify(unid)
    lnid = Util.STRINGify(lnid)
    rnid = Util.STRINGify(rnid)
    Comment.find({ :unid => unid, :lnid => lnid, :rnid => rnid })
  end
  
  def self.search_by_unid_lnid(unid,lnid)
    unid = Util.STRINGify(unid)
    lnid = Util.STRINGify(lnid)
    Comment.find({ :unid => unid, :lnid => lnid })
  end
  
  # simply find a comments id
  def self.search_nid(nid)
    nid = Util.BSONify(nid)
    Comment.find({ :_id => nid })
  end
  
  def self.for_user_nid(unid,options={})
    unid = Util.STRINGify(unid)
    Comment.for_all({:unid => unid},options)
  end
  
  def self.for_location_nid(lnid,options={})
    lnid = Util.STRINGify(lnid)
    Comment.for_all({:lnid => lnid},options)
  end
  
  def self.for_recommendation_nid(rnid,options={})
    rnid = Util.STRINGify(rnid)
    Comment.for_all({:rnid => rnid},options)
  end
  
  private
  
  # The most granular can only be user comments on a recommendation about a location
  def self.check_params_full(opt)
    return false if ((unid = opt[:unid]).blank?  || (nlid = opt[:lnid]).blank?  || (rnid = opt[:rnid]).blank?)
    true
  end
  
  # user comments on a location only
  def self.check_params(opt)
    return false if ((unid = opt[:unid]).blank?  || (lnid = opt[:lnid]).blank?)
    true
  end
  
  private
  # parent_comment_nid is for threadding (hit the reply button)
  def self.create(opt={})
    nid = Util.STRINGify(opt[:nid])
    unless nid && (Comment.search_nid(nid).count > 0)
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
          :unid  => Util.STRINGify(opt[:unid]),
          :lnid  => Util.STRINGify(opt[:lnid])
        })
      end
      hash.merge!({:pcid => Util.STRINGify(opt[:pcid])}) if opt[:pcid]
      hash.merge!({:rnid  => Util.STRINGify(opt[:rnid])})  if opt[:rnid]
      Util.STRINGify(Comment.save(hash))
    end
  end
  
  # removes all comments (could be more than one)
  def self.destroy(opt={})
    return false unless Comment.check_params(opt)
    finder = {
      :unid => Util.STRINGify(opt[:unid]),
      :lnid => Util.STRINGify(opt[:lnid]) }
    finder.merge!({:rnid => Util.STRINGify(opt[:rnid])}) if opt[:rnid]
    Comment.update(finder,{'$set'=>{:text => Comment.removed_content_message}})
  end
  
  def self.for_all(finder,options={})
    the_limit = options[:limit] || 20
    Comment.find(finder).sort([[ :_id, MONGO_ASC ]]).limit(the_limit)
  end
  
end