ZomekiCMS::Application.routes.draw do
  mod = 'gnav'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    ## contents
    resources :menu_items,
      :controller => 'admin/menu_items',
      :path       => ':content/menu_items'
  end
end
