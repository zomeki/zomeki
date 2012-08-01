ZomekiCMS::Application.routes.draw do
  mod = "bbs"
  
  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :items,
      :controller  => "admin/items",
      :path        => ":content/items"
    
    ## content
    resources :content_base,
      :controller => "admin/content/base"
    resources :content_settings,
      :controller  => "admin/content/settings",
      :path        => ":content/content_settings"
    
    ## node
    resources :node_threads,
      :controller  => "admin/node/threads",
      :path        => ":parent/node_threads"
    
    ## piece
    resources :piece_recent_items,
      :controller  => "admin/piece/recent_items"
  end
  
  ## public
  scope "_public/#{mod}", :module => mod, :as => "" do
    match "node_threads/(index.:format)"         => "public/node/threads#index",
      :as => nil
    match "node_threads/new"                     => "public/node/threads#new",
      :as => nil
    match "node_threads/delete"                  => "public/node/threads#delete",
      :as => nil
    match "node_threads/:thread/(index.:format)" => "public/node/threads#show",
      :as => nil
  end
end
