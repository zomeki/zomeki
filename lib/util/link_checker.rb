# encoding: utf-8
class Util::LinkChecker
  def self.check
    in_progress = check_in_progress
    in_progress.update_column(:in_progress, false) if in_progress
    if in_progress.nil? || !in_progress.in_progress
      link_check = plan_check
      link_check.execute
    end
  end

  def self.plan_check(link_check=nil)
    if link_check
      link_check.logs.clear
    else
      link_check = Cms::LinkCheck.create
    end

    GpArticle::Content::Doc.where(site_id: Core.site.id).each do |c|
      c.docs.each do |doc|
        doc.links.each do |link|
          info_log "Planning #{link.url} to check in GpArticle::Doc(#{doc.id})"

          begin
            uri = URI.parse(link.url)
            url = unless uri.absolute?
                    next unless uri.path =~ /^\//
                    "#{doc.content.site.full_uri.sub(/\/$/, '')}#{uri.path}"
                  else
                    uri.to_s
                  end

            link_check.logs.create(link_checkable: doc, title: doc.title,
                                   body: link.body, url: url)
          rescue => evar
            warn_log evar.message
          end
        end
      end
    end

    return link_check
  end

  def self.check_url(url)
    info_log "Checking #{url}"

    require 'httpclient'
    client = HTTPClient.new

    res = client.head(url)
    if res.redirect?
      3.times do
        break unless res.redirect?

        uri = URI.parse(res.headers['Location'] || res.headers['location'])
        next_url = unless uri.absolute?
                     path = uri.path

                     u = URI.parse(url)
                     if path =~ /^\//
                       u.path = path
                     else
                       u.path = '/' if u.path.blank?
                       u.path.sub!(/[^\/]+$/, '')
                       u.path.concat(path)
                     end
                     u.to_s
                   else
                     uri.to_s
                   end

        res = client.head(next_url)
      end
    end
    {status: res.status, reason: res.reason, result: res.ok?}
  rescue => evar
    warn_log evar.message
    {status: nil, reason: evar.message, result: false}
  end

  def self.check_in_progress
    Cms::LinkCheck.find_by_in_progress(true)
  end

  def self.last_check
    Cms::LinkCheck.first
  end
end
