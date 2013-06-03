# encoding: utf-8
require 'nkf'
class Article::Admin::Tool::ImportHtmlController < ApplicationController
  protect_from_forgery :except => [:import]
  def import
    return http_error(404) if params[:file].blank?
    return http_error(404) if params[:file].size > (1024*1024*10)
    
    data = params[:file].read.to_s
    data = NKF.nkf('-w', data).gsub(/.*?<body[^>]+>(.*)<\/body>.*/m, '\\1')
    data = data.gsub(/<script[^>]+>.*?<\/script>/m, '')
    
    render :text => data
  rescue
    return http_error(404)
  end
end
