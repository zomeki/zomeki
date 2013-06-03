ZomekiCMS::Application.routes.draw do
  mod = 'gp_calendar'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    ## contents
    resources :events,
      :controller => 'admin/events',
      :path       => ':content/events'

    ## nodes
    resources :node_events,
      :controller => 'admin/node/events',
      :path       => ':parent/node_events'

    ## pieces
    resources :piece_daily_links,
      :controller => 'admin/piece/daily_links'
    resources :piece_monthly_links,
      :controller => 'admin/piece/monthly_links'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    match 'node_events/:year/:month(/index.:format)' => 'public/node/events#index_monthly'
    match 'node_events/:year(/index.:format)' => 'public/node/events#index_yearly'
    match 'node_events(/index.:format)' => 'public/node/events#index'
  end
end
