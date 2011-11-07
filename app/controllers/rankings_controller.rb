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
    @key = :rank_id
    @rankings = Ranking.for_uid(@uid,@limit,@key) # a list of objects attr_accessor :nid, :uid, :v, :text, :cur
    @rank_loc = Ranking.build_list @rankings      # now just get the locations that are associated with these rankings
    respond_with ok_or_not({
      :items => @rank_loc,
      :what => 'user'})
  end
  
  def location
    @key = :rank_id
    @rankings = Ranking.for_nid(@nid,@limit,@key) # a list of objects attr_accessor :nid, :uid, :v, :text, :cur
    if @rankings.length > 0
      @location = Location.detail_for_nid(@nid)
      respond_with ok_or_not({
        :location=>@location,
        :ranks => @rankings,
        :what => 'location'})
    else
      respond_with Status.no_ranks_for({:what => 'location'})
    end
  end
  
  private
  
  def ok_or_not(options={})
    if ((loc = options[:location]) && (ranks = options[:ranks]))
      Status.location_ranks(loc,ranks)
    elsif (items = options[:items])
      Status.ranks(items)
    else
      Status.no_ranks_for(options)
    end
  end
  
  def render_insufficient
    respond_with Status.insufficient_arguments
  end
  
  def user_params
    render_insufficient unless (@uid = params[:nid])
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