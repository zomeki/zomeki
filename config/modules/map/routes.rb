ZomekiCMS::Application.routes.draw do
  mod = 'map'

  ## script
  get "/_script/#{mod}/script/markers/publish" => "#{mod}/script/markers#publish"

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    resources(:category_types, :only => [:index, :edit, :update],
      :controller => 'admin/category_types',
      :path       => ':content/category_types') do
      resources(:categories, :only => [:index, :edit, :update],
        :controller => 'admin/categories') do
        resources :categories, :only => [:index, :edit, :update],
          :controller => 'admin/categories'
      end
    end

    ## contents
    resources(:markers,
      :controller => 'admin/markers',
      :path       => ':content/markers') do
      member do
        get :file_content
      end
    end

    ## nodes
    resources :node_markers,
      :controller => 'admin/node/markers',
      :path       => ':parent/node_markers'
    resources :node_searches,
      :controller => 'admin/node/navigations',
      :path       => ':parent/node_navigations'
    ## pieces
    resources :piece_category_types,
      :controller => 'admin/piece/category_types'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    match 'node_markers/index_:escaped_category' => 'public/node/markers#index'
    match 'node_markers(/index)' => 'public/node/markers#index'
    match 'node_markers/:name/file_contents/:basename.:extname' => 'public/node/markers#file_content', :format => false
    match 'node_navigations(/index)' => 'public/node/navigations#index'
  end
end
