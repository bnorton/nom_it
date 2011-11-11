module Status
  class << self
    
    def message(status, message, options={})
      message = options[:message] || message
      {:status => status, :message => message, :results => []}
    end
    
    def OK(item=nil,options={})
      status_message_results(1,'OK',item,options)
    end
    
    def TOKEN(token)
      status_message_results(1,'OK',token,{:result_name=>:token})
    end
    
    def user_not_authorized
      message -1, "you are not authorized to view that user"
    end
    
    def user_found
      message -1, "the screen_name you were looking for is not available"
    end
    
    def thumb_created
      message 1, "the thumb was created succussfully"
    end
    
    def couldnt_create_new_thumb
      message -1, "the thumb you tried to create failed, make sure to include the :value param"
    end
    
    def couldnt_follow_or_unfollow
      message -1, "The specificed user couldn't be { followed, unfollowed }"
    end
    
    def no_followers
      message -1, "it appears that user dont { have any followers, follow anyone }"
    end
    
    def comments_not_found
      message -1, 'no comments were found for the specified item'
    end
    
    def recommendation_not(options={})
      word = options[:word] || "made"
      message -1, "The recommendation was not #{word}"
    end
    
    def couldnt_complete_recommendation(action)
      message -1, "Your request to #{action} the recommendation couldn't be completed :/"
    end
    
    def no_recommendations(options={})
      msg = options[:message] || "There were no recommendations for that #{options[:empty] || '{ user, location }'}"
      message -1, msg
    end
    
    def no_ranks_for(options={})
      msg = options[:message] || "There are no rankings for that #{options[:what]} yet :("
      message -1, msg
    end
    
    def insufficient_arguments(options={})
      msg = "insufficient or malformed argument #{options[:which]}" if options[:which]
      msg ||= options[:message] || "insufficient or malformed argument(s)"
      message -1, msg
    end
    
    def user_auth_invalid
      message -1, "authentication failed"
    end
    
    def unknown_error
      message -1, "an unknown error has occurred"
    end
    
    def thumbs(thmbs)success
      status_message_results(1,"fetched thumbs successfully",thumbs, {:result_name => :thumbs})
    end
    
    def user_detail(user)
      unless this = user.first
        message(-1,"no user found for the id")
      else
        status_message_results this.hashify?, 1, "OK"
      end
    end
    
    def user_session(user, session)
      unless user[0]
        message(-1,"no user found for the id")
      else
        # User.hashify!(user)
        response = status_message_results user, 1, "OK"
        response[:session] = session
        response
      end
    end

    def location_ranks(location,ranks)
      {
        :status => 1,
        :message => 'OK',
        :location => location,
        :ranks => ranks
      }
    end

    def ranks(ranks)
      {
        :status => 1,
        :message => 'OK',
        :ranks => ranks
      }
    end

    private
    
    def status_message_results(status,message,results,options)
      if results.nil?
        result_name = :message_detail
        results = 'everything went fine on our end'
      else
        result_name = options[:result_name] || :results
      end
      {
        :status      => status,
        :message     => message,
         result_name => results
      }
    end
    
    def location_not_properly_formatted(options={})
      example = 'id=lid'
      if options[:plural]
        s      = 's'
        example='ids=lid1,lid2,lid3'
      end
      message(-1, "The specified location#{s} were not properly formatted eg. #{example}")
    end
    
    def no_locations_found
      message(-1, "There were not locations found")
    end
  end
end
