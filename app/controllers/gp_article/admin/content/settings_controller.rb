# encoding: utf-8
class GpArticle::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = GpArticle::Content::Doc.find(params[:content])
    return error_auth unless @content.editable?
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end
end
