# encoding: utf-8
class GpCategory::Public::Piece::CategoryListsController < Sys::Controller::Public::Base
  def pre_dispatch
    @piece = GpCategory::Piece::CategoryList.find_by_id(Page.current_piece.id)
    render :text => '' unless @piece

    @item = Page.current_item
  end

  def index
    if @piece.setting_state == 'enabled'
      if @piece.category_type_id && @piece.category_id
        @category = @piece.category_type.categories.find_by_id(@piece.category_id)
        render :category
      elsif @piece.category_type_id
        @category_type = @piece.category_type
        render :category_type
      else
        @category_types = @piece.public_category_types
      end
    else
      case @item
      when GpCategory::CategoryType
        @category_type = @item
        render :category_type
      when GpCategory::Category
        @category = @item
        render :category
      else
        @category_types = @piece.public_category_types
      end
    end
  end
end
