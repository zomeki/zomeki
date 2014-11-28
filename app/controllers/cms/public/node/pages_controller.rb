# encoding: utf-8
class Cms::Public::Node::PagesController < Cms::Controller::Public::Base
  def index
    return http_error(404) if params[:page]

    @item = Cms::Node::Page.find(Page.current_node.id)
    
    if Core.mode == 'preview' && params[:node_id]
      cond = {:id => params[:node_id], :parent_id => @item.parent_id, :name => @item.name}
      return http_error(404) unless @item = Cms::Node::Page.find(:first, :conditions => cond)
    end
    
    Page.current_node = @item
    Page.current_item = @item
    Page.title        = @item.title
    
    @body = @item.body
    
    if request.mobile?
      Page.title = @item.mobile_title if !@item.mobile_title.blank?
      @body = @item.mobile_body if !@item.mobile_body.blank?
    end
  end
  
protected
  def render_public_variables
    response.body.scan(/\{\$[a-z]+\}/i).uniq.each do |name|
      value = name
      if name == "{$publishedOn}"
        value = @item.published_at ? @item.published_at.strftime("%Y年%-m月%-d日") : ""
      end
      
      response.body.gsub!("#{name}", value) if name != value
    end

    body = Nokogiri::HTML(response.body, nil, 'utf-8').xpath("//div[@class='contentPage']/div[@class='body']").inner_html
    if @item.pdf_in_body?(body)
      html = <<-EOT
<div class="adobeReader">
  <p>PDFの閲覧にはAdobe System社の無償のソフトウェア「Adobe Reader」が必要です。下記のAdobe Readerダウンロードページから入手してください。</p>
  <a href="http://get.adobe.com/jp/reader/" target="_blank" title="Adobe Readerダウンロード">Adobe Readerダウンロード</a>
</div>
      EOT
    else
      html = ''
    end

    self.response_body = response.body.gsub("@adobe-reader-link@", html)
  end
end
