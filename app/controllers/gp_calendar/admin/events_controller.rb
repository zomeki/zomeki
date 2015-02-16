# encoding: utf-8
class GpCalendar::Admin::EventsController < Cms::Controller::Admin::Base
  include Sys::Controller::Scaffold::Base

  include Cms::ApiGpCalendar

  def pre_dispatch
    return error_auth unless @content = GpCalendar::Content::Event.find_by_id(params[:content])
    return error_auth unless Core.user.has_priv?(:read, :item => @content.concept)
    return redirect_to url_for(action: :index) if params[:reset_criteria]
#    return redirect_to(request.env['REQUEST_PATH']) if params[:reset_criteria]
  end

  def index
    require 'will_paginate/array'

    criteria = params[:criteria] || {}
    @items = GpCalendar::Event.all_with_content_and_criteria(@content, criteria)

    criteria[:date] = Date.parse(criteria[:date]) rescue nil
    @events = GpCalendar::Holiday.all_with_content_and_criteria(@content, criteria).where(kind: :event)
    @events.each do |event|
      event.started_on = Time.now.year if event.repeat?
      @items << event if event.started_on
    end

    case criteria[:order]
      when 'created_at_desc'
        @items.sort! {|a, b| a.created_at <=> b.created_at}
      when 'created_at_asc'
        @items.sort! {|a, b| b.created_at <=> a.created_at}
      else
        @items.sort! {|a, b| a.started_on <=> b.started_on}
    end

    @items = @items.to_a.paginate(page: params[:page], per_page: 50)

    _index @items
  end

  def show
    @item = @content.events.find(params[:id])
    _show @item
  end

  def new
    @item = @content.events.build
  end

  def create
    @item = @content.events.build(params[:item])
    _create(@item) do
      set_categories
      @item.fix_tmp_files(params[:_tmp])
      gp_calendar_sync_events_export(@item) if @content.event_sync_export?
    end
  end

  def update
    @item = @content.events.find(params[:id])
    @item.attributes = params[:item]
    _update(@item) do
      set_categories
      gp_calendar_sync_events_export(@item) if @content.event_sync_export?
    end
  end

  def destroy
    @item = @content.events.find(params[:id])
    _destroy(@item) do
      gp_calendar_sync_events_export(@item) if @content.event_sync_export?
    end
  end

  private

  def set_categories
    category_ids = if params[:categories].kind_of?(Hash)
                     params[:categories].values.flatten.reject{|c| c.blank? }.uniq
                   else
                     []
                   end
    @item.category_ids = category_ids
  end
end
