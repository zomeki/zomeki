# encoding: utf-8
class Tool::Convert
  SITE_BASE_DIR = "#{Rails.application.root.to_s}/wget_sites/"

  def self.download_site(conf)
    return if conf.site_url.blank?
    com = "wget -rqNE --restrict-file-names=nocontrol -P #{SITE_BASE_DIR} #{conf.site_url}"
    com << " -I #{conf.include_dir}" if conf.include_dir.present?
    com << " -l #{conf.recursive_level}" if conf.recursive_level
    system com
  end

  def self.all_site_urls
    child_dirs(SITE_BASE_DIR).map{|dir| dir.sub(SITE_BASE_DIR, '')}.select(&:present?)
  end

  def self.child_dirs(dir)
    return [] if !::File.exist?(dir)
    dirs = [dir]
    Dir::entries(dir).sort.each do |name|
      unless name.valid_encoding?
        dump "#{name} :: directory name encode error.."
        next
      end
      next if name =~ /^\.+/ || ::FileTest.file?(File.join(dir, name))
      dirs += child_dirs(File.join(dir, name))
    end
    dirs
  end

  def self._htmlfiles(path, site_url, count, options, &block)
    Dir.glob("#{path}/*.html").sort.each do |filename|
      next if options[:only_filenames].present? && !options[:only_filenames].include?(::File.basename(filename))
      file_path = File.expand_path(filename)
      uri_path = (Pathname(site_url) + filename).to_s
      count += 1
      block.call file_path, uri_path, count
    end

    if options[:include_child_dir]
      Dir.glob("#{path}/*/").each do |dir|
        next if options[:ignore_dirnames].include?(dir) || options[:ignore_dirnames].include?(dir.sub(/\/$/, ""))
        _htmlfiles(dir.sub(/\/$/, ""), site_url, count, options, &block)
      end
    end
  end

  def self.htmlfiles(site_url, options={}, &block)
    root_dir = "#{SITE_BASE_DIR}#{site_url}"
    if !File.exist?(root_dir)
      dump "ルートフォルダが見つからない"
    end

    options[:ignore_dirnames] ||= []
    options[:include_child_dir] ||= true
    options[:only_filenames] ||= []
    Dir.chdir(root_dir) {
      _htmlfiles(".", site_url, 0, options, &block)
    }
  end

  def self.import_site(conf)
    if conf.site_filename.present?
      conf.total_num = 1
      conf.save
    else
      conf.total_num = `find #{SITE_BASE_DIR}#{conf.site_url} -type f | wc -l`.chomp
      conf.save
    end

    options = {}
    options[:only_filenames] = [conf.site_filename] if conf.site_filename.present?

    dump "書き込み処理開始: #{conf.total_num}件"
    htmlfiles(conf.site_url, options) do |file_path, uri_path, i|
      dump "[#{i}] #{uri_path}"
      page = Tool::Convert::PageParser.new.parse(file_path, uri_path, conf.convert_setting)

      if page.kiji_page?
        dump "#{page.title},#{page.updated_at},#{page.group_code}"
        db = Tool::Convert::DbProcessor.new.process(page, conf)
        case db.process_type
        when 'created'
          conf.created_num += 1
        when 'updated'
          conf.updated_num += 1
        when 'nonupdated'
          conf.nonupdated_num += 1
        end
        dump "#{db.process_type_label},#{db.cdoc.class.name},#{db.cdoc.id},#{db.cdoc.docable_type},#{db.cdoc.docable_id}"
      else
        conf.skipped_num += 1
        dump "非記事（#{'タイトル' if page.title.blank?}#{'本文' if page.body.blank?}無し）"
      end

      conf.save if i % 100 == 0
    end

    conf.save
    dump "書き込み処理終了"
  end

  def self.process_link(conf, updated_at = nil)
    items = Tool::ConvertDoc
    items = items.where('updated_at >= ?', updated_at) if updated_at
    items = items.order('id')

    conf.link_total_num = items.count
    conf.save

    dump "リンク解析処理開始: #{conf.link_total_num}件"
    items.find_in_batches(batch_size: 10) do |cdocs|
      cdocs.each do |cdoc|
        conf.link_processed_num += 1
        dump "[#{conf.link_processed_num}] #{cdoc.uri_path}"

        if doc = cdoc.latest_doc
          link = Tool::Convert::LinkProcessor.new.sublink(cdoc, conf)
          link.clinks.each do |clink|
            dump "#{clink.url} => #{clink.after_url}" if clink.url_changed?
          end
        else
          dump "記事検索失敗"
        end

        conf.save if conf.link_processed_num % 100 == 0
      end
    end

    conf.save
    dump "リンク解析処理終了"
  end
end
