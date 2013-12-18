# encoding: utf-8
class Util::Convert
  SITE_BASE_DIR = "#{Rails.application.root.to_s}/wget_sites"

  def self.download_site(url)
    system "wget -rqN -P #{SITE_BASE_DIR} #{url}" if url
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
end
