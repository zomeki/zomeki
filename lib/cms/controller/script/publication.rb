require 'timeout'
class Cms::Controller::Script::Publication < ApplicationController
  include Cms::Controller::Layout
  before_filter :initialize_publication

  def self.publishable?
    true
  end

  def initialize_publication
    if @node = params[:node] || Cms::Node.where(id: params[:node_id]).first
      @site = @node.site
    end
    @errors = []
  end

  def publish_page(item, params = {})
    site = params[:site] || @site

    if params[:smart_phone].present?
      return false unless site.publish_for_smart_phone?
      return false unless site.spp_all? || (site.spp_only_top? && item.respond_to?(:top_page?) && item.top_page?)
    end

    ::Script.current

    if ::Script.options
      path = params[:uri].to_s.sub(/\?.*/, '')
      return false if ::Script.options.is_a?(Array) && !::Script.options.include?(path)
      return false if ::Script.options.is_a?(Regexp) && ::Script.options !~ path
    end

    rendered = render_public_as_string(params[:uri], site: site,
                                       jpmobile: (params[:smart_phone] ? envs_to_request_as_smart_phone : nil))
    res  = item.publish_page(rendered, :path => params[:path], :dependent => params[:dependent])
    return false unless res
    #return true if params[:path] !~ /(\/|\.html)$/

    if params[:smart_phone_path].present? && site.publish_for_smart_phone? &&
       (site.spp_all? || (site.spp_only_top? && item.respond_to?(:top_page?) && item.top_page?))

      rendered = render_public_as_string(params[:uri], site: site, jpmobile: envs_to_request_as_smart_phone)
      res = item.publish_page(rendered, path: params[:smart_phone_path], dependent: "#{params[:dependent]}_smart_phone")
      return false unless res
    end

    ::Script.success if item.published?

    ## ruby html
    return true unless Zomeki.config.application['cms.use_kana']
    ids = Zomeki.config.application['cms.use_kana_exclude_site_ids'] || []
    return true if ids.include?(site.id)

    uri = params[:uri]
    if uri =~ /\.html$/
      uri += ".r"
    elsif uri =~ /\/$/
      uri += "index.html.r"
    elsif uri =~ /\/\?/
      uri = uri.gsub(/(\/)(\?)/, '\\1index.html.r\\2')
    elsif uri =~ /\.html\?/
      uri = uri.gsub(/(\.html)(\?)/, '\\1.r\\2')
    else
      return true
    end

    #uri  = (params[:uri] =~ /\.html$/ ? "#{params[:uri]}.r" : "#{params[:uri]}index.html.r")
    path = (params[:path] =~ /\.html$/ ? "#{params[:path]}.r" : "#{params[:path]}index.html.r")
    smart_phone_path = if params[:smart_phone_path].present? && site.publish_for_smart_phone? &&
                          (site.spp_all? || (site.spp_only_top? && item.respond_to?(:top_page?) && item.top_page?))
        params[:smart_phone_path] =~ /\.html$/ ? "#{params[:smart_phone_path]}.r" : "#{params[:smart_phone_path]}index.html.r"
      else
        nil
      end
    dep  = params[:dependent] ? "#{params[:dependent]}/ruby" : "ruby"

    ruby = nil
    if item.published?
      ruby = true
    elsif !::File.exist?(path)
      ruby = true
    elsif ::File.stat(path).mtime < Cms::KanaDictionary.dic_mtime
      ruby = true
    end

    if ruby
      begin
        timeout(600) do
          rendered = render_public_as_string(uri, site: site, jpmobile: (params[:smart_phone] ? envs_to_request_as_smart_phone : nil))
          item.publish_page(rendered, :path => path, :dependent => dep)
          if smart_phone_path
            rendered = render_public_as_string(uri, site: site, jpmobile: envs_to_request_as_smart_phone)
            item.publish_page(rendered, path: smart_phone_path, dependent: "#{dep}_smart_phone")
          end
        end
      rescue TimeoutError => e
        ::Script.error "#{uri} Timeout"
      rescue => e
        ::Script.error "#{uri}\n#{e.message}"
      end
    end

    return res
  rescue => e
    ::Script.error "#{uri}\n#{e.message}"
    error_log e.message
    return false
  end

  def publish_more(item, params = {})
    stopp = nil
    limit = params[:limit] || Zomeki.config.application["cms.publish_more_pages"].to_i rescue 0
    limit = (limit < 1 ? 1 : 1 + limit)
    file  = params[:file] || 'index'
    first = params[:first] || 1
    first.upto(limit) do |p|
      page = (p == 1 ? "" : ".p#{p}")
      uri  = "#{params[:uri]}#{file}#{page}.html"
      path = "#{params[:path]}#{file}#{page}.html"
      smart_phone_path = (params[:smart_phone_path].present? ? "#{params[:smart_phone_path]}#{file}#{page}.html" : nil)
      dep  = "#{params[:dependent]}#{page}"
      rs = publish_page(item, uri: uri, site: params[:site], path: path, smart_phone_path: smart_phone_path,
                              dependent: dep, smart_phone: params[:smart_phone])
      unless rs
        stopp = p
        break
      end
      #return item.published? ## file updated
    end

    ## remove over files
    first = stopp ? stopp : (limit + 1)
    first.upto(9999) do |p|
      dep = "#{params[:dependent]}.p#{p}"
      pub = Sys::Publisher.find(:first, :conditions => {:unid => item.unid, :dependent => dep})
      break unless pub
      pub.destroy
      pub = Sys::Publisher.find(:first, :conditions => {:unid => item.unid, :dependent => "#{dep}/ruby"})
      pub.destroy if pub
    end
  end
end
