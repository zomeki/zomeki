ZomekiCMS::Application.routes.draw do
  mod = 'gp_category'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'
    match ':content/content_settings/copy_groups' => 'admin/content/settings#copy_groups', :as => :content_settings_copy_groups

    ## contents
    resources(:category_types,
      :controller => 'admin/category_types',
      :path       => ':content/category_types') do
      resources(:categories,
        :controller => 'admin/categories') do
        resources :categories,
          :controller => 'admin/categories'
      end
    end

    ## nodes
    resources :node_category_types,
      :controller => 'admin/node/category_types',
      :path       => ':parent/node_category_types'

    ## pieces
    resources :piece_category_types,
      :controller => 'admin/piece/category_types'
    resources :piece_docs,
      :controller => 'admin/piece/docs'
    resources(:piece_recent_tabs,
      :controller => 'admin/piece/recent_tabs') do
      resources :tabs,
        :controller => 'admin/piece/recent_tabs/tabs'
    end
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    match 'node_category_types(/index.:format)' => 'public/node/category_types#index'
    match 'node_category_types/:name(/index.:format)' => 'public/node/category_types#show'
    match 'node_category_types/:category_type_name/*category_names/index(.:format)' => 'public/node/categories#show'
    match 'node_category_types/:category_type_name/*category_names' => 'public/node/categories#show'
  end
end
