ZomekiCMS::Application.routes.draw do
  mod = 'gp_article'

  ## admin
  scope "#{ZomekiCMS::ADMIN_URL_PREFIX}/#{mod}", :module => mod, :as => mod do
    ## contents
    resources :content_base,
      :controller => 'admin/content/base'
    resources :content_settings,
      :controller => 'admin/content/settings',
      :path       => ':content/content_settings'

    resources(:category_types,
      :controller => 'admin/category_types',
      :path       => ':content/category_types') do
      match 'category_tree' => 'admin/category_types#category_tree'
      resources(:categories, :only => :index,
        :controller => 'admin/categories') do
        resources :categories,
          :controller => 'admin/categories'
      end
    end

    resources :docs,
      :controller => 'admin/docs',
      :path       => ':content/docs'
  end
end
