# encoding: utf-8
module PortalGroup::Controller::SiteFeed
  def render_feed(sites)
    if ['rss', 'atom'].index(params[:format])
      @site_uri    = Page.site.full_uri
      @node_uri    = @site_uri.gsub(/\/$/, '') + Page.current_node.public_uri
      @req_uri     = @site_uri.gsub(/\/$/, '') + Page.uri
      @feed_name   = "#{Page.title} | #{Page.site.name}"

      data = eval("to_#{params[:format]}(sites)")
      return render :xml => unescape(data), :layout => false
    end
    return false
  end

  def unescape(xml)
    xml = xml.to_s
    #xml = CGI.unescapeHTML(xml)
    #xml = xml.gsub(/&amp;/, '&')
    xml.gsub(/&#(?:(\d*?)|(?:[xX]([0-9a-fA-F]{4})));/) { [$1.nil? ? $2.to_i(16) : $1.to_i].pack('U') }
  end

  def strimwidth(str, size, options = {})
    suffix = options[:suffix] || '..'
    str    = str.sub!(/<[^<>]*>/,"") while /<[^<>]*>/ =~ str
    chars  = str.split(//u)
    return chars.size <= size ? str : chars.slice(0, size).join('') + suffix
  end

  def to_rss(sites)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.rss('version' => '2.0') do

      xml.channel do
        xml.title       @feed_name
        xml.link        @req_uri
        xml.language    "ja"
        xml.description Page.title

        sites.each do |site|
          next unless site.created_at
          xml.item do
            xml.title        site.name
            xml.link         site.full_uri
            xml.description  strimwidth(site.body.to_s, 500)
            xml.pubDate      site.created_at.rfc822
            # site.category_items.each do |category|
              # xml.category   category.title
            # end
          end
        end #sites

      end #channel
    end #xml
  end

  def to_atom(sites)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct! :xml, :version => 1.0, :encoding => 'UTF-8'
    xml.feed 'xmlns' => 'http://www.w3.org/2005/Atom' do

      xml.id      "tag:#{Page.site.domain},#{Page.site.created_at.strftime('%Y')}:/"
      xml.title   @feed_name
      xml.updated Time.now.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/([0-9][0-9])$/, ':\1')
      xml.link    :rel => 'alternate', :href => @node_uri
      xml.link    :rel => 'self', :href => @req_uri, :type => 'application/atom+xml', :title => @feed_name

      sites.each do |site|
        next unless site.created_at
        
        xml.entry do
          xml.id      "tag:#{Page.site.domain},#{site.created_at.strftime('%Y')}:/"
          xml.title   site.name
          xml.updated site.updated_at.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/([0-9][0-9])$/, ':\1') #.rfc822
          #xml.summary strimwidth(site.body, 500), :type => 'text'
          xml.summary(:type => 'html') do |p|
            p.cdata! strimwidth(site.body.to_s, 500)
          end
          xml.link    :rel => 'alternate', :href => site.full_uri
          #xml.link    :rel => 'enclosure', :href => "#{site.full_uri}#{content.xhtml}", :type => 'text/xhtml'

          # if (c = site.unit) && (node = site.content.unit_node)
            # xml.category :term => c.name, :scheme => node.public_full_uri, :label => "組織/#{c.node_label}"
          # end
# 
          # if node = site.content.category_node
            # site.category_items.each do |c|
              # xml.category :term => c.name, :scheme => node.public_full_uri, :label => "分野/#{c.node_label}"
            # end
          # end
# 
          # if node = site.content.attribute_node
            # site.attribute_items.each do |c|
              # xml.category :term => c.name, :scheme => node.public_full_uri, :label => "属性/#{c.node_label}"
            # end
          # end
# 
          # if node = site.content.area_node
            # site.area_items.each do |c|
              # xml.category :term => c.name, :scheme => node.public_full_uri, :label => "地域/#{c.node_label}"
            # end
          # end

#          if site.event_state == 'visible' && site.event_date && node = site.content.event_node
#            xml.category :term => 'event', :scheme => node.public_full_uri,
#              :label => "イベント/#{site.event_date.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/([0-9][0-9])$/, ':\1')}"
#          end

          # xml.author do |auth|
            # if site.inquiry && site.inquiry.group
              # name  = site.inquiry.group.full_name
              # name += "　#{site.inquiry.charge}" if !site.inquiry.charge.blank?
              # auth.name  "#{name}"
              # auth.email "#{site.inquiry.email}"
            # end
            # #auth.uri "#{uri}#{site.unit.name}/"
          # end

          # if node = site.content.tag_node
            # site.tags.each do |c|
              # xml.link :rel => 'tag', :href => "#{node.public_full_uri}#{CGI::escape(c.word)}", :type => 'text/xhtml'
            # end
          # end

#          site.rel_sites.each do |c|
#            xml.link :rel => 'related', :href => "#{c.full_uri}", :type => 'text/xhtml'
#          end

        end #entry
      end #sites
    end #feed
  end
end