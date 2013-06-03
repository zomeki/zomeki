ZomekiCMS::Application.routes.draw do
  mod = "cms"
  
  match "/_preview/:site/(*path)" => "cms/admin/preview#index",
    :as => :cms_preview
  
  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :navi_concepts,
      :controller  => "admin/navi/concepts"
    resources :navi_sites,
      :controller  => "admin/navi/sites"
      # :as => :cms_navi_concepts
    match "stylesheets/(*path)" => "admin/stylesheets#index",
      :as => :stylesheets
    match "stylesheets/" => "admin/stylesheets#index",
      :as => :stylesheets
    
    resources :tests,
      :controller  => "admin/tests"
    resources :concepts,
      :controller  => "admin/concepts",
      :path        => ":parent/concepts" do
        collection do
          get  :layouts
          post :layouts
        end
      end
    resources :sites,
      :controller  => "admin/sites" do
        member do
          get :show_portal
          get :hide_portal
        end
      end
    resources :site_basic_auth_users,
      :controller  => "admin/site/basic_auth_users",
      :path        => ":site/basic_auth_users" do
        collection do
          get :enable_auth
          get :disable_auth
        end
      end
    resources :contents,
      :controller  => "admin/contents"
    resources :nodes,
      :controller  => "admin/nodes",
      :path        => ":parent/nodes" do
        collection do
          get  :search
          get  :content_options
          get  :model_options
        end
      end
    resources :layouts,
      :controller  => "admin/layouts"
    resources :pieces,
      :controller  => "admin/pieces" do
        collection do
          get  :content_options
          get  :model_options
        end
      end
    resources :data_texts,
      :controller  => "admin/data/texts"
    resources :data_files,
      :controller  => "admin/data/files",
      :path        => ":parent/data_files" do
        member do
          get :download
        end
      end
    resources :data_file_nodes,
      :controller  => "admin/data/file_nodes",
      :path        => ":parent/data_file_nodes"
    resources :inline_data_files,
      :controller  => "admin/inline/data_files",
      :path        => ":parent/inline_data_files" do
        member do
          get :download
        end
      end
    resources :inline_data_file_nodes,
      :controller  => "admin/inline/data_file_nodes",
      :path        => ":parent/inline_data_file_nodes"
    resources :kana_dictionaries,
      :controller  => "admin/kana_dictionaries" do
        collection do
          get  :make
          post :make
          get  :test
          post :test
        end
      end
    resources :emergencies,
      :controller  => "admin/emergencies" do
        member do
          get :change
        end
      end
    
    ## node
    resources :node_directories,
      :controller  => "admin/node/directories",
      :path        => ":parent/node_directories"
    resources :node_pages,
      :controller  => "admin/node/pages",
      :path        => ":parent/node_pages"
    resources :node_sitemaps,
      :controller  => "admin/node/sitemaps",
      :path        => ":parent/node_sitemaps"
    
    ## piece
    resources :piece_frees,
      :controller  => "admin/piece/frees"
    resources :piece_page_titles,
      :controller  => "admin/piece/page_titles"
    resources :piece_bread_crumbs,
      :controller  => "admin/piece/bread_crumbs"
    resources :piece_links,
      :controller  => "admin/piece/links"
    resources :piece_link_items,
      :controller  => "admin/piece/link_items",
      :path        => ":piece/piece_link_items"
    resources :piece_sns_parts,
      :controller  => "admin/piece/sns_parts"
  end
  
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => "" do
    match "tool_rebuild" => "admin/tool/rebuild#index",
      :as => nil
    match "tool_search"  => "admin/tool/search#index",
      :as => nil
  end
      
  ## public
  scope "_public/#{mod}", :module => mod, :as => "" do
    match "layouts/:id/:file.:format" => "public/layouts#index",
      :as => nil
    match "node_pages/"    => "public/node/pages#index",
      :as => nil
    match "node_sitemaps/" => "public/node/sitemaps#index",
      :as => nil
  end
end
