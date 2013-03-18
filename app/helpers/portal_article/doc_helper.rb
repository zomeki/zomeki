# encoding: utf-8
module PortalArticle::DocHelper
	def portal_article_archive_list(base_uri, list)
		content_tag(:ul) do
			list.each do |item|
				year = item[0][0,4]
				month = item[0][4,2]
				count = item[1]
				uri = base_uri + year + '/' + month + '/'
				concat content_tag(:li, link_to_if(count.to_i > 0, sprintf("%s年%s月(%d)", year, month, count), uri))
			end
		end
	end

  def portal_article_docs_view(docs, list_type = :opened)
    return nil if docs.size == 0
    
    h = ''
    if list_type.to_s == 'list'
      h += %Q(<ul class="docs">)
      docs.each {|doc| h += portal_article_doc_view(doc, list_type) }
      h += %Q(</ul>)
    else
      h += %Q(<div class="docs">)
      docs.each {|doc| h += portal_article_doc_view(doc, list_type) }
      h += %Q(</div>)
    end
    return h.html_safe
  end
  
  def portal_article_doc_view(doc, list_type = :opened)
    if list_type.to_s == 'list'
      h = %Q(<li>#{link_to(doc.title, doc.public_full_uri)}#{h(doc.date_and_unit)}</li>)
    else
      unless (pa = doc.published_at).blank?
        date = pa.strftime('%Y年%-m月%-d日')
        time = pa.strftime('%-H時%-M分')
      else
        date = nil
        time = nil
      end
      thumb = nil
      if doc.body =~ /^.*?<img [^>]*src="[^>"]*?".*?>/i
        uri   = doc.body.gsub(/^.*?<img [^>]*src="([^>"]+?)".*?>.*/im, '\\1')
        if uri =~ /^\.\/files\//
          uri = uri.gsub(/^\.\//, doc.public_uri)
          thumb = %Q(<a href="#{uri}" target="_blank"><img src="#{uri}" style="width: 120px;" alt="" /></a>).html_safe
        end
      end
      
      if doc.body =~ /\[\[\/?summary\]\]/
        summary = doc.summary
        summary = summary.gsub(/(<a [^>]*href=")\.\/([^>"]+?".*?>)/im, '\\1' + doc.public_uri + '\\2')
        if summary =~ /^.*?<img [^>]*src="[^>"]*?".*?>/i
          thumb = nil
          summary = summary.gsub(/(<img [^>]*src=")\.\/([^>"]+?".*?>)/im, '\\1' + doc.public_uri + '\\2')
        end
      else
        summary = doc.body.to_s
        summary.sub!(/<[^<>]*>/,"") while /<[^<>]*>/ =~ summary
        summary = truncate(summary, :length => 200)
      end
      summary = summary.html_safe
      
      h  = %Q(<article>)
      h += %Q(<header>)
      h += %Q(<h3 class="docTitle">#{link_to(doc.title, doc.public_uri)}</h3>)
      h += %Q(</header>)
      h += %Q(<div class="thumb">#{thumb}</div>) if thumb
      h += %Q(<p class="summary">#{summary}</p>)
      h += %Q(<footer>)
      h += %Q(<p class="date">#{h(date)}<span class="time">#{h(time)}</span></p>)
      h += %Q(</footer>)
      h += %Q(</article>)
    end
    h.html_safe
  end
end
