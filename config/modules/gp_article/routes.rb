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
    resources(:docs,
      :controller => 'admin/docs',
      :path       => ':content/docs') do
      match 'file_contents/:basename.:extname' => 'admin/docs/files#content'
      resources :files,
        :controller => 'admin/docs/files'
    end

    ## nodes
    resources :node_docs,
      :controller => 'admin/node/docs',
      :path       => ':parent/node_docs'

    ## pieces
    resources(:piece_recent_tabs,
      :controller => 'admin/piece/recent_tabs') do
      resources :tabs,
        :controller => 'admin/piece/recent_tabs/tabs'
    end
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    match 'node_docs(/index.:format)' => 'public/node/docs#index'
    match 'node_docs/:name(/index.:format)' => 'public/node/docs#show'
    match 'node_docs/:name/file_contents/:basename.:extname' => 'public/node/docs#file_content'
  end
end
