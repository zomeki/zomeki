ZomekiCMS::Application.routes.draw do
  mod = 'map'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

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

    ## pieces
    resources :piece_category_types,
      :controller => 'admin/piece/category_types'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    match 'node_markers(/index)' => 'public/node/markers#index'
    match 'node_markers/:name/file_contents/:basename.:extname' => 'public/node/markers#file_content', :format => false
  end
end
