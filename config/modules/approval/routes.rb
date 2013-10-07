ZomekiCMS::Application.routes.draw do
  mod = 'approval'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    resources :content_base,
      :controller => 'admin/content/base'

    ## contents
    resources :approval_flows,
      :controller => 'admin/approval_flows',
      :path       => ':content/approval_flows'
  end
end
