# encoding: utf-8
class Tool::Convert
  SITE_BASE_DIR = "#{Rails.application.root.to_s}/wget_sites"

  def self.download_site(url)
    system "wget -rqNE -P #{SITE_BASE_DIR} #{url}" if url
  end

  def self.all_site_urls
    items = []
    if ::FileTest.directory?(SITE_BASE_DIR)
      Dir::entries(SITE_BASE_DIR).sort.each do |name|
        items << name unless name =~ /^\.+/ || ::FileTest.file?(::File.join(SITE_BASE_DIR, name))
      end
    end
    items
  end

  # params: {
  #   site_url: 
  #   content_id: 
  # }
  def self.import_site(params={})
    return false unless params[:site_url] && params[:content_id]

    root = "#{SITE_BASE_DIR}/#{params[:site_url]}"
    host = params[:site_url]

    # TODO dairg xpathsの設定

    opts = { 
      html_options: {
        ignore_dir_list: [],
      },
      parse_xpaths: {
        title_xpath: "//div[@id='id_z1_body']/form/h1",
        body_xpath: "//div[@id='id_z1_width']"
      },
      db_options: {
        content_id: params[:content_id],
        creator: {group_id: 1, user_id: 1}
      }
    }

    i = 0
    htmlfiles(root, host, opts) do |file_path, uri_path, options|
      page_info = Tool::Convert::PageParseInfo.new(host, file_path, uri_path, opts[:parse_xpaths])
      page_info.parse

      if page_info.is_kiji_page?
        processor = Tool::Convert::NormalKijiDbProcessor.new(page_info, opts[:db_options])
        processor.process

        puts "#{i + 1} #{page_info.title}\t#{processor.target_name}"
        i += 1
      else
        puts "parse:パース失敗(記事ページではない):#{file_path}"
      end

    end

    return true
  end

  def self._htmlfiles(path, host, html_options, &block)
    Dir.glob("#{path}/*.html").each do |file|
      file_path = File.expand_path(file)
      uri_path = (Pathname(host) + file).to_s
      block.call file_path, uri_path, html_options
    end

    Dir.glob("#{path}/*/").each do |dir|
      next if html_options[:ignore_dir_list].include?(dir) || html_options[:ignore_dir_list].include?(dir.sub(/\/$/, ""))
      _htmlfiles(dir.sub(/\/$/, ""), host, html_options, &block)
    end
  end

  ### 
  # params 
  #   root:
  #   host:
  #   html_options: {
  #     # ignore_list: array, the directory list to ignore process
  #     # default: []
  #     # eg: ["./dira", "./dirb/", ...]
  #     ignore_dir_list: [],
  #   }
  def self.htmlfiles(root, host, html_options={}, &block)
    if !File.exist?(root)
      puts "error parse:ルートフォルダが見つからない"
    end

    _html_options = { ignore_dir_list: [] }.merge html_options

    Dir.chdir(root) {
      _htmlfiles(".", host, _html_options, &block)
    }
  end

  def self.process_link
    i = 0
    Tool::ConvertDoc.find(:all).each do |cdoc|
      doc = GpArticle::Doc.find(:first, :conditions => {:name => cdoc.name})
      if !doc
        puts "doc検索失敗"
        next
      end

      # TODO dairg 設定できるように
      doc.ignore_accessibility_check = true
      puts "#{i + 1} #{doc.title}\t#{doc.name}"
    
      links = Tool::Convert::LinkProcessor.sublink(cdoc.body, cdoc, doc.content.public_node.public_uri)
      doc.body = links[:body]
      links[:upload].each do |pfile|
        file = Tool::Convert::LinkProcessor.upload_file(doc, pfile, "#{SITE_BASE_DIR}/#{pfile[:link_uri_path]}")
        doc.files.push(file) if file
      end
      
      doc.publish_files if doc.files != []
      if !doc.save
        puts "doc save失敗"
        p doc.errors.full_messages
      end
      
      #50回に１回ガベレージコレクタ
      if ((i + 1) % 50) == 0
        puts "GC.start"
        GC.start
      end
      i += 1
    end
  end

end
