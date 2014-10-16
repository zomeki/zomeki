ZomekiCMS::Application.routes.draw do
  mod = 'rank'

  ## script
  get "/_script/#{mod}/script/previous_days/publish" => "#{mod}/script/previous_days#publish"
  get "/_script/#{mod}/script/last_weeks/publish" => "#{mod}/script/last_weeks#publish"
  get "/_script/#{mod}/script/last_months/publish" => "#{mod}/script/last_months#publish"
  get "/_script/#{mod}/script/this_weeks/publish" => "#{mod}/script/this_weeks#publish"

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller  => "admin/content/base"

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller  => "admin/content/settings",
      :path        => ":content/content_settings" do
        collection do
          post :import
          post :makeup
        end
      end

    ## contents
    resources :ranks, :only => [:index],
      :controller  => "admin/ranks",
      :path        => ":content/ranks"

    resources :ranks, :only => [:index],
      :controller  => "admin/ranks",
      :path        => ":content/ranks/:target"

    resources :ranks, :only => [:index],
      :controller  => "admin/ranks",
      :action      => "remote",
      :path        => ":content/ranks/remote/:gp_category(/:category_type)(/:category)"

    ## nodes
    resources :node_previous_days,
      :controller => 'admin/node/previous_days',
      :path       => ':parent/node_previous_days'
    resources :node_last_weeks,
      :controller => 'admin/node/last_weeks',
      :path       => ':parent/node_last_weeks'
    resources :node_last_months,
      :controller => 'admin/node/last_months',
      :path       => ':parent/node_last_months'
    resources :node_this_weeks,
      :controller => 'admin/node/this_weeks',
      :path       => ':parent/node_this_weeks'

    ## pieces
    resources :piece_ranks,
      :controller => 'admin/piece/ranks'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    match 'node_previous_days(/index.:format)' => 'public/node/previous_days#index'
    match 'node_last_weeks(/index.:format)' => 'public/node/last_weeks#index'
    match 'node_last_months(/index.:format)' => 'public/node/last_months#index'
    match 'node_this_weeks(/index.:format)' => 'public/node/this_weeks#index'
  end
end
