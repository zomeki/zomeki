ZomekiCMS::Application.routes.draw do
  mod = 'organization'

  ## script
  get "/_script/#{mod}/script/groups/publish" => "#{mod}/script/groups#publish"

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
#    resources :piece_groups, # Somehow doesn't work
    resources :piece_all_groups,
      :controller => 'admin/piece/all_groups'
    resources :piece_categorized_docs,
      :controller => 'admin/piece/categorized_docs'
    resources :piece_business_outlines,
      :controller => 'admin/piece/business_outlines'
    resources :piece_contact_informations,
      :controller => 'admin/piece/contact_informations'
  end

  ## public
  scope "_public/#{mod}", :module => mod do
    match 'node_groups(/(index))' => 'public/node/groups#index'
  end
  scope "_public/#{mod}", :module => 'gp_article' do
    get 'node_groups/*group_names/docs/:name/comments/new' => 'public/node/comments#new', :format => false
    post 'node_groups/*group_names/docs/:name/comments/confirm' => 'public/node/comments#confirm', :format => false
    post 'node_groups/*group_names/docs/:name/comments' => 'public/node/comments#create', :format => false
    match 'node_groups/*group_names/docs/:name/preview/:id/file_contents/:basename.:extname' => 'public/node/docs#file_content'
    match 'node_groups/*group_names/docs/:name/preview/:id/:filename_base' => 'public/node/docs#show'
    match 'node_groups/*group_names/docs/:name/file_contents/:basename.:extname' => 'public/node/docs#file_content'
    match 'node_groups/*group_names/docs/:name/:filename_base' => 'public/node/docs#show'
  end
  scope "_public/#{mod}", :module => mod do
    match 'node_groups/*group_names/:filename_base' => 'public/node/groups#show'
    match 'node_groups/*group_names' => 'public/node/groups#show'
  end
end
