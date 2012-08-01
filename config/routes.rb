ZomekiCMS::Application.routes.draw do
  ## OmniAuth
  match "/_auth/facebook"           => "cms/public/o_auth#dummy",   :as => :o_auth_facebook
  match "/_auth/:provider/callback" => "cms/public/o_auth#callback" # Used only by OmniAuth
  match "/_auth/failure"            => "cms/public/o_auth#failure"  # Used only by OmniAuth

  ## Tool
  match "/_tools/captcha/:action" => "simple_captcha",
    :as => "simple_captcha"
  
  ## Files
  match "_files/*path"           => "cms/public/files#down"
  
  ## Talking
  match "*path.html.mp3"         => "cms/public/talk#down_mp3"
  match "*path.html.m3u"         => "cms/public/talk#down_m3u"
  match "*path.html.r.mp3"       => "cms/public/talk#down_mp3"
  match "*path.html.r.m3u"       => "cms/public/talk#down_m3u"
  
  ## Admin
  match "#{ZomekiCMS::ADMIN_URL_PREFIX}"                 => "sys/admin/front#index"
  match "#{ZomekiCMS::ADMIN_URL_PREFIX}/login.:format"   => "sys/admin/account#login"
  match "#{ZomekiCMS::ADMIN_URL_PREFIX}/login"           => "sys/admin/account#login"
  match "#{ZomekiCMS::ADMIN_URL_PREFIX}/logout.:format"  => "sys/admin/account#logout"
  match "#{ZomekiCMS::ADMIN_URL_PREFIX}/logout"          => "sys/admin/account#logout"
  match "#{ZomekiCMS::ADMIN_URL_PREFIX}/account.:format" => "sys/admin/account#info"
  match "#{ZomekiCMS::ADMIN_URL_PREFIX}/account"         => "sys/admin/account#info"

  ## Modules
  Dir::entries("#{Rails.root}/config/modules").each do |mod|
    next if mod =~ /^\./
    file = "#{Rails.root}/config/modules/#{mod}/routes.rb"
    load(file) if FileTest.exist?(file)
  end
  
  ## Exception
  match "404.:format" => "exception#index"
  match "*path"       => "exception#index"
end
