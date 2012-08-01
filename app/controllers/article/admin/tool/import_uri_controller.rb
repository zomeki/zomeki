# encoding: utf-8
require 'nkf'
class Article::Admin::Tool::ImportUriController < Cms::Controller::Admin::Base
  def import
    uri = params[:uri]#.join('/')
    return http_error(404) if uri.blank?
    
    res = Util::Http::Request.send(uri)
    return http_error(404) if res.status != 200
    
    data = NKF.nkf('-w', res.body.to_s).gsub(/.*<body[^>]+>(.*)<\/body>.*/m, '\\1')
    
    render :text => data
  rescue
    return http_error(404)
  end
end
