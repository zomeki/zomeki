# encoding: utf-8
class GpArticle::Admin::CommentsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return http_error(404) unless @content = GpArticle::Content::Doc.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset_criteria]

    @item = GpArticle::Comment.all_with_content_and_criteria(@content, {}).find(params[:id]) if params[:id].present?
  end

  def index
    criteria = params[:criteria] || {}

    comments = GpArticle::Comment.arel_table
    @items = GpArticle::Comment.all_with_content_and_criteria(@content, criteria)
                               .order(comments[:posted_at].desc)
                               .paginate(page: params[:page], per_page: 30)
  end

  def show
  end

  def edit
  end

  def update
    @item = GpArticle::Comment.all_with_content_and_criteria(@content, {}).find(params[:id])
    @item.attributes = params[:item]
    _update @item
  end

  def destroy
    _destroy @item
  end
end
