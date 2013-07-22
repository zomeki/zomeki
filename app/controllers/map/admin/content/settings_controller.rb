# encoding: utf-8
class Map::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Map::Content::Marker.find(params[:content])
    return error_auth unless @content.editable?
  end

  def index
    @items = Map::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = Map::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def update
    @item = Map::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]

    if @item.name == 'gp_category_content_category_type_id'
      extra_values = @item.extra_values

      category_ids = (params[:categories] || {}).to_a.sort{|a, b| a.first <=> b.first }.map(&:last)
      extra_values[:category_ids] = category_ids.map{|id| id.to_i if id.present? }.compact.uniq

      @item.extra_values = extra_values
    end

    _update @item
  end
end
