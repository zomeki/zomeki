# encoding: utf-8
class Tool::Convert::LinkProcessor
  attr_reader :body, :after_body, :clinks

  def sublink(cdoc, conf)
    @body = cdoc.body.dup
    @after_body = cdoc.body.dup
    @clinks = []
    site_url = cdoc.site_url
    host = cdoc.site_url.split('/')[0]

    html = Nokogiri::HTML.fragment(@body)
    html.xpath("./a[@href]|.//a[@href]|./area[@href]|.//area[@href]|./img[@src]|.//img[@src]").each do |e|
      clink = Tool::Convert::Link.new
      clink.cdoc = cdoc
      clink.tag = e.name
      clink.attr = ['a', 'area'].include?(e.name) ? 'href' : 'src'
      clink.url = e[clink.attr].to_s.dup
      clink.after_url = clink.url.dup

      url = preprocess_url(clink.url)
      next if url.blank?

      uri = normalize_url(url, cdoc.uri_path)
      next if uri.blank?
      next if uri.scheme != 'http' && uri.scheme != 'https'
      next if uri.host != host

      case File.extname(uri.path).downcase
      when '.html', '.htm', '.php', '.asp', ''
        convert_doc_link(uri, clink)
      else
        convert_file_link(uri, clink)
      end

      if clink.url_changed?
        @clinks << clink
        e[clink.attr] = clink.after_url
        e['class'] = "iconFile icon#{clink.ext.capitalize}" if clink.tag == 'a' && clink.filename.present?
        e['onclick'] = e['onclick'].to_s.dup.gsub(clink.url, clink.after_url) if e.attributes['onclick']
      end
    end

    doc = cdoc.latest_doc
    return self unless doc

    @clinks.each do |clink|
      if clink.filename.present? && !doc.files.find_by_name(clink.filename)
        if file = create_file(doc, clink)
          doc.files.push(file)
        end
      end
    end

    doc.body = @after_body = html.inner_html
    doc.ignore_accessibility_check = conf.ignore_accessibility_check
    doc.publish_files
    unless doc.save
      dump "記事保存失敗"
      dump doc.errors.full_messages
    end

    return self
  end

private

  def preprocess_url(url)
    url.gsub(%r{/file/open\.php\?f\=}, '')
      .gsub(%r{/soshiki/index\.php\?type\=2$}, '/soshiki/')
      .gsub(%r{/soshiki/kakubu\.php\?sec_sec2\=(\d+)$}, "/soshiki/#{$1}/")
      .gsub(%r{/soshiki/kakuka\.php\?sec_sec1\=(\d+)$}, "/soshiki/#{$1}/")
  end

  def normalize_url(url, uri_path)
    uri = URI.parse("http://#{uri_path}").merge(url)
    uri.path = '/' unless uri.path
    uri
  rescue => e
    nil
  end

  def convert_doc_link(uri, clink)
    # 他記事へのリンク
    linked_cdoc = Tool::ConvertDoc.where(uri_path: "#{uri.host}#{uri.path}").first
    # 他記事へのリンク(index.html補完)
    if !linked_cdoc && uri.path[-1] == '/'
      linked_cdoc = Tool::ConvertDoc.where(uri_path: "#{uri.host}#{uri.path}index.html").first
    end
    # 他記事へのリンク(.html補完)
    if !linked_cdoc && (!uri.path.include?('.') || uri.path[-4..-1] == '.htm' )
      linked_cdoc = Tool::ConvertDoc.where(uri_path: "#{uri.host}#{uri.path}.html").first
    end

    uri = uri.dup
    uri.scheme = uri.host = nil

    if linked_cdoc
      uri.path = ""
      if linked_cdoc == clink.cdoc
        clink.after_url = uri.to_s
      else
        clink.after_url = linked_cdoc.doc_public_uri
        clink.after_url += uri.to_s
      end
    else
      clink.after_url = uri.to_s
    end
  end

  def convert_file_link(uri, clink)
    file_path = "#{Tool::Convert::SITE_BASE_DIR}#{URI.unescape(uri.to_s).gsub(%r{^\w+://}, '')}"

    if File.file?(file_path)
      clink.file_path = file_path
      clink.ext = File.extname(uri.path).gsub(/^\./, '')
      clink.filename = "#{uri.host}#{uri.path}".sub(/^\//, "").gsub(/\/|\.|\(|\)/, "_").gsub(/_#{clink.ext}$/i, ".#{clink.ext}")
      clink.filename = "#{clink.cdoc.doc_name}_#{clink.filename}"
      clink.after_url = "./file_contents/#{clink.filename}"
    else
      dump "ファイル検索失敗:#{file_path}"
    end
  end

  def create_file(doc, clink)
    file = Sys::File.new
    file.file = Sys::Lib::File::NoUploadedFile.new(clink.file_path, :skip_image => true)
    file.parent_unid = doc.unid
    file.name = clink.filename
    file.title = clink.filename
    file.in_creator = doc.in_creator

    unless file.save
      dump "ファイル保存失敗:#{clink.file_path}"
      dump file.errors.full_messages
    end
  end
end
