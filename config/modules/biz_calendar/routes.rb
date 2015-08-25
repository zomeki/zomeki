ZomekiCMS::Application.routes.draw do
  mod = "biz_calendar"
  
  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources(:places,
      :controller  => "admin/places",
      :path        => ":content/places") do
      resources :hours,
        :controller => 'admin/hours'
      resources :holidays,
        :controller => 'admin/holidays'
      resources :exception_holidays,
        :controller => 'admin/exception_holidays'
    end
    resources :types,
      :controller  => "admin/types",
      :path        => ":content/types"
    
    ## content
    resources :content_base,
      :controller => "admin/content/base"
    resources :content_settings,
      :controller  => "admin/content/settings",
      :path        => ":content/content_settings"
    
    ## node
    resources :node_places,
      :controller  => "admin/node/places",
      :path        => ":parent/node_places"
    
    ## piece
    resources :piece_calendars,
      :controller  => "admin/piece/calendars"
    resources :piece_bussiness_holidays,
      :controller  => "admin/piece/bussiness_holidays"
    resources :piece_bussiness_times,
      :controller  => "admin/piece/bussiness_times"
  end
  
  ## public
  scope "_public/#{mod}", :module => mod, :as => "" do
    match "node_places/index"              => "public/node/places#index",
      :as => nil
    match "node_places/:piece/bussiness_times/:name" => "public/node/places#bussiness_times"
    match "node_places/:piece/bussiness_times"       => "public/node/places#bussiness_times"
    match "node_places/:piece/bussiness_holidays/:name" => "public/node/places#bussiness_holidays"
    match "node_places/:piece/bussiness_holidays"       => "public/node/places#bussiness_holidays"
    match "node_places/:name/index"        => "public/node/places#show",
      :as => nil
  end
end
