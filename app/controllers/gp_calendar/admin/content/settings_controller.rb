# encoding: utf-8
class GpCalendar::Admin::Content::SettingsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  def pre_dispatch
    return error_auth unless Core.user.has_auth?(:designer)
    return error_auth unless @content = GpCalendar::Content::Event.find(params[:content])
    return error_auth unless @content.editable?
  end

  def index
    @items = GpCalendar::Content::Setting.configs(@content)
    _index @items
  end

  def show
    @item = GpCalendar::Content::Setting.config(@content, params[:id])
    _show @item
  end

  def update
    @item = GpCalendar::Content::Setting.config(@content, params[:id])
    @item.value = params[:item][:value]

    if @item.name.in?('gp_category_content_category_type_id', 'event_sync_import', 'event_sync_export')
      extra_values = @item.extra_values

      case @item.name
      when 'gp_category_content_category_type_id'
        category_ids = (params[:categories] || {}).to_a.sort{|a, b| a.first <=> b.first }.map(&:last)
        extra_values[:category_ids] = category_ids.map{|id| id.to_i if id.present? }.compact.uniq
      when 'event_sync_import'
        extra_values[:source_hosts] = params[:source_hosts].to_s
      when 'event_sync_export'
        extra_values[:destination_hosts] = params[:destination_hosts].to_s
      end

      @item.extra_values = extra_values
    elsif @item.name == 'show_images'
      @item.extra_values do |ev|
        ev[:image_cnt] = params[:image_cnt].to_i
      end
    end

    _update @item
  end
end
