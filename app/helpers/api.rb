module NOM
  class API
    class << self
      def api_prefix
        { :prefix => "justnom.it" }
      end
      # users
      def me
        { :endpoint => "/users/me", :required => [:auth_token], :optional => [:user_nid,:email], :example => "/users/me?auth_token={your_auth_token}", :description => {  } }
      end
      def login
        { :endpoint => "/users/login", :required => [:password], :optional => [:user_nid,:email], :example => "/users/login?user_nid={user_nid}&password={some_pass}", :description => {  } }
      end
      def register
        { :endpoint => "/users/register", :required => [:email,:password], :optional => [:name,:city,:regtype,:fb_hash,:tw_hash], :example => "/users/register?email={email@example.com}&password={some_pass}&name={real_name}", :description => {  } }
      end
      def usearch
        { :endpoint => "/users/search", :required => [:q], :optional => [:email,:screen_name], :example => "/users/search?q={nort}", :description => {  } }
      end
      def udetail
        { :endpoint => "/users/detail", :required => [:user_nid], :optional => [:user_nids], :example => "/users/detail?user_nids={comma,separated,user_nids}", :description => {  } }
      end
      def ucheck
        { :endpoint => "/users/check", :required => [:screen_name], :optional => [:timeout], :example => "/users/check?screen_name={some_screen_name}", :description => {  } }
      end
      def urecommended
        { :endpoint => "/users/{:user_nid}/recommended", :required => [:user_nid], :optional => [], :example => "/users/", :description => {  } }
      end
      def tnew
        { :endpoint => "/users/{:user_nid}/thumbs/new", :required => [:user_nid,:value,:auth_token], :optional => [:location_nid,:to_user_nid], :example => "/users/", :description => {  } }
      end
      def uthumbs
        { :endpoint => "/users/{:user_nid}/thumbs", :required => [:user_nid], :optional => [], :example => "/users/", :description => {  } }
      end
      def uthumbed
        { :endpoint => "/users/{:user_nid}/thumbed", :required => [:user_nid], :optional => [], :example => "/users/", :description => {  } }
      end
      
      #locations
      def lnew
        { :endpoint => "/locations/new", :required => [:user_nid,:auth_token,:lat,:lng,:name,:primary], :optional => [:text,:street,:city,:secondary], :example => "/locations/new", :description => {  } }
      end
      def lsearch
        { :endpoint => "/locations/search", :required => [:q], :optional => [:location_nid,:lat,:lng,:street,:city], :example => "/locations/search", :description => {  } }
      end
      def here
        { :endpoint => "/locations/here", :required => [:lat,:lng], :optional => [:dist,:primary,:secondary,:cost], :example => "/locations/here?lat=37.337&lng=-122.247&dist=0.625", :description => {  } }
      end
      def ldetail
        { :endpoint => "/locations/detail", :required => [:location_nid], :optional => [:location_nids], :example => "/locations/detail?location_nids={comma,separated,location_nids}", :description => {  } }
      end
      def rrecommendatons
        { :endpoint => "/locations/{:location_nid}/recommendations", :required => [:location_nid], :optional => [], :example => "/locations/{:location_nid}/recommendations", :description => {  } }
      end
      def tnew
        { :endpoint => "/locations/{:location_nid}/thumbs/new", :required => [:location_nid,:user_nid,:value,:auth_token], :optional => [], :example => "/locations/", :description => {  } }
      end
      def rthumbs
        { :endpoint => "/locations/{:location_nid}/thumbs", :required => [:location_nid], :optional => [], :example => "/locations/", :description => {  } }
      end
      
      # recommendations
      def rnew
        { :endpoint => "/recommendations/new", :required => [:location_nid,:user_nid,:text], :optional => [], :example => "/recommendations/", :description => {  } }
      end
      def rdestroy
        { :endpoint => "/recommendations/destroy", :required => [], :optional => [], :example => "/recommendations/", :description => {  } }
      end
      
      # comments
      def cnew
        { :endpoint => "/comments/new", :required => [], :optional => [], :example => "/comments/", :description => {  } }
      end
      def crecommendation
        { :endpoint => "/comments/recommendation", :required => [], :optional => [], :example => "/comments/", :description => {  } }
      end
      def clocation
        { :endpoint => "/comments/location", :required => [], :optional => [], :example => "/comments/", :description => {  } }
      end
      def cuser
        { :endpoint => "/comments/user", :required => [], :optional => [], :example => "/comments/", :description => {  } }
      end
      def csearch
        { :endpoint => "/comments/search", :required => [], :optional => [], :example => "/comments/", :description => {  } }
      end
      
      # followers
      def followers
        { :endpoint => "/comments/user", :required => [], :optional => [], :example => "/comments/", :description => {  } }
      end
      def following
        { :endpoint => "/comments/search", :required => [], :optional => [], :example => "/comments/", :description => {  } }
      end

    end
  end
end