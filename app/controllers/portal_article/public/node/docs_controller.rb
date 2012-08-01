# encoding: utf-8
class PortalArticle::Public::Node::DocsController < Cms::Controller::Public::Base
  include PortalArticle::Controller::Feed
  
  def pre_dispatch
    return http_error(404) unless @content = Page.current_node.content
    #@docs_uri = @content.public_uri('PortalArticle::Doc')
  end
  
  def index
    doc = PortalArticle::Doc.new.public
    doc.agent_filter(request.mobile)
    doc.and :content_id, @content.id
    doc.and :language_id, 1
    #doc.visible_in_list
    doc.search params
    doc.page params[:page], (request.mobile? ? 20 : 50)
    @docs = doc.find(:all, :order => 'published_at DESC')
    return true if render_feed(@docs)
    
    return http_error(404) if @docs.current_page > 1 && @docs.current_page > @docs.total_pages
  end

  def show
    doc = PortalArticle::Doc.new.public_or_preview
    doc.agent_filter(request.mobile) if Core.mode != 'preview'
    doc.and :content_id, Page.current_node.content.id
    doc.and :name, params[:name]
    return http_error(404) unless @item = doc.find(:first)

    if Core.mode == 'preview' && params[:doc_id]
      cond = {:id => params[:doc_id], :content_id => @item.content_id, :name => @item.name}
      return http_error(404) unless @item = PortalArticle::Doc.find(:first, :conditions => cond)
    end
    
    Page.current_item = @item
    Page.title        = @item.title

    @body = @item.body_without_summary_code
    
    if request.mobile?
      if !@item.mobile_body.blank?
        @body = @item.mobile_body
        @body = ApplicationController.helpers.br(@body)
      else
        ;
      end

      ## Converts the TABLE tags.
      #while @body =~ /(.*)<table.*?<\/table>/im
      #  @body.gsub!(/(.*)<table.*?<\/table>/im, '\1')
      #end
      
      ## Converts the images.
      #@body.gsub!(/<img.*?>/im) do |m|
      #  '' #remove
      #end

      related_sites = Page.site.related_sites(:include_self => true)

      ## Converts the links.
      @body.gsub!(/<a .*?href=".*?".*?>.*?<\/a>/im) do |m|
        uri   = m.gsub(/<a .*?href="(.*?)".*?>.*?<\/a>/im, '\1')
        label = m.sub(/(<a .*?href=".*?".*?>)(.*?)(<\/a>)/i, '\2')

        if m =~ /^<a .*?class="iconFile.*?"/i
          ## attachment
          size = label.gsub(/.*(\(.*?\))$/, '\1')
          ext  = label.gsub(/.*\.(.*?)\(.*?\)$/, '\1').to_s.upcase
          "#{ext}ファイル#{size}"
        elsif uri =~ /\.(pdf|doc|docx|xls|xlsx|jtd|jst)$/i
          ## other than html file
          label
        elsif uri =~ /^(\/|\.\/|\.\.\/)/
          ## same site
          m
        else
          result = false
          related_sites.each do |site|
            result = true if uri + '/' =~ /^#{site}/i
            result = true if uri =~ /^[0-9a-z]/i && uri !~ /^(http|https):\/\//
            break if result
          end
          result ? m : label
        end
      end

      ## Converts the phone number texts.
      @body.gsub!(/[\(]?(([0-9]{2}[-\(\)]+[0-9]{4})|([0-9]{3}[-\(\)]+[0-9]{3,4})|([0-9]{4}[-\(\)]+[0-9]{2}))[-\)]+[0-9]{4}/) do |m|
        "<a href='tel:#{m.gsub(/\D/, '\1')}'>#{m}</a>"
      end
    end
    
    if Core.mode == 'preview' && !Core.publish
      if params[:doc_id]
        @body = @body.gsub(/(<img[^>]+src=".\/files\/.*?)(".*?>)/i, '\\1' + "?doc_id=#{params[:doc_id]}" + '\\2')
      end
    end
  end
end
