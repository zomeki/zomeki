# encoding: utf-8
class GpCategory::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = GpCategory::Content::CategoryType.find(params[:content])
    return error_auth unless @content.editable?
    return redirect_to(request.env['PATH_INFO']) if params[:reset]
  end

  def index
    @items = GpCategory::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = GpCategory::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def edit
    @item = GpCategory::Content::Setting.config(@content, params[:id])
  end

  def update
    @item = GpCategory::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]
    _update @item
  end

  def copy_groups
    category_type = @content.category_types.find_by_name(@content.group_category_type_name) || @content.category_types.create(name: @content.group_category_type_name, title: '組織')
    category_type.copy_from_groups(Sys::Group.where(parent_id: 1, level_no: 2))
    redirect_to gp_category_content_settings_path, :notice => 'コピーが完了しました。'
  end
end
