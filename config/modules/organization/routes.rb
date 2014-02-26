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
  end
end
