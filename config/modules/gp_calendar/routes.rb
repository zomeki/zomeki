ZomekiCMS::Application.routes.draw do
  mod = 'gp_calendar'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    ## contents
    resources(:events,
      :controller => 'admin/events',
      :path       => ':content/events') do
      match 'file_contents/:basename.:extname' => 'admin/events/files#content'
      resources :files,
        :controller => 'admin/events/files'
    end

    ## nodes
    resources :node_events,
      :controller => 'admin/node/events',
      :path       => ':parent/node_events'
    resources :node_todays_events,
      :controller => 'admin/node/todays_events',
      :path       => ':parent/node_todays_events'

    ## pieces
    resources :piece_daily_links,
      :controller => 'admin/piece/daily_links'
    resources :piece_monthly_links,
      :controller => 'admin/piece/monthly_links'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    match 'node_events/:year/:month(/index)' => 'public/node/events#index'
    match 'node_events/:year(/index)' => 'public/node/events#index'
    match 'node_events(/index)' => 'public/node/events#index'
    match 'node_events/:name/file_contents/:basename.:extname' => 'public/node/events#file_content', :format => false
    match 'node_todays_events(/index)' => 'public/node/todays_events#index'
  end
end
