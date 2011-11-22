require 'mongo_ruby'

class Comment < MongoRuby
  
  ############ user_nid  |  about_user_nid | location_nid  |  recommendation_nid  |  parent_comment_nid
  attr_accessor :unid,      :abuid,         :lnid,            :rnid,                 :pcid
  attr_accessor :text, :hash

  def self.dbcollection
    "comments"
  end

  def self.removed_content_message
    "the user has removed this comment."
  end

  def self.create_comment_about_user(opt)
    return false unless Comment.check_user(opt,true) && opt[:text]
  end

  def self.create_comment_for_location(opt)
    return false unless Comment.check_location(opt) && opt[:text]
    self.create(opt)
  end

  def self.create_comment_for_recommendation(opt)
    return false unless Comment.check_recommendation(opt) && opt[:text]
    self.create(opt)
  end

  def self.for_location_nid(lnid,options={})
    lnid = Util.STRINGify(lnid)
    Comment.for_all({ :lnid => lnid },options)
  end

  
  # precedence nid > text > uid,lid,rid > uid,lid > uid > lid > rid
  #
  def self.search(opt={})
    if fn = opt[:comment_nid]
      Comment.search_nid(fn)
    elsif fn = opt[:text]
      Comment.text_search(fn)
    elsif check_params_full(opt)
      Comment.search_by_unid_lnid_rnid(opt[:user_nid],opt[:location_nid],opt[:recommendation_nid])
    elsif check_params(opt)
      Comment.search_by_unid_lnid(opt[:user_nid],opt[:location_nid])
    elsif val = opt[:user_nid]
      Comment.for_user_nid(val)
    elsif val = opt[:location_nid]
      Comment.for_location_nid(val)
    elsif val = opt[:recommendation_nid]
      Comment.for_recommendation_nid(val)
    else
      false
    end
  end

  # can only destroy one since the id is globally unique
  def self.destroy_nid(comment_nid)
    return false unless (comment_nid = Util.STRINGify(comment_nid))
    Comment.set(comment_nid,:text,Comment.removed_content_message)
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

  # simply find a comments nid
  def self.search_nid(nid)
    nid = Util.STRINGify(nid)
    Comment.find({ :_id => nid })
  end
  
  def self.for_user_nid(unid,options={})
    unid = Util.STRINGify(unid)
    Comment.for_all({ :unid => unid },options)
  end
  
  def self.for_recommendation_nid(rnid,options={})
    rnid = Util.STRINGify(rnid)
    Comment.for_all({ :rnid => rnid },options)
  end
  
  def self.check_user(opt,direct=false)
    return false if direct && opt[:about_user_nid].blank?
    return true if opt[:user_nid]
  end
  
  # The most granular can only be user comments on a recommendation about a location
  def self.check_recommendation(opt)
    return false unless Comment.check_user(opt)
    return true if opt[:recommendation_nid]
  end
  
  # user comments on a location only
  def self.check_location(opt)
    return false unless Comment.check_user(opt)
    return true if opt[:location_nid]
  end
  
  private
  # parent_comment_nid is for threadding (hit the reply button)
  def self.create(opt={})
    hash = {
      :text => opt[:text],
      :hash => opt[:hash],
      :unid  => Util.STRINGify(opt[:user_nid]),
      :lnid  => Util.STRINGify(opt[:location_nid])
    }
    hash.merge!({:pcid => Util.STRINGify(opt[:parent_nid])}) if opt[:parent_nid]
    hash.merge!({:abuid => opt[:about_user_nid]}) if opt[:about_user_nid]
    hash.merge!({:rnid  => Util.STRINGify(opt[:recommendation_nid])})  if opt[:recommendation_nid]
    
    Util.STRINGify(Comment.save(hash))
  end
  
  def self.for_all(finder,options={})
    the_limit = Util.limit(options[:limit])
    Comment.find(finder).sort([[ :_id, MONGO_ASC ]]).limit(the_limit)
  end
  
end