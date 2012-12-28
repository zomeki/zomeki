# encoding: utf-8
class Cms::Public::Piece::BreadCrumbsController < Sys::Controller::Public::Base
  def index
    @item = Page.current_item
    if @item.respond_to?(:bread_crumbs)
      @bread_crumbs = @item.bread_crumbs(Page.current_node)
    else
      @bread_crumbs = Page.current_node.bread_crumbs
    end
  end
end
