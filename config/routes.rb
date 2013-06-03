ZomekiCMS::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

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

  ## OmniAuth
  match "/_auth/facebook"           => "cms/public/o_auth#dummy",   :as => :o_auth_facebook
  match "/_auth/:provider/callback" => "cms/public/o_auth#callback" # Used only by OmniAuth
  match "/_auth/failure"            => "cms/public/o_auth#failure"  # Used only by OmniAuth

  ## Tool
  match "/_tools/captcha/:action" => "simple_captcha",
    :as => "simple_captcha"

  ## Files
  match "_files/*path"           => "cms/public/files#down"

  ## Talking
  match "*path.html.mp3"         => "cms/public/talk#down_mp3"
  match "*path.html.m3u"         => "cms/public/talk#down_m3u"
  match "*path.html.r.mp3"       => "cms/public/talk#down_mp3"
  match "*path.html.r.m3u"       => "cms/public/talk#down_m3u"

  ## Admin
  match "#{ZomekiCMS::ADMIN_URL_PREFIX}"         => 'sys/admin/front#index'
  match "#{ZomekiCMS::ADMIN_URL_PREFIX}/login"   => 'sys/admin/account#login',  :as => :admin_login
  match "#{ZomekiCMS::ADMIN_URL_PREFIX}/logout"  => 'sys/admin/account#logout', :as => :admin_logout
  match "#{ZomekiCMS::ADMIN_URL_PREFIX}/account" => 'sys/admin/account#info',   :as => :admin_account

  get  "#{ZomekiCMS::ADMIN_URL_PREFIX}/password_reminders/new" => 'sys/admin/account#new_password_reminder',    :as => :new_admin_password_reminder
  post "#{ZomekiCMS::ADMIN_URL_PREFIX}/password_reminders"     => 'sys/admin/account#create_password_reminder', :as => :admin_password_reminders
  get  "#{ZomekiCMS::ADMIN_URL_PREFIX}/password/edit"          => 'sys/admin/account#edit_password',            :as => :edit_admin_password
  put  "#{ZomekiCMS::ADMIN_URL_PREFIX}/password"               => 'sys/admin/account#update_password',          :as => :admin_password

  ## Modules
  Dir::entries("#{Rails.root}/config/modules").each do |mod|
    next if mod =~ /^\./
    file = "#{Rails.root}/config/modules/#{mod}/routes.rb"
    load(file) if FileTest.exist?(file)
  end

  ## Exception
  match "404.:format" => "exception#index"
  match "*path"       => "exception#index"
end
