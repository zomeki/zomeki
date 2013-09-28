ZomekiCMS::Application.routes.draw do
  mod = 'survey'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    ## contents
    resources :forms,
      :controller => 'admin/forms',
      :path       => ':content/forms'
  end
end
