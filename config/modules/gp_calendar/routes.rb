ZomekiCMS::Application.routes.draw do
  mod = 'gp_calendar'

  ## script
  get "/_script/#{mod}/script/calendar_styled_events/publish" => "#{mod}/script/calendar_styled_events#publish"
  get "/_script/#{mod}/script/events/publish" => "#{mod}/script/events#publish"
  get "/_script/#{mod}/script/todays_events/publish" => "#{mod}/script/todays_events#publish"

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

    resources :holidays,
      :controller => 'admin/holidays',
      :path       => ':content/holidays'

    ## nodes
    resources :node_events,
      :controller => 'admin/node/events',
      :path       => ':parent/node_events'
    resources :node_todays_events,
      :controller => 'admin/node/todays_events',
      :path       => ':parent/node_todays_events'
    resources :node_calendar_styled_events,
      :controller => 'admin/node/calendar_styled_events',
      :path       => ':parent/node_calendar_styled_events'

    ## pieces
    resources :piece_daily_links,
      :controller => 'admin/piece/daily_links'
    resources :piece_monthly_links,
      :controller => 'admin/piece/monthly_links'
    resources :piece_category_types,
      :controller => 'admin/piece/category_types'
    resources :piece_near_future_events,
      :controller => 'admin/piece/near_future_events'
  end

  ## public
  scope "_public/#{mod}", :module => mod, :as => '' do
    get 'node_calendar_styled_events/index_:escaped_category' => 'public/node/calendar_styled_events#index'
    get 'node_calendar_styled_events/:year/index_:escaped_category' => 'public/node/calendar_styled_events#index'
    get 'node_calendar_styled_events/:year/:month/index_:escaped_category' => 'public/node/calendar_styled_events#index'
    get 'node_calendar_styled_events/:year/:month(/index)' => 'public/node/calendar_styled_events#index'
    get 'node_calendar_styled_events/:year(/index)' => 'public/node/calendar_styled_events#index'
    get 'node_calendar_styled_events(/index)' => 'public/node/calendar_styled_events#index'
    get 'node_events/index_:escaped_category' => 'public/node/events#index'
    get 'node_events/:year/index_:escaped_category' => 'public/node/events#index'
    get 'node_events/:year/:month/index_:escaped_category' => 'public/node/events#index'
    get 'node_events/:year/:month(/index)' => 'public/node/events#index'
    get 'node_events/:year(/index)' => 'public/node/events#index'
    get 'node_events(/index)' => 'public/node/events#index'
    get 'node_events/:name/file_contents/:basename.:extname' => 'public/node/events#file_content', :format => false
    get 'node_todays_events(/index)' => 'public/node/todays_events#index'
  end
end
