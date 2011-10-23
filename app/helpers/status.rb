module Status
  class << self
    
    def message(status, message, options={})
      message = options[:message] || message
      {:status => status, :message => message, :results => []}
    end
    
    def OK(item,options={})
      status_message_results(1,'OK',item,options)
    end
    
    def user_not_authorized
      message -1, "you are not authorized to view that user"
    end
    
    def insufficient_arguments(options={})
      msg = options[:message] || "insufficient arguments"
      message -1, msg
    end
    
    def user_auth_invalid
      message -1, "authentication failed"
    end
    
    def unknown_error
      message -1, "an unknown error has occurred"
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
    
    private
    
    def status_message_results(status,message,results,options)
      result_name = options[:result_name] || :results 
      {
        :status  => status,
        :message => message,
         result_name => results
      }
    end
    
    def location_not_properly_formatted(options={})
      example = 'id=locationid'
      if options[:plural]
        s      = 's'
        example='ids=id1,id2,id3'
      end
      message(-1, "The specified location#{s} were not properly formatted eg. #{example}")
    end
    
    def no_locations_found
      message(-1, "There were not locations found")
    end
  end
end