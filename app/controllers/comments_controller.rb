class CommentsController < ApplicationController
  
  respond_to :json
  
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
    nid = if @search[:rnid] && @search[:lnid]
      Comment.create_comment_for_recommendation(@search)
    else
      Comment.create_comment_for_location(@search)
    end
    message = nid ? [{:nid=>nid.to_s}] : nil
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
    @nid    = params[:nid]
    @start = params[:start]
    @limit = params[:limit]
    unless (!@nid.blank? && @nid = @nid)
      respond_with Status.comments_not_found
    end
  end
  
  def search_params
    @search = {
      :nid  => params[:nid],
      :unid  => params[:unid],
      :lnid  => params[:lnid],
      :rnid  => params[:rnid],
      :text => params[:text]
    }
    unless @search[:nid] || @search[:unid] || @search[:lnid] || @search[:rnid] || @search[:text]
      respond_with Status.insufficient_arguments({
        :message=>"must have a `nid`, `unid`, `lnid` ,`rnid`, or some `text`"})
    end
  end
  
end