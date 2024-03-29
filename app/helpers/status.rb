module Status
  class << self
    
    def method_missing(method_name, *args)
      unknown_error
    end
    
    def message(status, message, options={})
      message = options[:message] || message
      {:status => status, :message => message, :results => []}
    end
    
    def OK(item=nil,options={})
      status_message_results(1,'OK',item,options)
    end
    
    def TOKEN(token)
      status_message_results(1,'OK',token) #,{:result_name=>:token})
    end
    
    def SEARCHED(token,dist)
      m = OK(token)
      m.merge!({:distance => dist}) if dist.present?
      m
    end
    
    def user_not_authorized
      message(-1, "You are not authorized as that user")
    end
    
    def user_login_failed
      message(-1,"You've registered but login failed")
    end
    
    def image_saved(image_nid)
      d = [{:image_nid => image_nid}]
      status_message_results(1,'Image uploaded seccessfully',d)
    end
    
    def user_image_created(img_r)
      status_message_results(1, 'User avatar created', img_r)
    end
    
    def screen_name_taken
      message(-2, "The handle you entered was not available")
    end
    
    def search_result(results)
      status_message_results(1,'OK',results)
    end

    def follow_list(list,options={})
      status_message_results(1,'OK',list,options)
    end

    def insufficient_arguments(options={})
      msg = "insufficient or malformed argument #{options[:which]}" if options[:which]
      msg ||= options[:message] || "insufficient or malformed argument(s)"
      message(-1, msg)
    end

    def user_auth_invalid
      message(-1, "User authentication via auth_token failed")
    end

    def not_found(what_is_it='items')
      message(1,"no #{what_is_it} were found.")
    end

    def item_not_destroyed(what='item')
      message(-1,"The #{what} could not be destroyed")
    end
    
    def item_destroyed(what='item')
      message(1,"The #{what} was destroyed successfully")
    end
    
    def item_not_created(what='item')
      message(-1,"The #{what} could not be created")
    end
    
    def item_created(what='item')
      message(1,"The #{what} was created successfully")
    end
    
    def item_not_created_destroyed(what='item')
      message(1,"The #{what} was not created/destroyed successfully")
    end

    def item_created_destroyed(what='item')
      message(1,"The #{what} was created/destroyed successfully")
    end
    
    def unknown_error
      message(-1, "An API error has occurred")
    end

    def location_ranks(location,ranks)
      {
        :status => 1,
        :message => 'OK',
        :location => location,
        :ranks => ranks
      }
    end

    def not_properly_formatted(options={})
      str = "The specified #{options[:item] || 'item'}"
      if options[:plural]
        str << 's were '
      else
        str << ' was '
      end
      str << 'not properly formatted'
      if options[:example]
        str << " eg. #{options[:example]}"
      end
      message(-1, str)
    end

    private
    
    def status_message_results(status,message,results,options={})
      results ||= []
      {
        :status      => status,
        :message     => message,
        :results => Array(results)
      }
    end
  end
end
