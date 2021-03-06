ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "roots"

  # See how all your routes lay out with "rake routes"

  # for openida_authentication
  map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.resource :session
  map.login  '/login',  :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  
  # acts_as_taggable_redux
  map.resources :tags
  map.resources :versions

  # by hand for tag rating
  map.plus_useful_tag 'tags/:id/plus_useful/:rubygem_id', :controller => 'tags', :action => 'plus_useful', :requirements => { :method => :post }
  map.minus_useful_tag 'tags/:id/minus_useful/:rubygem_id', :controller => 'tags', :action => 'minus_useful', :requirements => { :method => :post }
  map.reset_useful_tag 'tags/:id/reset_useful/:rubygem_id', :controller => 'tags', :action => 'reset_useful', :requirements => { :method => :post }

  
  # by hand
  map.resource :mypage
  map.resources :rubygems, :controller => "rubygems", :member => {:plus_love => :post, :minus_love => :post, :reset_love => :post, :new_tag => :get, :create_tag => :post, :destroy_tag => :post, :create_favorit => :post}
  map.resources :gemcasts, :path_prefix => 'rubygems/:rubygem_id', :member => {:plus_useful => :post, :minus_useful => :post, :reset_useful => :post}
  map.resources :unchikus, :path_prefix => 'rubygems/:rubygem_id', :member => {:plus_useful => :post, :minus_useful => :post, :reset_useful => :post}
  map.resources :obstacles, :path_prefix => 'rubygems/:rubygem_id/:version_id', :member => {:plus_useful => :post, :minus_useful => :post, :reset_useful => :post}
  map.resources :whats,    :path_prefix => 'rubygems/:rubygem_id', :member => {:plus_useful => :post, :minus_useful => :post, :reset_useful => :post}, :controller => "what"
  map.resources :strengths, :path_prefix => 'rubygems/:rubygem_id', :member => {:plus_useful => :post, :minus_useful => :post, :reset_useful => :post}, :controller => "strength"
  map.resources :weaknesses, :path_prefix => 'rubygems/:rubygem_id', :member => {:plus_useful => :post, :minus_useful => :post, :reset_useful => :post}, :controller => "weakness"

  # by hand for trackback
  map.unchiku_trackback 'rubygems/:rubygem_id/unchiku/trackback/:user_key', :controller => 'unchikus', :action => 'create_trackback', :requirements => { :method => :post }
  map.obstacle_trackback 'rubygems/:version_id/obstacle/trackback/:user_key', :controller => 'obstacles', :action => 'create_trackback', :requirements => { :method => :post }
  
  # by hand for search
  map.search '/search', :controller => "roots", :action => "search", :requirements => { :method => :get }
  
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
