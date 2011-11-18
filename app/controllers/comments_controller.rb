class CommentsController < ApplicationController
  
  respond_to :json
  
  before_filter :lat_lng_user
  before_filter :check_params,  :only => [:recommendation,:location,:user]
  before_filter :search_params, :only => [:search,:create]
  
  def recommendation
    comments 'recommendation'
  end
  
  def location
    comments 'location'
  end
  
  def user
    comments 'user'
  end
  
  def search
    comments = Comment.search(@search)
    prepared = Util.prepare(comments)
    respond_with ok_or_not(prepared)
  end
  
  def create
    nid = if @search[:recommendation_nid]
      Comment.create_comment_for_recommendation(@search)
    elsif @search[:location_nid]
      Comment.create_comment_for_location(@search)
    elsif @search[:about_user_nid]
      Comment.create_comment_about_user(@search)
    end
    message = nid ? [{:comment_nid=>Util.STRINGify(nid)}] : nil
    respond_with ok_or_not(message)
  end
  
  private 
  
  def comments(method_name)
    comments = Comment.send("for_#{method_name}_nid".to_sym, @nid, {:start=>@start,:limit=>@limit})
    prepared = Util.prepare(comments)
    respond_with ok_or_not(prepared)
  end
  
  def ok_or_not(comments)
    unless comments.blank?
      Status.OK(comments,{:result_name=>:comments})
    else
      Status.comments_not_found
    end
  end
  
  def check_params
    @nid = params[:comment_nid]
    @start = params[:start]
    @limit = params[:limit]
    if @nid.blank?
      respond_with Status.comments_not_found
    end
  end
  
  def search_params
    @search = {
      :comment_nid  => params[:comment_nid],
      :user_nid => @user_nid,
      :location_nid => params[:location_nid],
      :recommendation_nid => params[:recommendation_nid],
      :text => params[:text]
    }
    unless @search[:comment_nid] || @search[:user_nid] || @search[:location_nid] || @search[:recommendation_nid] || @search[:text]
      respond_with Status.insufficient_arguments({
        :message=>"must have a `comment_nid`, `user_nid`, `location_nid` ,`recommendation_nid`, or some `text`"})
    end
  end
  
  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @user_nid = params[:user_nid]
  end

end