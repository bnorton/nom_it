NomIt::Application.routes.draw do
  
  get "/r/:hash"            => "details#detail"
  
  post "/images/create" => 'images#create'
  #############################################################################
  #####  USERS  ###############################################################
  #############################################################################
  get "/users/me"            => "users#me"                             ### POST
  
  get "/users/login"         => "users#login"                          ### POST
  get "/users/register"      => "users#register"                       ### POST
  get "/users/check"         => "users#check"
    
  get "/users/search"        => "users#search"
  get "/users/:nid/detail"   => "users#detail"
  
  #############################################################################
  #####  FOLLOWERS  ###########################################################
  #############################################################################
  get "/follow/create"      => "followers#create"                      ### POST
  get "/follow/destroy"     => "followers#destroy"                     ### POST
  
  get "/users/:nid/followers" => "followers#who_follows_nid"
  get "/users/:nid/following" => "followers#following"
  
  #############################################################################
  #####  RECOMMENDATIONS  #####################################################
  #############################################################################
  get "/recommendation/create"       => "recommendations#create"       ### POST
  get "/recommendation/destroy"      => "recommendations#destroy"      ### POST
  get "/recommendation/update"       => "recommendations#update"       ### POST
  
  get "/users/:nid/recommended"    => "recommendations#user"
  get "/locations/:nid/recommended"=> "recommendations#location"
  
  #############################################################################
  #####  LOCATIONS  ###########################################################
  #############################################################################
  get "/locations/create" => "locations#create"                         ## POST
  get "/locations/search" => "locations#search"
  get "/locations/here"   => "locations#here"
  
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
  get "locations/:nid/thumbs/create"  => "locations#thumb_create"       ## POST
  get "locations/:nid/thumbs" => "locations#thumbs"
  
  get "users/:nid/thumbs/create"=> "users#thumb_create"                 ## POST
  get "users/:nid/thumbs"      => "user#thumbs"
  get "users/:nid/thumbed"     => "user#thumbed"                        ## POST
  #############################################################################
  #####  RANKING  #############################################################
  #############################################################################
  get "/rankings/create"        => "rankings#create"                    ## POST
  get "/rankings/update"        => "rankings#create"                    ## POST
  get "/rankings/destory"       => "rankings#destory"                   ## POST
  
  get "user/:nid/ranked"        => "rankings#user"
  get "location/:nid/rankings"  => "rankings#location"
  
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
