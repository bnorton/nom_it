NomIt::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  get "/r/:hash"            => "details#detail"
  
  #############################################################################
  #####  USERS  ###############################################################
  #############################################################################
  get "/user/me"            => "users#me"                              ### POST
  
  get "/user/:nid/login"    => "users#login"                           ### POST
  get "/user/register"      => "users#register"                        ### POST
  get "/user/check"         => "users#check"
    
  get "/user/search"       => "users#search"
  get "/users/:nid/detail" => "users#detail"
  
  #############################################################################
  #####  FOLLOWERS  ###########################################################
  #############################################################################
  get "/follow/create"      => "followers#create"                      ### POST
  get "/follow/destroy"     => "followers#destroy"                     ### POST
  
  get "/followers"          => "followers#who_follows_id"
  get "/follows"            => "followers#followers"
  
  get "/user/:nid/followers" => "followers#who_follows_id"
  get "/user/:nid/follows"   => "followers#followers"
  
  #############################################################################
  #####  RECOMMENDATIONS  #####################################################
  #############################################################################
  get "/recommendation/create"       => "recommendations#create"       ### POST
  get "/recommendation/destroy"      => "recommendations#destroy"      ### POST
  get "/recommendation/update"       => "recommendations#update"       ### POST
  
  get "/recommendations/user/:nid"    => "recommendations#to_user"
  get "/recommendations/location/:nid"=> "recommendations#about_location"
  
  get "/location/:nid/recommends"     => "recommendations#location"
  
  #############################################################################
  #####  LOCATIONS  ###########################################################
  #############################################################################
  get "/locations/create"   => "locations#create"                       ## POST
  get "/locations/search"   => "geolocations#search"
  get "/locations/here"     => "geolocations#here"
  
  #############################################################################
  #####  COMMENTS  ############################################################
  #############################################################################
  get "/recommendation/:nid/comments" => "comments#recommendation"
  get "/location/:nid/comments"       => "comments#location"
  get "/user/:nid/comments"           => "comments#user"
  
  get "/comments/search"             => "comments#search"
  get "/comment/create"              => "comments#create"               ## POST
  
  #############################################################################
  #####  THUMBS  ##############################################################
  #############################################################################
  get "location/:nid/thumb"  => "locations#thumb_create"                ## POST
  get "location/:nid/thumbs" => "locations#thumbs"
  
  get "user/:nid/thumb/create"=> "users#thumb_create"                   ## POST
  get "user/:nid/thumbs"      => "user#thumbs"
  get "user/:nid/thumbed"     => "user#thumbed"                         ## POST
  #############################################################################
  #####  RANKING  #############################################################
  #############################################################################
  get "/rank/create"        => "rankings#create"                        ## POST
  get "/rank/update"        => "rankings#create"                        ## POST
  get "/rank/destory"       => "rankings#destory"                       ## POST
  
  get "user/:nid/ranked"    => "rankings#user"
  get "location/:nid/ranks" => "rankings#location"
  
  #############################################################################
  #####  USERS  ###############################################################
  #############################################################################

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
