# encoding: utf-8
module PortalGroup::DocHelper
  def portal_group_docs_view(docs, list_type = :opened)
    return nil if docs.size == 0
    
    h = ''
    if list_type.to_s == 'list'
      h += %Q(<ul class="docs">)
      docs.each {|doc| h += portal_group_doc_view(doc, list_type) }
      h += %Q(</ul>)
    else
      h += %Q(<div class="docs">)
      docs.each {|doc| h += portal_group_doc_view(doc, list_type) }
      h += %Q(</div>)
    end
    return h.html_safe
  end
  
  def portal_group_doc_view(doc, list_type = :opened)
    if list_type.to_s == 'list'
      h = %Q(<li>#{link_to(doc.title, doc.public_full_uri)}#{h(doc.date_and_site)}</li>)
      return h.html_safe
    end
    
    site  = (doc.content && doc.content.site) ? doc.content.site : nil
    unless (pa = doc.published_at).blank?
      date = pa.strftime('%Y年%-m月%-d日')
      time = pa.strftime('%-H時%-M分')
    else
      date = nil
      time = nil
    end
    
    thumb = nil
    if doc.body =~ /^.*?<img [^>]*src="[^>"]*?".*?>/i
      uri = doc.body.gsub(/^.*?<img [^>]*src="([^>"]+?)".*?>.*/im, '\\1')
      if uri =~ /^\.\/files\//i
        uri = uri.gsub(/^\.\//, doc.public_full_uri)
        thumb = %Q(<a href="#{uri}" target="_blank"><img src="#{uri}" style="width: 120px;" alt="" title="" /></a>).html_safe
      end
    end
    
    summary = doc.summary.to_s
    summary.sub!(/<[^<>]*>/,"") while /<[^<>]*>/ =~ summary
    summary = truncate(summary, :length => 200)
    summary = summary.html_safe
    
    h  = %Q(<article>)
    h += %Q(<header>)
    h += %Q(<h3 class="docTitle">#{link_to(doc.title, doc.public_full_uri, :target => '_blank')}</h3>)
    h += %Q(<p class="siteName">[#{link_to(site.name, site.full_uri, :target => '_blank')}]</p>) if site
    h += %Q(</header>)
    h += %Q(<div class="thumb">#{thumb}</div>) if thumb
    h += %Q(<p class="summary">#{summary}</p>)
    h += %Q(<footer>)
    h += %Q(<p class="date">#{h(date)}<span class="time">#{h(time)}</span></p>)
    h += %Q(</footer>)
    h += %Q(</article>)
    
    h.html_safe
  end
end
