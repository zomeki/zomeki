class Gnav::Public::Node::MenuItemsController < Cms::Controller::Public::Base
  def pre_dispatch
    @content = Gnav::Content::MenuItem.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    @menu_items = @content.menu_items.paginate(page: params[:page], per_page: 20)
    return http_error(404) if @menu_items.current_page > @menu_items.total_pages

    render :index_mobile if Page.mobile?
  end

  def show
    @menu_item = @content.menu_items.find_by_name(params[:name])
    return http_error(404) unless @menu_item

    Page.current_item = @menu_item
    Page.title = @menu_item.title

    @categories = @menu_item.public_categories
    @least_level_no = @categories.min{|a, b| a.level_no <=> b.level_no }.level_no
    @categories.reject! {|c| c.level_no > (@least_level_no + 1) }

    render :show_mobile if Page.mobile?
  end
end
