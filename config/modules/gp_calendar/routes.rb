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
  end
end
