# encoding: utf-8
#require 'date'
module PortalArticle::Controller::Feed

	#そのyyyymmに何件のレコードが登録されているかを配列で返す
	def get_count(et, st, content_id, show_zero)
		#et, st には yyyy-mm-dd 形式の日付型がくることを期待している
		#[[201312,0],[201311,1],,,,[YYYYMM,count]]形式の返り値

		months = []
		dt = et
		while dt > st
			yyyymm = dt.strftime("%Y%m")
			sql =	["SELECT DATE_FORMAT(published_at,'%Y%m') as YYYYMM, count(id) as count
				FROM portal_article_docs
				WHERE content_id = ?
				GROUP BY YYYYMM
				HAVING YYYYMM = ?", content_id, yyyymm]

			r = PortalArticle::Doc.find_by_sql(sql)
			if r.empty?
				months << [yyyymm, 0] if show_zero
			else
				months << [r[0].attributes['YYYYMM'], r[0].attributes['count']]
			end
			dt = 1.month.ago(dt)
		end
		months.sort!{|x,y|  y[0] <=> x[0]}
		
		return months
	end

	
  def render_feed(docs)
    if ['rss', 'atom'].index(params[:format])
      @site_uri    = Page.site.full_uri
      @node_uri    = @site_uri.gsub(/\/$/, '') + Page.current_node.public_uri
      @req_uri     = @site_uri.gsub(/\/$/, '') + Page.uri
      @feed_name   = "#{Page.title} | #{Page.site.name}"

      data = eval("to_#{params[:format]}(docs)")
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

  def to_rss(docs)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.rss('version' => '2.0') do

      xml.channel do
        xml.title       @feed_name
        xml.link        @req_uri
        xml.language    "ja"
        xml.description Page.title

        docs.each do |doc|
          next unless doc.published_at
          xml.item do
            xml.title        doc.title
            xml.link         doc.public_full_uri
            xml.description  strimwidth(doc.summary, 500)
            xml.pubDate      doc.published_at.rfc822
            doc.category_items.each do |category|
              xml.category   category.title
            end
          end
        end #docs

      end #channel
    end #xml
  end

  def to_atom(docs)
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct! :xml, :version => 1.0, :encoding => 'UTF-8'
    xml.feed 'xmlns' => 'http://www.w3.org/2005/Atom' do

      xml.id      "tag:#{Page.site.domain},#{Page.site.created_at.strftime('%Y')}:#{Page.current_node.public_uri}"
      xml.title   @feed_name
      xml.updated Time.now.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/([0-9][0-9])$/, ':\1')
      xml.link    :rel => 'alternate', :href => @node_uri
      xml.link    :rel => 'self', :href => @req_uri, :type => 'application/atom+xml', :title => @feed_name

      docs.each do |doc|
        next unless doc.published_at
        
        xml.entry do
          xml.id      "tag:#{Page.site.domain},#{doc.created_at.strftime('%Y')}:#{doc.public_uri}"
          xml.title   doc.title
          xml.updated doc.published_at.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/([0-9][0-9])$/, ':\1') #.rfc822
          #xml.summary strimwidth(doc.body, 500), :type => 'text'
          xml.summary(:type => 'html') do |p|
            p.cdata! strimwidth(doc.summary, 500)
          end
          xml.link    :rel => 'alternate', :href => doc.public_full_uri
          #xml.link    :rel => 'enclosure', :href => "#{doc.public_full_uri}#{content.xhtml}", :type => 'text/xhtml'

#          if (c = doc.unit) && (node = doc.content.unit_node)
#            xml.category :term => c.name, :scheme => node.public_full_uri, :label => "組織/#{c.node_label}"
#          end

          if node = doc.content.category_node
            doc.category_items.each do |c|
              xml.category :term => c.name, :scheme => node.public_full_uri, :label => "分野/#{c.node_label}"
            end
          end

#          if node = doc.content.attribute_node
#            doc.attribute_items.each do |c|
#              xml.category :term => c.name, :scheme => node.public_full_uri, :label => "属性/#{c.node_label}"
#           end
#          end

#          if node = doc.content.area_node
#            doc.area_items.each do |c|
#              xml.category :term => c.name, :scheme => node.public_full_uri, :label => "地域/#{c.node_label}"
#            end
#          end

#          if doc.event_state == 'visible' && doc.event_date && node = doc.content.event_node
#            xml.category :term => 'event', :scheme => node.public_full_uri,
#              :label => "イベント/#{doc.event_date.strftime('%Y-%m-%dT%H:%M:%S%z').sub(/([0-9][0-9])$/, ':\1')}"
#          end

          xml.author do |auth|
#            if doc.inquiry && doc.inquiry.group
#              name  = doc.inquiry.group.full_name
#              name += "　#{doc.inquiry.charge}" if !doc.inquiry.charge.blank?
#              auth.name  "#{name}"
#              auth.email "#{doc.inquiry.email}"
#            end
            #auth.uri "#{uri}#{doc.unit.name}/"
          end

          if node = doc.content.tag_node
            doc.tags.each do |c|
              xml.link :rel => 'tag', :href => "#{node.public_full_uri}#{CGI::escape(c.word)}", :type => 'text/xhtml'
            end
          end

#          doc.rel_docs.each do |c|
#            xml.link :rel => 'related', :href => "#{c.public_full_uri}", :type => 'text/xhtml'
#          end

        end #entry
      end #docs
    end #feed
  end
end