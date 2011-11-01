NomIt::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  get "/r/:hash"            => "details#detail"
  
  get "/user/me"            => "users#me"                 ### POST
  
  get "/user/login"         => "users#login"              ### POST
  get "/user/register"      => "users#register"           ### POST
  get "/user/check"         => "users#check"
    
  get "/users/search"       => "users#search"
  get "/users/detail"       => "users#detail"

  
  get "/follow/create"      => "followers#create"         ### POST
  get "/follow/destroy"     => "followers#destroy"        ### POST
  
  get "/followers"          => "followers#who_follows_id"
  get "/follows"            => "followers#followers"
  
  get "/user/:id/followers" => "followers#who_follows_id"
  get "/user/:id/follows"   => "followers#followers"
  
  get "/locations/search"   => "geolocations#search"
  get "/locations/here"     => "geolocations#here"
  
  get "/recommendation/:id/comments" => "comments#recommendation"
  get "/location/:id/comments"       => "comments#location"
  get "/user/:id/comments"           => "comments#user"
  
  get "/comments/search"             => "comments#search"
  get "/comment/create"              => "comments#create"
  
  get "/recommendation/create"       => "recommendations#create"    ### POST
  get "/recommendation/destroy"      => "recommendations#destroy"   ### POST
  get "/recommendation/update"       => "recommendations#update"    ### POST
  
  get "/recommendations/user/:id"    => "recommendations#to_user"
  get "/recommendations/location/:id"=> "recommendations#about_location"
  
  get "/location/:id/recommends"     => "recommendations#location"
  
  
  
  root :to => "detail#index"

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
