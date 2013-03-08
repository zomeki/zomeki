ZomekiCMS::Application.routes.draw do
  mod = "newsletter"

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :docs,
      :controller  => "admin/docs",
      :path        => ":content/docs" do
        member do
          get :deliver
        end
      end
    resources :members,
      :controller  => "admin/members",
      :path        => ":content/members"
    resources :tests,
      :controller  => "admin/tests",
      :path        => ":content/tests"

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
    match "node_forms/index.:format"                        => "public/node/forms#index"
    match "node_forms/change/index.:format"                 => "public/node/forms#change"
    match "node_forms/sent/:id/:token/index.:format"        => "public/node/forms#sent"
    match "node_forms/unsubscribe/:id/:token/index.:format" => "public/node/forms#unsubscribe"
  end
end
