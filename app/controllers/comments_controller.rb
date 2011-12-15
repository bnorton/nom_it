class CommentsController < ApplicationController
  
  respond_to :json
  
  before_filter :lat_lng_user
  before_filter :other_params
  before_filter :search_params
  before_filter :authentication_required, :only => [:create]
  
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
    elsif @search[:to_user_nid]
      Comment.create_comment_about_user(@search)
    end
    message = nid ? {:comment_nid=>Util.STRINGify(nid)} : nil
    respond_with ok_or_not(message), :location => nil
  end
  
  private 
  
  def comments(method_name)
    comments = Comment.search(@search, {:start=>@start,:limit=>@limit})
    prepared = Util.prepare(comments)
    respond_with ok_or_not(prepared)
  end
  
  def ok_or_not(comments)
    unless comments.blank?
      Status.OK(comments)#,{:result_name=>:comments})
    else
      Status.not_found 'comments'
    end
  end
  
  def other_params
    @comment_nid = params[:comment_nid]
    @start = params[:start]
    @limit = Util.limit(params[:limit])
    if @comment_nid.blank?
      respond_with Status.comments_not_found, :location => nil
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

  def authentication_required
    @auth_token = params[:auth_token]
    unless @auth_token.present? && User.valid_session?(@user_nid, @auth_token)
      respond_with Status.user_auth_invalid, :location => nil
    end
  end

end