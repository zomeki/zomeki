# encoding: utf-8
class Cms::Lib::BreadCrumbs
  @crumbs = []
  def initialize(crumbs = [])
    @crumbs = crumbs if crumbs
  end
  
  def crumbs
    @crumbs
  end
  
  def to_links
    h = ''
    @crumbs.each do |r|
      links = []
      if r.first[1] == Page.site.uri
        r.first[0] = "TOP"
      end
      if r.last[1] =~ /index\.html$/
        r.pop
      end
      r.each do |c|
        if c[0].class == Array
          l = []
          c.each do |c2|
            l << %Q(<a href="#{c2[1]}">#{c2[0]}</a>)
          end
          links << l.join("，")
        else
          links << %Q(<a href="#{c[1]}">#{c[0]}</a>)
        end
      end
      h += "<div>#{links.join(' &gt; ')}</div>"
    end
    h.html_safe
  end
end