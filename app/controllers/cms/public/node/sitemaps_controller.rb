# encoding: utf-8
class Cms::Public::Node::SitemapsController < Cms::Controller::Public::Base
  def index
    @item = Page.current_node

    Page.current_item = @item
    Page.title        = @item.title

    item = Cms::Node.new.public
    item.and :route_id, Page.site.root_node.id
    item.and :name, 'IS NOT', nil
    item.and :sitemap_state, 'visible'
    @items = item.find(:all, :order => 'directory DESC, sitemap_sort_no IS NULL, sitemap_sort_no, name')

    @children = lambda do |node|
      item = Cms::Node.new.public
      item.and :route_id, node.id
      item.and :name, 'IS NOT', nil
      item.and :sitemap_state, 'visible'
      item.find(:all, :order => 'directory DESC, sitemap_sort_no IS NULL, sitemap_sort_no, name')
    end
  end
end
