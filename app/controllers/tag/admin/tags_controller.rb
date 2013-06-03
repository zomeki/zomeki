# encoding: utf-8
class Tag::Admin::TagsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Tag::Content::Tag.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = @content.tags.paginate(page: params[:page], per_page: 50)
    _index @items
  end
end
