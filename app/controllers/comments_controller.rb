class CommentsController < ApplicationController
  
  respond_to :json
  
  before_filter :check_params,  :only => [:recommendation,:location,:user]
  before_filter :search_params, :only => [:search]
  
  def recommendation
    comments 'recommendation'
  end
  
  def location
    comments 'location'
  end
  
  def user
    comments 'user'
  end
  
  def comments(method_name)
    comments = []
    all_coments = Comment.send("for_#{method_name}_id".to_sym, @id, {:start=>@start,:limit=>@limit})
    all_coments.each do |comment|
      comments << Util.nidify(comment)
    end
    condition = !comments.blank?
    respond_with ok_or_not(condition,comments)
  end
  
  def search
    respond_with '{"status":-10}'
  end
  
  def ok_or_not(condition,comments)
    if condition
      Status.OK(comments,{:result_name=>:comments})
    else
      Status.comments_not_found
    end
  end
  
  def check_params
    @id    = params[:id]
    @start = params[:start]
    @limit = params[:limit]
    unless (!@id.blank? && @id = @id.to_i)
      respond_with Status.comments_not_found
    end
  end
  
  def search_params
    
  end
  
end