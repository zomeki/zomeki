# encoding: utf-8
class Laby::Public::Node::DocsController < Cms::Controller::Public::Base
  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
  end
    
  def pre_dispatch
    @node = Page.current_node
    return http_error(404) unless @node_uri = @node.public_uri
    return http_error(404) unless @content  = @node.content
  end
  
  def index
    doc = Laby::Doc.new.public
    doc.and :content_id, @content.id
    doc.search params
    doc.page params[:page], (request.mobile? ? 20 : 50)
    @items = doc.find(:all, :order => 'updated_at DESC')
    
    return http_error(404) if @items.current_page > 1 && @items.current_page > @items.total_pages
  end

  def show
    doc = Laby::Doc.new.public_or_preview
    doc.and :content_id, @content.id
    doc.and :name, params[:name]
    return http_error(404) unless @item = doc.find(:first)

    Page.current_item = @item
    Page.title        = @item.title
    
    ## link
    @item.body.gsub!(/\[\[.*?\]\]/) do |m|
      key = m.gsub(/\[\[(.*?)\]\]/, '\\1').strip
      if key =~ /^(file|text|piece)\//
        ;
      elsif key =~ /^c[0-9]+$/
        doc = Laby::Doc.new.public
        doc.and :content_id, @content.id
        doc.and :name, key
        if item = doc.find(:first, :order => :id)
          title = ::ERB::Util.html_escape(item.title)
          m = %Q(<a href="#{@node_uri}#{item.name}/">#{title}</a>).html_safe
        end
      else
        doc = Laby::Doc.new.public
        doc.and :content_id, @content.id
        doc.and :title, key
        if item = doc.find(:first, :order => :id)
          title = ::ERB::Util.html_escape(item.title)
          m = %Q(<a href="#{@node_uri}#{item.name}/">#{title}</a>).html_safe
        end
      end
      m
    end
    
    ## phone number
    @item.body.gsub!(/[\(]?(([0-9]{2}[-\(\)]+[0-9]{4})|([0-9]{3}[-\(\)]+[0-9]{3,4})|([0-9]{4}[-\(\)]+[0-9]{2}))[-\)]+[0-9]{4}/) do |m|
      "<a href='tel:#{m.gsub(/\D/, '\1')}'>#{m}</a>".html_safe
    end

  end
end
