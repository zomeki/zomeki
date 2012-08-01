ZomekiCMS::Application.routes.draw do
  mod = "enquete"
  
  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :forms,
      :controller  => "admin/forms",
      :path        => ":content/forms"
    resources :form_columns,
      :controller  => "admin/form_columns",
      :path        => ":content/:form/form_columns"
    resources :form_answers,
      :controller  => "admin/form_answers",
      :path        => ":content/:form/form_answers"
    
    ## content
    resources :content_base,
      :controller => "admin/content/base"
    resources :content_settings,
      :controller  => "admin/content/settings",
      :path        => ":content/content_settings"
    
    ## node
    resources :node_forms,
      :controller  => "admin/node/forms",
      :path        => ":parent/node_forms"
  end
  
  ## public
  scope "_public/#{mod}", :module => mod, :as => "" do
    match "node_forms/index"     => "public/node/forms#index",
      :as => nil
    match "node_forms/:id/index" => "public/node/forms#show",
      :as => nil
    match "node_forms/:id/sent"  => "public/node/forms#sent",
      :as => nil
  end
end
