ZomekiCMS::Application.routes.draw do
  mod = 'gp_article'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    resources(:category_types,
      :controller => 'admin/category_types',
      :path       => ':content/category_types') do
#TODO: ツリー表示は不採用
#      match 'category_tree' => 'admin/category_types#category_tree'
      resources(:categories, :only => [:index],
        :controller => 'admin/categories') do
        resources :categories,
          :controller => 'admin/categories'
      end
    end

    ## contents
    resources :docs,
      :controller => 'admin/docs',
      :path       => ':content/docs'

    ## nodes
    resources :node_category_types,
      :controller => 'admin/node/category_types',
      :path       => ':parent/node_category_types'
    resources :node_docs,
      :controller => 'admin/node/docs',
      :path       => ':parent/node_docs'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    match 'node_category_types(/index.:format)'                  => 'public/node/category_types#show'
    match 'node_category_types/:name(/:file.:format)'            => 'public/node/categories#show'
    match 'node_category_types/*ancestors/:name(/:file.:format)' => 'public/node/categories#show'
    match 'node_docs/index.:format'                              => 'public/node/docs#index'
    resources :node_docs, :only => [:index, :show],
      :controller => 'public/node/docs'
  end
end
