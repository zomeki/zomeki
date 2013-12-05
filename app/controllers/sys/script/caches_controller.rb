# encoding: utf-8
class Sys::Script::CachesController < ApplicationController
  include Sys::Controller::CacheSweeper::Base

  def sweep
    Sys::CacheSweeper.find(:all, :order => :id).each do |s|
      Script.current

      # create key
      path =  Rails.application.routes.recognize_path(s.uri)
      qp = {}
      if s.uri =~ /\?/
        qp   = Rack::Utils.parse_query(s.uri.gsub(/.*\?/, ''))
        path = qp.merge(path)
      end
      path[:only_path] = true

#      puts url_for s.uri
#      puts url_for path
#      puts ' '
      begin
        expire_action path
        s.destroy
      rescue => e
        Script.error "#{s.uri} => #{e}"
        next
      end
    end
    render(:text => "OK")
  rescue => e
    raise "error #{e}"
  end

end
