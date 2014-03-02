require 'will_paginate/array'

class GpArticle::Public::Node::DocsController < Cms::Controller::Public::Base
  include GpArticle::Controller::Feed
  skip_filter :render_public_layout, :only => [:file_content]

  def pre_dispatch
    if (org_content = Page.current_node.content).kind_of?(Organization::Content::Group)
      settings = GpArticle::Content::Setting.arel_table
      doc_contents = GpArticle::Content::Doc.joins(:settings)
                                            .where(settings[:name].eq('organization_content_group_id').and(settings[:value].eq(org_content.id)))
                                            .where(site_id: org_content.site.id)
      doc_content_ids = doc_contents.map{|d| d.id if d.under_group? }.compact
#TODO: Revert flatted groups
#      if (sys_group = org_content.find_group_by_path_from_root(params[:group_names]).try(:sys_group))
      if (sys_group = org_content.groups.where(name: params[:group_names]).first.try(:sys_group))
        conditions = {content_id: doc_content_ids, name: params[:name], filename_base: params[:filename_base]}
        conditions.delete(:filename_base) if action_name == 'file_content'

        creators = Sys::Creator.arel_table
        docs = GpArticle::Doc.joins(:creator).where(creators[:group_id].eq(sys_group.id))
                             .mobile(Page.mobile?).public
                             .where(conditions)
        if docs.count.zero?
          return http_error(404)
        else
          @content = doc_contents.first
        end
      else
        return http_error(404)
      end
    else
      @content = GpArticle::Content::Doc.find_by_id(Page.current_node.content.id)
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
    @docs = @docs.reject{|d| d.will_be_replaced? } unless Core.publish
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
    @item = public_or_preview_docs(id: params[:id], name: params[:name])
    return http_error(404) if @item.nil? || @item.filename_base != params[:filename_base]

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
          nil
        else
          @content.public_docs
        end
      end
    end
  end
end
