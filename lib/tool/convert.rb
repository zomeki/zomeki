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

  # params:
  #   site_url
  #   content_id
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
      page_info = Tool::Convert::PageParseInfo.new(host, file_path, uri_path, options[:parse_xpaths])

      if page_info.is_kiji_page?
        processor = Tool::Convert::NormalKijiDbProcessor.new(page_info, options[:db_options])
        processor.process

        # puts "#{i + 1} #{page_info.title}\t#{page_info.name}"
        i += 1
      else
        puts "parse:パース失敗(記事ページではない):#{file_path}"
      end

    end
    
  end

private

  def _htmlfiles(path, host, options, &block)
    Dir.glob("#{path}/*.html").each do |file|
      file_path = File.expand_path(file)
      uri_path = (Pathname(host) + file).to_s
      block.call file_path, uri_path, options
    end

    Dir.glob("#{path}/*/").each do |dir|
      next if options[:ignore_dir_list].include?(dir) || options[:ignore_dir_list].include?(dir.sub(/\/$/, ""))
      _htmlfiles(dir.sub(/\/$/, ""), host, options, &block)
    end
  end

  ### 
  # params 
  #   root:
  #   host:
  #   options:
  #     { 
  #       html_options: {
  #         # ignore_list: array, the directory list to ignore process
  #         # default: []
  #         # eg: ["./dira", "./dirb/", ...]
  #         ignore_dir_list: [],
  #       },
  #      parse_xpaths: {
  #         title_xpath: "//div[@id='id_z1_body']/form/h1",
  #         body_xpath: "//div[@id='id_z1_width']"
  #       },
  #      db_options: {
  #          content_id: 1,
  #          creator: {group_id: 1, user_id: 1}
  #        }
  #     }
  def htmlfiles(root, host, options={}, &block)
    if !File.exist?(root)
      puts "error parse:ルートフォルダが見つからない"
    end

    _options = { ignore_dir_list: [] }.merge options[:html_options]

    Dir.chdir(root){
      _htmlfiles(".", host, _options, &block)
    }
  end

end
