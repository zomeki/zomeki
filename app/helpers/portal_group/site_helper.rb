# encoding: utf-8
module PortalGroup::SiteHelper
  def portal_group_sites_view(sites, list_type = :opened)
    return nil if sites.size == 0
    
    h = ''
    if list_type.to_s == 'list'
      h += %Q(<ul class="sites">)
      sites.each {|site| h += portal_group_site_view(site, list_type) }
      h += %Q(</ul>)
    else
      h += %Q(<div class="sites">)
      sites.each {|site| h += portal_group_site_view(site, list_type) }
      h += %Q(</div>)
    end
    return h.html_safe
  end
  
  def portal_group_site_view(site, list_type = :opened)
    if list_type.to_s == 'list'
      h = %Q(<li>#{link_to(site.name, site.full_uri)}</li>)
      return h.html_safe
    end
    
    unless (pa = site.created_at).blank?
      date = pa.strftime('%Y年%-m月%-d日')
      time = pa.strftime('%-H時%-M分')
    else
      date = nil
      time = nil
    end
    
    thumb = nil
    if uri = site.site_image_uri
      if uri =~ /^\/_files\//i
        uri = uri.gsub(/^\//, site.full_uri)
        thumb = %Q(<a href="#{uri}" target="_blank"><img src="#{uri}" style="width: 120px;" alt="" title="" /></a>).html_safe
      end
    end
    
    summary = site.body.to_s
    summary.sub!(/<[^<>]*>/,"") while /<[^<>]*>/ =~ summary
    summary = truncate(summary, :length => 200)
    summary = summary.html_safe
    
    h  = %Q(<section>)
    h += %Q(<header>)
    h += %Q(<h3 class="siteName">#{link_to(site.name, site.full_uri, :target => '_blank')}</h3>)
    h += %Q(</header>)
    h += %Q(<div class="thumb">#{thumb}</div>) if thumb
    h += %Q(<p class="summary">#{summary}</p>)
    h += %Q(<footer>)
    h += %Q(<p class="date">#{h(date)}<span class="time">#{h(time)}</span></p>)
    h += %Q(</footer>)
    h += %Q(</section>)
    
    h.html_safe
  end
end
