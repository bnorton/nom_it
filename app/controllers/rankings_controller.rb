class RankingsController < ApplicationController
  
  respond_to :json
  
  before_filter :creation, :only => [:create,:update,:destroy]
  before_filter :user_params, :only => [:user]
  before_filter :location_params, :only => [:location]
  
  # Ranking.new_rank(nid,uid,value,text='')
  # Ranking.remove_rank(nid,uid)
  # Ranking.for_uid(uid)
  # Ranking.for_nid(nid)
  
  # RankingAverage.new_ranking(nid,rating)
  # RankingAverage.update_ranking(nid,old_r,new_r)
  # RankingAverage.remove_ranking(nid,old_value)
  # RankingAverage.ranking(nid)
  # RankingAverage.total(nid)
  # RankingAverage.ranking_total(nid)
  
  def create
    Ranking.new_rank(@nid,@uid,@rank)
    respond_with Status.OK
  end
  
  def destroy
    Ranking.remove_ranking(@nid,@uid,@rank)
    respond_with Status.OK
  end
  
  def user
    @key = :ranking_id
    @rankings = Ranking.for_uid(@uid,@limit,@key) # a list of objects attr_accessor :nid, :uid, :v, :text, :cur
    # now just get the locations that are associated with these rankings
    @rank_loc = Ranking.build_list @rankings, @key
    respond_with ok_or_not(@rank_loc,{})
  end
  
  def location
    @key = :location_id
    @rankings = Ranking.for_nid(@nid,@limit,@key) # a list of objects attr_accessor :nid, :uid, :v, :text, :cur
    unless @rankings.length > 0
      respond_with Status.no_ranks_for_location
    end
    @location = Location.detail_for_nids([@nid])
    respond_with ok_or_not(@location,options={
      :location=>@location,
      :ranks => @rankings})
  end
  
  private
  
  def ok_or_not(items,wrapper={},options={})
    unless items.blank?
      if (loc = options[:location])
        Status.location_ranks(1,loc,options[:ranks])
      else
        Status.user_ranks()
      end
    Status.
  end
  
  def merge
    
  end
  
  def render_insufficient
    respind_with Status.insufficient_arguments
  end
  
  def user_params
    render_insufficient unless (@uid = params[:user_id])
    @limit = params[:limit] || 20
  end
  
  def location_params
    render_insufficient unless (@nid = params[:nid])
    @limit = params[:limit] || 20
  end
  
  # verifies the params of user_id, nid, and rank
  def creation
    user_params
    location_params
    render_insufficient unless (@rank = params[:rank])
  end
  
end