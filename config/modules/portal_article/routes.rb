ZomekiCMS::Application.routes.draw do
  mod = "portal_article"

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :categories,
      :controller  => "admin/categories",
      :path        => ":content/:parent/categories"
    resources :docs,
      :controller  => "admin/docs",
      :path        => ":content/docs"
    resources :edit_docs,
      :controller  => "admin/docs/edit",
      :path        => ":content/edit_docs"
    resources :recognize_docs,
      :controller  => "admin/docs/recognize",
      :path        => ":content/recognize_docs"
    resources :publish_docs,
      :controller  => "admin/docs/publish",
      :path        => ":content/publish_docs"
    resources :inline_files,
      :controller  => "admin/doc/files",
      :path        => ":content/doc/:parent" do
        member do
          get :download
        end
      end

    ## content
    resources :content_base,
      :controller => "admin/content/base"
    resources :content_settings,
      :controller => "admin/content/settings",
      :path        => ":content/content_settings"

    ## node
    resources :node_docs,
      :controller  => "admin/node/docs",
      :path        => ":parent/node_docs"
    resources :node_recent_docs,
      :controller  => "admin/node/recent_docs",
      :path        => ":parent/node_recent_docs"
    resources :node_event_docs,
      :controller  => "admin/node/event_docs",
      :path        => ":parent/node_event_docs"
    resources :node_tag_docs,
      :controller  => "admin/node/tag_docs",
      :path        => ":parent/node_tag_docs"
    resources :node_categories,
      :controller  => "admin/node/categories",
      :path        => ":parent/node_categories"
    resources :node_archives,
      :controller  => "admin/node/archives",
      :path        => ":parent/node_archives"

    ## piece
    resources :piece_recent_docs,
      :controller  => "admin/piece/recent_docs"
    resources :piece_recent_tabs,
      :controller  => "admin/piece/recent_tabs"
    resources :piece_recent_tab_tabs,
      :controller  => "admin/piece/recent_tab/tabs",
      :path        => ":piece/piece_recent_tab_tabs"
    resources :piece_calendars,
      :controller  => "admin/piece/calendars"
    resources :piece_categories,
      :controller  => "admin/piece/categories"
    resources :piece_archives,
      :controller  => "admin/piece/archives"

    ## tool
    match "tool_import_uri"  => "admin/tool/import_uri#import"
    match "tool_import_html" => "admin/tool/import_html#import"
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => "" do
    match "node_docs/:name/(index.:format)"            => "public/node/docs#show"
    match "node_docs/:name/files/:file.:format"        => "public/node/doc/files#show"
    match "node_docs/index.:format"                    => "public/node/docs#index"
    match "node_recent_docs/index.:format"             => "public/node/recent_docs#index"
    match "node_event_docs/:year/:month/index.:format" => "public/node/event_docs#month"
    match "node_event_docs/index.:format"              => "public/node/event_docs#month"
    match "node_tag_docs/index.:format"                => "public/node/tag_docs#index"
    match "node_tag_docs/:tag"                         => "public/node/tag_docs#index"
    match "node_categories/:name/:attr/index.:format"  => "public/node/categories#show_attr"
    match "node_categories/:name/:file.:format"        => "public/node/categories#show"
    match "node_categories/index.:format"              => "public/node/categories#index"
    match "node_archives/:year/:month/index.:format"   => "public/node/archives#index"
    match "node_archives/index.:format"                => "public/node/archives#index"
  end
end
