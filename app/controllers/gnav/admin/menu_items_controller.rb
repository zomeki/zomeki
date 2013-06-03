# encoding: utf-8
class Gnav::Admin::MenuItemsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless @content = Gnav::Content::MenuItem.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to(request.env['PATH_INFO']) if params[:reset]

    if (gccct = @content.gp_category_content_category_type)
      @category_types = gccct.category_types
      @category_types_for_option = gccct.category_types_for_option
    else
      redirect_to gnav_content_settings_path, :alert => '汎用カテゴリタイプを設定してください。'
    end
  end

  def index
    @items = @content.menu_items.paginate(page: params[:page], per_page: 50)
    _index @items
  end

  def show
    @item = @content.menu_items.find(params[:id])
    _show @item
  end

  def new
    @item = @content.menu_items.build(state: 'public', sort_no: 10)
  end

  def create
    @item = @content.menu_items.build(params[:item])
    _create(@item) do
      save_category_sets
    end
  end

  def update
    @item = @content.menu_items.find(params[:id])
    @item.attributes = params[:item]
    _update(@item) do
      save_category_sets
    end
  end

  def destroy
    @item = @content.menu_items.find(params[:id])
    _destroy @item
  end

  private

  def save_category_sets
    categories = params[:categories]
    layers = params[:layers]

    if categories.is_a?(Hash) && layers.is_a?(Hash)
      category_set_ids = @item.category_set_ids
      categories.each do |key, value|
        next unless (category = GpCategory::Category.where(id: value).first)
        category_set = @item.category_sets.where(category_id: category.id).first || @item.category_sets.build
        category_set.update_attributes(category: category, layer: layers[key])
        category_set_ids.delete(category_set.id)
      end
      @item.category_sets.find(category_set_ids).each {|cs| cs.destroy }
    end
  end
end
