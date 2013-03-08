ZomekiCMS::Application.routes.draw do
  mod = "laby"
  
  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :docs,
      :controller  => "admin/docs",
      :path        => ":content/docs"
    
    ## content
    resources :content_base,
      :controller => "admin/content/base"
    resources :content_settings,
      :controller => "admin/content/settings",
      :path        => ":content/content_settings"
    
    ## node
    resources :node_docs,
      :controller  => "admin/node/docs",
      :path        => ":parent/node_docs"
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => "" do
    match "node_docs/:name/:file.:format" => "public/node/docs#show"
    match "node_docs/index.:format"       => "public/node/docs#index"
  end
end
