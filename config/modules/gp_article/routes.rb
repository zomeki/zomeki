ZomekiCMS::Application.routes.draw do
  mod = 'gp_article'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    ## contents
    resources :content_base,
      :controller => 'admin/content/base'
  end
end
