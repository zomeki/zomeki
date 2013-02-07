ZomekiCMS::Application.routes.draw do
  mod = 'tag'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    ## contents
    resources :tags, :only => [:index],
      :controller => 'admin/tags',
      :path       => ':content/tags'
  end
end
