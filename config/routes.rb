NomIt::Application.routes.draw do

  get '/r/:token' => 'details#detail'

  post '/images/create' => 'images#create'
  #############################################################################
  #####  USERS  ###############################################################
  #############################################################################
  post '/users/me'            => 'users#me'

  post '/users/login'         => 'users#login'
  post '/users/register'      => 'users#register'
  get  '/users/check'         => 'users#check'

  get  '/users/search'        => 'users#search'
  get  '/users/:user_nid/detail' => 'users#detail'

  #############################################################################
  #####  FOLLOWERS  ###########################################################
  #############################################################################
  post '/follow/create' => 'followers#create'
  post '/follow/destroy' => 'followers#destroy'

  get '/followers' => 'followers#followers'
  get '/following' => 'followers#following'

  get '/followers/list' => 'followers#followers_list'
  get '/following/list' => 'followers#following_list'

  #############################################################################
  #####  RECOMMENDATIONS  #####################################################
  #############################################################################
  post '/recommendation/create' => 'recommendations#create'
  post '/recommendation/destroy' => 'recommendations#destroy'

  get '/users/:user_nid/recommended' => 'recommendations#user'
  get '/locations/:location_nid/recommended' => 'recommendations#location'

  #############################################################################
  #####  LOCATIONS  ###########################################################
  #############################################################################
  post '/locations/create' => 'locations#create'
  get '/locations/search' => 'locations#search'
  get '/locations/here'   => 'locations#here'

  #############################################################################
  #####  COMMENTS  ############################################################
  #############################################################################
  get '/recommendation/:recommendation_nid/comments' => 'comments#recommendation'
  get '/location/:location_nid/comments' => 'comments#location'
  get '/user/:user_nid/comments' => 'comments#user'

  get '/comments/search' => 'comments#search'
  post '/comment/create' => 'comments#create'

  #############################################################################
  #####  THUMBS  ##############################################################
  #############################################################################
  post 'locations/:location_nid/thumbs/create' => 'thumbs#location_new'
  get 'locations/:location_nid/thumbs' => 'thumbs#thumbs'

  post 'users/:user_nid/thumbs/create' => 'thumbs#user_new'
  get 'users/:user_nid/thumbs' => 'user#thumbs'
  get 'users/:user_nid/thumbed' => 'user#thumbed'

  #############################################################################
  #####  RANKING  #############################################################
  #############################################################################
  post '/rankings/create' => 'rankings#create'
  post '/rankings/update' => 'rankings#create'
  post '/rankings/destory' => 'rankings#destory'

  get 'user/:user_nid/ranked'        => 'rankings#by_user'
  get 'location/:location_nid/rankings'  => 'rankings#location'

  #############################################################################
  #####  CATEGORIES  ##########################################################
  #############################################################################
  post '/categories/create' => 'categories#create'
  get '/categories/all' => 'categories#all'
  get '/locations/:location_nid/categories' => 'categories#location'

  #############################################################################
  #####  ACTIVITIES  ##########################################################
  #############################################################################
  get '/activities' => 'users#activity'

  get '/mu-3638e38f-8dd3e59d-52c5ecf8-1330dbf4' => 'details#blitz'

end
