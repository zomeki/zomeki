ZomekiCMS::Application.routes.draw do
  mod = 'ad_banner'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    ## contents
    resources(:banners,
      :controller => 'admin/banners',
      :path       => ':content/banners') do
      member do
        get :file_content
      end
    end
    resources :groups,
      :controller => 'admin/groups',
      :path       => ':content/groups'

    ## nodes
    resources :node_banners,
      :controller => 'admin/node/banners',
      :path       => ':parent/node_banners'

    ## pieces
    resources :piece_banners,
      :controller => 'admin/piece/banners'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    match 'node_banners(/index.:format)' => 'public/node/banners#index'
  end
end
