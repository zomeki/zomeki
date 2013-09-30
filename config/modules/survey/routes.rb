ZomekiCMS::Application.routes.draw do
  mod = 'survey'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    resources :content_settings, :only => [:index, :show, :edit, :update],
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    ## contents
    resources(:forms,
      :controller => 'admin/forms',
      :path       => ':content/forms') do
      resources :questions,
        :controller => 'admin/questions'
    end
  end
end
