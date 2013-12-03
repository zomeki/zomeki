ZomekiCMS::Application.routes.draw do
  mod = 'sns_share'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    ## contents
    resources(:accounts, :only => [:index, :show],
      :controller => 'admin/accounts',
      :path       => ':content/accounts') do
      member do
        post :logout
      end
    end
  end
end
