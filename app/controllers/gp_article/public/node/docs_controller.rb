# encoding: utf-8

require 'will_paginate/array'

class GpArticle::Public::Node::DocsController < Cms::Controller::Public::Base
  skip_filter :render_public_layout, :only => [:file_content]

  def pre_dispatch
    @content = GpArticle::Content::Doc.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    @docs = public_or_preview_docs.paginate(page: params[:page], per_page: 20)
    return http_error(404) if @docs.current_page > @docs.total_pages

    @items = @docs.inject([]) do |result, doc|
        date = doc.published_at.try(:strftime, '%Y年%-m月%-d日')

        unless result.empty?
          last_date = result.last[:doc].published_at.try(:strftime, '%Y年%-m月%-d日')
          date = nil if date == last_date
        end

        result.push(date: date, doc: doc)
      end

    render :index_mobile if Page.mobile?
  end

  def show
    @item = public_or_preview_docs.find_by_name(params[:name])
    return http_error(404) unless @item

    Page.current_item = @item
    Page.title = unless Page.mobile?
                   @item.title
                 else
                   @item.mobile_title.presence || @item.title
                 end
  end

  def file_content
    @doc = public_or_preview_docs.find_by_name(params[:name])
    return http_error(404) unless @doc

    if (file = Sys::File.where(parent_unid: @doc.unid, name: "#{params[:basename]}.#{params[:extname]}").first)
      mt = Rack::Mime.mime_type(".#{params[:extname]}")
      type, disposition = (mt =~ %r!^image/|^application/pdf$! ? [mt, 'inline'] : [mt, 'attachment'])
      disposition = 'attachment' if request.env['HTTP_USER_AGENT'] =~ /Android/
      send_file file.upload_path, :type => type, :filename => file.name, :disposition => disposition
    else
      http_error(404)
    end
  end

  private

  def public_or_preview_docs
    if Core.mode == 'preview'
      @content.preview_docs
    else
      @content.public_docs
    end
  end
end
