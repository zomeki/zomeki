# encoding: utf-8
class Cms::Admin::PreviewController < Cms::Controller::Admin::Base
  after_filter :replace_preview_data

  def index
    path = Core.request_uri.gsub(/^#{Regexp.escape(cms_preview_path)}/, "")

    render_preview(path, :mobile => Page.mobile?, :preview => true)
  end

  def render_preview(path, options = {})
    Core.publish = true unless options[:preview]
    mode = Core.set_mode('preview')

    Page.initialize
    Page.site   = options[:site] || Core.site
    Page.uri    = path
    Page.mobile = options[:mobile]

    node = Core.search_node(path)
    env  = {}
    opt  = _routes.recognize_path(node, env)
    ctl  = opt[:controller]
    act  = opt[:action]

    opt.each {|k,v| params[k] = v }
    #opt[:layout_id] = params[:layout_id] if params[:layout_id]
    #opt[:authenticity_token] = params[:authenticity_token] if params[:authenticity_token]

    component_response = render_component :controller => ctl, :action => act, :params => params
    response.content_type = component_response.content_type
  end

protected
  def replace_preview_data
    return if response.content_type != 'text/html' && response.content_type != 'application/xhtml+xml'
    return if response.body.class != String

    public_uri = URI.parse(Page.site.full_uri)
    public_uri.path = '/'

    if (script_uri = Core.env['SCRIPT_URI'])
      admin_uri = URI.parse(script_uri)
      admin_uri.path = '/'
    else
      #admin_uri = public_uri
      d = Zomeki.config.application['sys.core_domain']
      admin_uri = (d == 'core') ? Core.full_uri.to_s : public_uri;
    end

    mobile   = Page.mobile? ? 'm' : ''
    base_uri = "#{admin_uri}_preview/#{format('%08d', Page.site.id)}#{mobile}"

    self.response_body = response.body.gsub(/<a[^>]+?href="\/[^"]*?"[^>]*?>/i) do |m|
      if m =~ /href="\/_(files|layouts)\//
        m
      else
        m.gsub(/^(<a[^>]+?href=")(\/[^"]*?)("[^>]*?>)/i, '\\1' + base_uri + '\\2\\3')
      end
    end

    ## preview mark
    html = <<-EOT
<div id="cmsPreviewMark" style="margin: 1px; padding: 5px 10px; border-bottom: 1px solid #fff; background-color: #000; color: #fff; line-height: 1.5; font-family: sans-serif; cursor: pointer; " onclick="document.getElementById('cmsPreviewMark').style.display='none';">プレビュー：&nbsp;終了する場合は、ブラウザのタブの×で閉じてください。</div>
    EOT
    self.response_body = response.body.gsub(/(<body[^>]*?>)/i, '\\1' + html)

    ## host
    doc = Nokogiri::HTML.parse(response.body)
    unless (a_tags = doc.css(%Q!a[href^="#{public_uri}"]!)).empty?
      a_tags.each do |a_tag|
        a_tag.set_attribute('href', a_tag.attribute('href').to_s.sub(public_uri.to_s, admin_uri.to_s))
      end
    end
    unless (img_tags = doc.css(%Q!img[src^="#{public_uri}"]!)).empty?
      img_tags.each do |img_tag|
        img_tag.set_attribute('src', img_tag.attribute('src').to_s.sub(public_uri.to_s, admin_uri.to_s))
      end
    end
    self.response_body = doc.to_s

    ## themes
    self.response_body = response.body.gsub(%r! (href|src)="/_themes/!, %Q! \\1="#{public_uri}_themes/!)
  end
end
