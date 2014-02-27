class Organization::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = Organization::Content::Group.find(params[:content])
    return error_auth unless @content.editable?
  end

  def index
    @items = Organization::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = Organization::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def edit
    @item = Organization::Content::Setting.config(@content, params[:id])
    @item.value = YAML.load(@item.value.presence || '[]') if @item.form_type.in?(:check_boxes, :multiple_select)
    _show @item
  end

  def update
    @item = Organization::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]
    if @item.form_type.in?(:check_boxes, :multiple_select)
      @item.value = YAML.dump(case @item.value
                              when Hash; @item.value.keys
                              when Array; @item.value
                              else []
                              end)
    end
    _update @item
  end
end
