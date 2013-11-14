# encoding: utf-8
class GpArticle::Public::Node::DocsController < Cms::Controller::Public::Base
  include GpArticle::Controller::Feed
  skip_filter :render_public_layout, :only => [:file_content]

  def pre_dispatch
    @content = GpArticle::Content::Doc.find_by_id(Page.current_node.content.id)
    return http_error(404) unless @content
  end

  def index
    @docs = public_or_preview_docs.order('display_published_at DESC, published_at DESC').paginate(page: params[:page], per_page: 20)
    return true if render_feed(@docs)
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
    @item = public_or_preview_docs(id: params[:id], name: params[:name])
    return http_error(404) unless @item

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

    if (file = @doc.files.find_by_name("#{params[:basename]}.#{params[:extname]}"))
      mt = Rack::Mime.mime_type(".#{params[:extname]}")
      type, disposition = (mt =~ %r!^image/|^application/pdf$! ? [mt, 'inline'] : [mt, 'attachment'])
      disposition = 'attachment' if request.env['HTTP_USER_AGENT'] =~ /Android/
      send_file file.upload_path, :type => type, :filename => file.name, :disposition => disposition
    else
      http_error(404)
    end
  end

  private

  def public_or_preview_docs(id: nil, name: nil)
    docs = if Core.mode == 'preview'
             @content.preview_docs
           else
             @content.public_docs
           end

    return docs if id.nil? && name.nil?

    if Core.mode == 'preview'
      docs.find_by_id(id) || docs.find_by_name(name)
    else
      docs.find_by_name(name)
    end
  end
end
