class GpArticle::Admin::Docs::HistoriesController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return http_error(404) unless @content = GpArticle::Content::Doc.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return http_error(404) unless @doc = @content.docs.find_by_id(params[:doc_id])

    @category_types = @content.category_types
    @event_category_types = @content.event_category_types
    @marker_category_types = @content.marker_category_types
  end

  def index
    doc_ids = @doc.prev_editions.select(&:state_archived?).map(&:id)
    @items = @content.docs.unscoped.where(id: doc_ids).reorder('display_published_at DESC').paginate(page: params[:page], per_page: 30)
  end

  def show
    @item = @content.docs.unscoped.find(params[:id])
  end
end
