
class UsersController < ApplicationController
  
  respond_to :json

  before_filter :lat_lng_user
  before_filter :user_params,       :only => [:me,:login,:register,:thumbs,:thumbed]
  before_filter :auth_params,       :only => [:me,:login,:register]
  before_filter :login_required,    :only => [:login]
  before_filter :search_params,     :only => [:search]
  before_filter :validate_nids,     :only => [:detail,:thumbs,:thumbed]
  before_filter :authentication_required, :only => [:me,:thumb_create,:user_image]
  before_filter :activity_requires,  :only => [:activity]

  def check
    @screen_name = params[:screen_name]
    response = if @screen_name.blank?
      Status.insufficient_arguments
    else
      if User.find_by_screen_name(@screen_name).blank?
        ok_or_not(true,{:results => [{:reserved_until => Time.now.utc + 2.minutes}]})
      else
        ok_or_not(false,{:name_taken=>true})
      end
    end
    respond_with response, :location => nil
  end

  def register
    registration = case @registration_type
      when 'facebook'
        User.register_with_facebook(@FBHash,@user_nid,@email,@fb_access_token)
      when 'twitter'
        User.register_with_twitter(@TWHash)
      when 'nom'
        if (reg = User.register(@email, @password, @screen_name, @name, @city)) == 'login_failed'
          respond_with(Status.user_login_failed, :location => nil)
          return
        end
        reg
      end
    response = ok_or_not(registration.present?,{:results=>registration})
    respond_with response, :location => nil
  end

  def login
    condition = User.login(@email_or_nid,@password,@screen_name)
    if condition == 'login_failed'
      respond_with((Status.user_login_failed), :location => nil)
      return
    end
    response  = ok_or_not(condition,{:results=>[{:logged_in=>true}]})
    respond_with response, :location => nil
  end

  def me
    me = User.me(@auth_token)
    respond_with Status.OK(me), :location => nil
  end

  def detail
    results   = User.detail_for_nids(@user_nids,@limit)
    condition = !results.blank?
    response  = ok_or_not(condition,{:results=>results})
    respond_with response
  end

  def search
    @query ||= @screen_name || @email
    results   = User.search_by_all(@query,@limit)
    condition = results.present?
    response  = ok_or_not(condition,{:results=>results,:search=>true})
    respond_with response
  end

  def activity
    resp = { :status => 1, :message => 'OK' }
    if params[:by_user_nid]
      recommendations = Recommendation.for_user(@by_user_nid, @limit)
      resp.merge!({:recommendations => recommendations})
      thumbs_for_who = @by_user_nid
    else
      recommends = Recommend.for_user_nid(@user_nid,@limit)
      resp.merge!({:recommends => recommends})
      thumbs_for_who = Follower.followers_nids(@user_nid)
    end
    thumbs = Thumb.for_unids(thumbs_for_who,@limit)
    resp.merge!({:thumbs => thumbs})
    respond_with resp
  end

  def user_image
    if(user = User.find_by_user_nid(@user_nid))
      image = Image.new(@image)
      inid = Util.ID
      image.image_nid = inid
      image.user_nid = @user_nid
      resp = if image.save
        Status.user_image_created Image.build_image(Image.find_by_image_nid(inid))
      else
        Status.item_not_created 'user_image'
      end
      respond_with resp, :location => nil
    end
  end

  private

  def ok_or_not(condition,options={})
    if condition && (detail = options[:results])
      Status.OK(detail)
    elsif options[:name_taken]
      Status.screen_name_taken
    elsif options[:search]
      if condition
        Status.search_result(results)
      else
        Status.not_found 'users'
      end
    else
      Status.user_not_authorized
    end
  end

  def login_required
    unless (@email.present? || @user_nid.present? || @screen_name.present?) && @password.present?
      respond_with Status.user_not_authorized, :location => nil
    end
  end

  def user_params
    @user_nid = params[:user_nid]
    @to_user_nid = params[:to_user_nid]
    @email = params[:email]
    @screen_name  = params[:screen_name]
    @FBHash = params[:fbhash]
    @fb_access_token = params[:fb_access_token]
    @TWHash = params[:twhash]
    @name = params[:name]
    @city = params[:city]
  end

  def auth_params
    @email_or_nid = @user_nid || @email
    @password = params[:password]
    @registration_type = params[:regtype] || 'nom'
  end

  def search_params
    @query = params[:query] || params[:q]
    @screen_name = params[:screen_name]
    @email = params[:email]
    unless @query.present? || @screen_name.present? || @email.present?
      respond_with Status.insufficient_arguments
    end
  end

  def validate_nids
    @user_nid  = params[:user_nid]
    @user_nids = params[:user_nids] || ''
    if @user_nids.present?
      @user_nids << ",#{@user_nid}" if @user_nid.present?
    else
      @user_nids << @user_nid if @user_nid.present?
    end
    if @user_nids.blank? || !(@user_nids =~ NID_LIST)
      respond_with Status.insufficient_arguments
    end
  end

  def activity_requires
    if params[:by_user_nid]
      unless (@by_user_nid = params[:by_user_nid]).present?
        respond_with Status.insufficient_arguments
      end
    else
      validate_nids
    end
  end

  def authentication_required
    @auth_token = params[:auth_token]
    unless @auth_token.present? && User.valid_session?(@user_nid, @auth_token)
      respond_with Status.user_not_authorized, :location => nil
    end
  end

  def lat_lng_user
    @lat  = params[:lat]
    @lng  = params[:lng]
    @limit  = Util.limit(params[:limit],10)
    @user_nid = params[:user_nid]
  end
end
