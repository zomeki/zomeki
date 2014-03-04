ZomekiCMS::Application.routes.draw do
  mod = 'organization'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    ## contents
    resources(:groups, :only => [:index, :show, :edit, :update],
      :controller => 'admin/groups',
      :path       => ':content/groups') do
      resources :groups, :only => [:index, :show, :edit, :update],
        :controller => 'admin/groups'
    end

    ## nodes
    resources :node_groups,
      :controller => 'admin/node/groups',
      :path       => ':parent/node_groups'

    ## pieces
    resources :piece_categorized_docs,
      :controller => 'admin/piece/categorized_docs'
  end

  ## public
  scope "_public/#{mod}", :module => mod do
    match 'node_groups(/(index))' => 'public/node/groups#index'
  end
  scope "_public/#{mod}", :module => 'gp_article' do
    get 'node_groups/:group_names/:name/comments/new' => 'public/node/comments#new', :format => false
    post 'node_groups/:group_names/:name/comments/confirm' => 'public/node/comments#confirm', :format => false
    post 'node_groups/:group_names/:name/comments' => 'public/node/comments#create', :format => false
    match 'node_groups/:group_names/:name/preview/:id/file_contents/:basename.:extname' => 'public/node/docs#file_content'
    match 'node_groups/:group_names/:name/preview/:id/:filename_base' => 'public/node/docs#show'
    match 'node_groups/:group_names/:name/file_contents/:basename.:extname' => 'public/node/docs#file_content'
    match 'node_groups/:group_names/:name/:filename_base' => 'public/node/docs#show'
  end
  scope "_public/#{mod}", :module => mod do
    match 'node_groups/:group_names/:filename_base' => 'public/node/groups#show'
    match 'node_groups/:group_names' => 'public/node/groups#show'
  end
end
