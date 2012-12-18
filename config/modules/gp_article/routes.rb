ZomekiCMS::Application.routes.draw do
  mod = 'gp_article'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    ## contents
    resources :docs,
      :controller => 'admin/docs',
      :path       => ':content/docs'

    ## nodes
    resources :node_docs,
      :controller => 'admin/node/docs',
      :path       => ':parent/node_docs'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    match 'node_docs/index.:format' => 'public/node/docs#index'
    resources :node_docs, :only => [:index, :show],
      :controller => 'public/node/docs'
  end
end
