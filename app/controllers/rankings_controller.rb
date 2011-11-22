class RankingsController < ApplicationController
  
  respond_to :json
  
  before_filter :lat_lng_user
  before_filter :creation, :only => [:create]
  before_filter :destruction, :only => [:destroy]
  before_filter :user_params, :only => [:user]
  before_filter :location_params, :only => [:location]
  
  # Ranking.new_rank(nid,unid,value,text='')
  # Ranking.remove_rank(nid,unid)
  # Ranking.for_unid(unid)
  # Ranking.for_nid(nid)
  
  # RankingAverage.new_ranking(nid,rating)
  # RankingAverage.remove_ranking(nid,old_value)
  # RankingAverage.ranking(nid)
  # RankingAverage.total(nid)
  # RankingAverage.ranking_total(nid)
  
  def create
    success = Ranking.new_rank(@location_nid,@user_nid,@rank)
    respond_with ok_or_not({:oper => success})
  end
  
  def destroy
    success = if (@rank_nid)
      Ranking.remove_rank_nid(@rank_nid)
    else
      Ranking.remove_ranking(@location_nid,@user_nid,@rank)
    end
    respond_with ok_or_not({:oper => success,:remove => true})
  end
  
  def by_user
    @key = :rank_nid
    @rankings = Ranking.for_unid(@user_nid,@limit,@key)
    @rank_loc = Ranking.build_list @rankings
    respond_with ok_or_not({
      :items => @rank_loc,
      :what => 'user'})
  end
  
  def location
    @key = :rank_nid
    @rankings = Ranking.for_nid(@location_nid,@limit,@key)
    if @rankings.length > 0
      @location = Location.detail_for_nid(@location_nid)
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
    elsif options[:oper]
      if options[:remove]
        Status.rank_action({:which => 'removed'})
      else
        Status.rank_action({:which => 'created'})
      end
    else
      Status.no_ranks_for(options)
    end
  end
  
  def render_insufficient
    respond_with Status.insufficient_arguments
  end
  
  def user_params
    render_insufficient unless (@user_nid = params[:user_nid])
    @limit = Util.limit(params[:limit])
  end
  
  def location_params
    render_insufficient unless (@location_nid = params[:location_nid])
    @limit = Util.limit(params[:limit])
  end
  
  # verifies the params of user_nid, nid, and rank
  def creation
    user_params
    location_params
    render_insufficient unless (@rank = params[:rank])
  end

  def destruction
    unless @rank_nid = params[:rank_nid]
      user_params
      location_params
    end
    render_insufficient unless (@rank = params[:rank])
  end
  
  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
  end

  
end