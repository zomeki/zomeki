require 'will_paginate/array'

class GpArticle::Public::Node::DocsController < Cms::Controller::Public::Base
  include GpArticle::Controller::Feed
  skip_filter :render_public_layout, :only => [:file_content]

  def pre_dispatch
    if (organization_content = Page.current_node.content).kind_of?(Organization::Content::Group)
      return http_error(404) unless organization_content.article_related?
      @group = organization_content.find_group_by_path_from_root(params[:group_names])
      return http_error(404) unless @group
      @content = organization_content.related_article_content
    else
      @content = GpArticle::Content::Doc.find_by_id(Page.current_node.content.id)
      # Block if organization relation available
      if (organization_content = @content.organization_content_group) &&
          organization_content.article_related? &&
          organization_content.related_article_content == @content
        return http_error(404)
      end
    end

    return http_error(404) unless @content
  end

  def index
    @docs = public_or_preview_docs.order('display_published_at DESC, published_at DESC')
    if params[:format].in?('rss', 'atom')
      @docs = @docs.display_published_after(@content.feed_docs_period.to_i.days.ago) if @content.feed_docs_period.present?
      @docs = @docs.reject{|d| d.will_be_replaced? } unless Core.publish
      @docs = @docs.paginate(page: params[:page], per_page: @content.feed_docs_number)
      return render_feed(@docs)
    end
    @docs = @docs.includes(:next_edition).reject{|d| d.will_be_replaced? } unless Core.publish
    @docs = @docs.paginate(page: params[:page], per_page: 20)
    return http_error(404) if @docs.current_page > @docs.total_pages

    @items = @docs.inject([]) do |result, doc|
        date = doc.display_published_at.try(:strftime, '%Y年%-m月%-d日')

        unless result.empty?
          last_date = result.last[:doc].display_published_at.try(:strftime, '%Y年%-m月%-d日')
          date = nil if date == last_date
        end

        result.push(date: date, doc: doc)
      end

    render :index_mobile if Page.mobile?
  end

  def show
    params[:filename_base], params[:format] = 'index', 'html' unless params[:filename_base]

    @item = public_or_preview_docs(id: params[:id], name: params[:name])
    return http_error(404) if @item.nil? || @item.filename_base != params[:filename_base]
    if @group
      return http_error(404) unless @item.creator.group == @group.sys_group
    end

    Page.current_item = @item
    Page.title = unless Page.mobile?
                   @item.title
                 else
                   @item.mobile_title.presence || @item.title
                 end
  end

  def file_content
    @doc = public_or_preview_docs(id: params[:id], name: params[:name])
    return http_error(404) unless @doc
    if @group
      return http_error(404) unless @doc.creator.group == @group.sys_group
    end

    if (file = @doc.files.find_by_name("#{params[:basename]}.#{params[:extname]}"))
      mt = Rack::Mime.mime_type(".#{params[:extname]}")
      type, disposition = (mt =~ %r!^image/|^application/pdf$! ? [mt, 'inline'] : [mt, 'attachment'])
      disposition = 'attachment' if request.env['HTTP_USER_AGENT'] =~ /Android/
      send_file file.upload_path, :type => type, :filename => file.name, :disposition => disposition
    else
      http_error(404)
    end
  end

  def qrcode
    @doc = public_or_preview_docs(id: params[:id], name: params[:name])
    return http_error(404) unless @doc
    return http_error(404) unless @doc.qrcode_visible?

    if ::Storage.exists?(@doc.qrcode_path)
      mt = Rack::Mime.mime_type(".png")
      disposition = request.env['HTTP_USER_AGENT'] =~ /Android/ ? 'attachment' : 'inline'
      send_file @doc.qrcode_path, :type => mt, :filename => 'qrcode.ping', :disposition => disposition
    else
      qrcode = Util::Qrcode.create_date(@doc.public_full_uri, @doc.qrcode_path)
      if qrcode
        mt = Rack::Mime.mime_type(".png")
        disposition = request.env['HTTP_USER_AGENT'] =~ /Android/ ? 'attachment' : 'inline'
        send_data qrcode, :type => mt, :filename => 'qrcode.ping', :disposition => disposition
      else
        http_error(404)
      end
    end
  end

  private

  def public_or_preview_docs(id: nil, name: nil)
    unless Core.mode == 'preview'
      docs = @content.public_docs
      name ? docs.find_by_name(name) : docs
    else
      if Core.publish
        case
        when id
          nil
        when name
          @content.preview_docs.find_by_name(name)
        else
          @content.public_docs
        end
      else
        case
        when id
          @content.all_docs.find_by_id(id)
        when name
          @content.public_docs.find_by_name(name) || @content.preview_docs.find_by_name(name)
        else
          @content.public_docs
        end
      end
    end
  end
end
