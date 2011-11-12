class Api
  class << self
  
    # users
    def login
      { :endpoint => "api.justnom.it/users/login", :required => [:password], :optional => [:nid,:email], :example => "api.justnom.it/users/login?nid={nid}&password={some_pass}" }
    end
    def register
      { :endpoint => "api.justnom.it/users/register", :required => [:email,:password], :optional => [:regtype,:fb_hash,:tw_hash], :example => "api.justnom.it/users/register?email={email@example.com}&password=some_pass" }
    end
    def usearch
      { :endpoint => "api.justnom.it/users/search", :required => [], :optional => [:q,:email,:screen_name], :example => "api.justnom.it/users/search?q=nort" }
    end
    def udetail
      { :endpoint => "api.justnom.it/users/detail", :required => [:nid], :optional => [:token], :example => "api.justnom.it/users/detail?nids={comma,separated,nids}" }
    end
    def ucheck
      { :endpoint => "api.justnom.it/users/check", :required => [:screen_name], :optional => [:timeout], :example => "api.justnom.it/users/check?screen_name=nort" }
    end
    def urecommended
      { :endpoint => "api.justnom.it/", :required => [:nid], :optional => [], :example => "api.justnom.it/users/" }
    end
    def tcreate
      { :endpoint => "api.justnom.it/users/:nid/thumbs/create", :required => [:user_nid,:value,:token], :optional => [], :example => "api.justnom.it/users/" }
    end
    def uthumbs
      { :endpoint => "api.justnom.it/users/:nid/thumbs", :required => [], :optional => [], :example => "api.justnom.it/users/" }
    end
    def uthumbed
      { :endpoint => "api.justnom.it/users/:nid/thumbed", :required => [], :optional => [], :example => "api.justnom.it/users/" }
    end
    
    #locations
    def lcreate
      { :endpoint => "api.justnom.it/locations/create", :required => [:nid,:token,:lat,:lng,:name,:primary], :optional => [:text,:street,:city,:secondary], :example => "api.justnom.it/locations/" }
    end
    def lsearch
      { :endpoint => "api.justnom.it/", :required => [:q], :optional => [:nid,:lat,:lng,:street,:city], :example => "api.justnom.it/locations/" }
    end
    def here
      { :endpoint => "api.justnom.it/", :required => [:lat,:lng], :optional => [:dist], :example => "api.justnom.it/locations/" }
    end
    def ldetail
      { :endpoint => "api.justnom.it/", :required => [:nid], :optional => [], :example => "api.justnom.it/locations/" }
    end
    def rrecommendatons
      { :endpoint => "api.justnom.it/", :required => [], :optional => [], :example => "api.justnom.it/locations/" }
    end
    def tcreate
      { :endpoint => "api.justnom.it/", :required => [], :optional => [], :example => "api.justnom.it/locations/" }
    end
    def rthumbs
      { :endpoint => "api.justnom.it/", :required => [], :optional => [], :example => "api.justnom.it/locations/" }
    end
    
    # recommendations
    def rcreate
      { :endpoint => "api.justnom.it/", :required => [], :optional => [], :example => "api.justnom.it/recommendations/" }
    end
    def rdestroy
      { :endpoint => "api.justnom.it/", :required => [], :optional => [], :example => "api.justnom.it/recommendations/" }
    end
    def rupdate
      { :endpoint => "api.justnom.it/", :required => [], :optional => [], :example => "api.justnom.it/recommendations/" }
    end
    
    # thumbs
    def t
      { :endpoint => "api.justnom.it/", :required => [], :optional => [], :example => "api.justnom.it/" }
    end
    def d
      { :endpoint => "api.justnom.it/", :required => [], :optional => [], :example => "api.justnom.it/" }
    end
  
  end
end