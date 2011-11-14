module NOM
  class API
    class << self
      def api_prefix
        { :prefix => "api.justnom.it" }
      end
      # users
      def me
        { :endpoint => "/users/me", :required => [:token], :optional => [:nid,:email], :example => "/users/me?token={some_token}", :description => {  } }
      end
      def login
        { :endpoint => "/users/login", :required => [:password], :optional => [:nid,:email], :example => "/users/login?nid={nid}&password={some_pass}", :description => {  } }
      end
      def register
        { :endpoint => "/users/register", :required => [:email,:password], :optional => [:name,:city,:regtype,:fb_hash,:tw_hash], :example => "/users/register?email={email@example.com}&password={some_pass}&name={real_name}", :description => {  } }
      end
      def usearch
        { :endpoint => "/users/search", :required => [:q], :optional => [:email,:screen_name], :example => "/users/search?q={nort}", :description => {  } }
      end
      def udetail
        { :endpoint => "/users/detail", :required => [:nid], :optional => [:nids], :example => "/users/detail?nids={comma,separated,nids}", :description => {  } }
      end
      def ucheck
        { :endpoint => "/users/check", :required => [:screen_name], :optional => [:timeout], :example => "/users/check?screen_name={some_screen_name}", :description => {  } }
      end
      def urecommended
        { :endpoint => "/users/{:nid}/recommended", :required => [:nid], :optional => [], :example => "/users/", :description => {  } }
      end
      def tcreate
        { :endpoint => "/users/{:nid}/thumbs/create", :required => [:nid,:user_nid,:value,:token], :optional => [], :example => "/users/", :description => {  } }
      end
      def uthumbs
        { :endpoint => "/users/{:nid}/thumbs", :required => [:nid], :optional => [], :example => "/users/", :description => {  } }
      end
      def uthumbed
        { :endpoint => "/users/{:nid}/thumbed", :required => [:nid], :optional => [], :example => "/users/", :description => {  } }
      end
      
      #locations
      def lcreate
        { :endpoint => "/locations/create", :required => [:nid,:token,:lat,:lng,:name,:primary], :optional => [:text,:street,:city,:secondary], :example => "/locations/create", :description => {  } }
      end
      def lsearch
        { :endpoint => "/locations/search", :required => [:q], :optional => [:nid,:lat,:lng,:street,:city], :example => "/locations/search", :description => {  } }
      end
      def here
        { :endpoint => "/locations/here", :required => [:lat,:lng], :optional => [:dist,:primary,:secondary,:cost], :example => "/locations/here?lat=37.337&lng=-122.247&dist=0.625", :description => {  } }
      end
      def ldetail
        { :endpoint => "/locations/detail", :required => [:nid], :optional => [:nids], :example => "/locations/detail?nids={comma,separated,nids}", :description => {  } }
      end
      def rrecommendatons
        { :endpoint => "/locations/{:nid}/recommendations", :required => [:nid], :optional => [], :example => "/locations/{:nid}/recommendations", :description => {  } }
      end
      def tcreate
        { :endpoint => "/locations/{:nid}/thumbs/create", :required => [:nid], :optional => [], :example => "/locations/", :description => {  } }
      end
      def rthumbs
        { :endpoint => "/locations/{:nid}/thumbs", :required => [:nid], :optional => [], :example => "/locations/", :description => {  } }
      end
      
      # recommendations
      def rcreate
        { :endpoint => "/recommendations/create", :required => [], :optional => [], :example => "/recommendations/", :description => {  } }
      end
      def rdestroy
        { :endpoint => "/recommendations/destroy", :required => [], :optional => [], :example => "/recommendations/", :description => {  } }
      end
      
      # comments
      def ccreate
        { :endpoint => "/comments/create", :required => [], :optional => [], :example => "/comments/", :description => {  } }
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
    end
  end
end