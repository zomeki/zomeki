ZomekiCMS::Application.routes.draw do
  mod = 'gp_category'

  ## script
  get "/_script/#{mod}/script/category_types/publish" => "#{mod}/script/category_types#publish"
  get "/_script/#{mod}/script/docs/publish" => "#{mod}/script/docs#publish"

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
        resources :docs, :only => [:index, :show, :edit, :update],
          :controller => 'admin/docs'
      end
    end
    resources :templates,
      :controller => 'admin/templates',
      :path       => ':content/templates'
    resources :template_modules,
      :controller => 'admin/template_modules',
      :path       => ':content/template_modules'

    ## nodes
    resources :node_category_types,
      :controller => 'admin/node/category_types',
      :path       => ':parent/node_category_types'
    resources :node_docs,
      :controller => 'admin/node/docs',
      :path       => ':parent/node_docs'

    ## pieces
    resources :piece_category_types,
      :controller => 'admin/piece/category_types'
    resources :piece_category_lists,
      :controller => 'admin/piece/category_lists'
    resources :piece_categories,
      :controller => 'admin/piece/categories'
    resources :piece_docs,
      :controller => 'admin/piece/docs'
    resources(:piece_recent_tabs,
      :controller => 'admin/piece/recent_tabs') do
      resources :tabs,
        :controller => 'admin/piece/recent_tabs/tabs'
    end
    resources :piece_feeds,
      :controller => 'admin/piece/feeds'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    match 'node_category_types(/index.:format)' => 'public/node/category_types#index'
    match 'node_category_types/:name/:file.:format' => 'public/node/category_types#show'
    match 'node_category_types/:name' => 'public/node/category_types#show', :format => false
    match 'node_category_types/:category_type_name/*category_names/:file.:format' => 'public/node/categories#show'
    match 'node_category_types/:category_type_name/*category_names' => 'public/node/categories#show', :format => false
    match 'node_docs(/index)' => 'public/node/docs#index'
    match 'node_docs/:file' => 'public/node/docs#index'
  end
end
