# encoding: utf-8
class GpArticle::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = GpArticle::Content::Doc.find(params[:content])
    return error_auth unless @content.editable?
  end

  def index
    @items = GpArticle::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = GpArticle::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def edit
    @item = GpArticle::Content::Setting.config(@content, params[:id])
    @item.value = YAML.load(@item.value.presence || '[]') if @item.form_type.in?(:check_boxes, :multiple_select)
    _show @item
  end

  def update
    @item = GpArticle::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]
    if @item.form_type.in?(:check_boxes, :multiple_select)
      @item.value = YAML.dump(case @item.value
                              when Hash; @item.value.keys
                              when Array; @item.value
                              else []
                              end)
    end

    if @item.name.in?('gp_category_content_category_type_id', 'calendar_relation', 'map_relation', 'inquiry_setting',
                      'approval_relation', 'gp_template_content_template_id', 'feed', 'tag_relation', 'sns_share_relation',
                      'blog_functions', 'feature_settings', 'list_style', 'qrcode_settings', 'basic_setting')
      extra_values = @item.extra_values

      case @item.name
      when 'gp_category_content_category_type_id'
        extra_values[:category_type_ids] = (params[:category_types] || []).map {|ct| ct.to_i }
        extra_values[:visible_category_type_ids] = (params[:visible_category_types] || []).map {|ct| ct.to_i }
        extra_values[:default_category_type_id] = params[:default_category_type].to_i
        extra_values[:default_category_id] = params[:default_category].to_i
      when 'basic_setting'
        extra_values[:default_layout_id] = params[:default_layout_id].to_i
      when 'calendar_relation'
        extra_values[:calendar_content_id] = params[:calendar_content_id].to_i
        extra_values[:event_sync_settings] = params[:event_sync_settings].to_s
        extra_values[:event_sync_default_will_sync] = params[:event_sync_default_will_sync].to_s
      when 'map_relation'
        extra_values[:map_content_id] = params[:map_content_id].to_i
        extra_values[:lat_lng] = params[:lat_lng]
        extra_values[:marker_icon_category] = params[:marker_icon_category]
      when 'inquiry_setting'
        extra_values[:state] = params[:state]
        extra_values[:display_fields] = params[:display_fields] || []
      when 'approval_relation'
        extra_values[:approval_content_id] = params[:approval_content_id].to_i
      when 'gp_template_content_template_id'
        extra_values[:template_ids] = params[:template_ids].to_a.map(&:to_i)
        extra_values[:default_template_id] = params[:default_template_id].to_i
      when 'feed'
        extra_values[:feed_docs_number] = params[:feed_docs_number]
        extra_values[:feed_docs_period] = params[:feed_docs_period]
      when 'tag_relation'
        extra_values[:tag_content_tag_id] = params[:tag_content_tag_id].to_i
      when 'sns_share_relation'
        extra_values[:sns_share_content_id] = params[:sns_share_content_id].to_i
      when 'blog_functions'
        extra_values[:comment] = params[:comment]
        extra_values[:comment_open] = params[:comment_open]
        extra_values[:comment_notification_mail] = params[:comment_notification_mail]
        extra_values[:footer_style] = params[:footer_style]
      when 'feature_settings'
        extra_values[:feature_1] = params[:feature_1]
        extra_values[:feature_2] = params[:feature_2]
      when 'list_style'
        extra_values[:wrapper_tag] = params[:wrapper_tag]
      when 'qrcode_settings'
        extra_values[:state] = params[:state]
      end

      @item.extra_values = extra_values
    end

    _update(@item) do
      if @item.name == 'calendar_relation' && @content.gp_calendar_content_event.nil?
        @content.docs.where(event_state: 'visible').update_all(event_state: 'hidden')
      end
      if @item.name == 'map_relation' && @content.map_content_marker.nil?
        @content.docs.where(marker_state: 'visible').update_all(marker_state: 'hidden')
      end
    end
  end
end
