ZomekiCMS::Application.routes.draw do
  mod = 'gp_article'

  ## script
  get "/_script/#{mod}/script/docs/publish" => "#{mod}/script/docs#publish"
  get "/_script/#{mod}/script/archives/publish" => "#{mod}/script/archives#publish"

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
      member do
        post :approve
        post :passback
        post :pullback
        post :publish
      end
      resources(:files,
        :controller => 'admin/docs/files') do
        member do
          get  :view
          post :crop
        end
      end
      resources :histories,
        :controller => 'admin/docs/histories', :only => [:index, :show]
    end
    resources :comments, :only => [:index, :show, :edit, :update, :destroy],
      :controller => 'admin/comments',
      :path       => ':content/comments'

    ## nodes
    resources :node_docs,
      :controller => 'admin/node/docs',
      :path       => ':parent/node_docs'
    resources :node_archives,
      :controller => 'admin/node/archives',
      :path       => ':parent/node_archives'

    ## pieces
    resources :piece_docs,
      :controller => 'admin/piece/docs'
    resources(:piece_recent_tabs,
      :controller => 'admin/piece/recent_tabs') do
      resources :tabs,
        :controller => 'admin/piece/recent_tabs/tabs'
    end
    resources :piece_monthly_archives,
      :controller => 'admin/piece/monthly_archives'
    resources :piece_comments,
      :controller => 'admin/piece/comments'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    match 'node_docs(/(index))' => 'public/node/docs#index'
    get 'node_docs/:name/comments/new' => 'public/node/comments#new', :format => false
    post 'node_docs/:name/comments/confirm' => 'public/node/comments#confirm', :format => false
    post 'node_docs/:name/comments' => 'public/node/comments#create', :format => false
    match 'node_docs/:name/preview/:id/file_contents/:basename.:extname' => 'public/node/docs#file_content'
    match 'node_docs/:name/preview/:id/qrcode.:extname' => 'public/node/docs#qrcode'
    match 'node_docs/:name/preview/:id(/(:filename_base.:format))' => 'public/node/docs#show'
    match 'node_docs/:name/file_contents/:basename.:extname' => 'public/node/docs#file_content'
    match 'node_docs/:name/qrcode.:extname' => 'public/node/docs#qrcode'
    match 'node_docs/:name(/(:filename_base.:format))' => 'public/node/docs#show'
    get 'node_archives/:year(/(index))' => 'public/node/archives#index'
    get 'node_archives/:year/:month(/(index))' => 'public/node/archives#index'
  end
end
