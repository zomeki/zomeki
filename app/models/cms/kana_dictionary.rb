# encoding: utf-8
class Cms::KanaDictionary < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager
  
  validates_presence_of :name
  
  before_save :convert_csv
  
  def self.mecab_rc(_site_id=nil)
    user_dic(_site_id) # confirm
    return site_mecab_rc(_site_id)
  end
  
  def self.user_dic(_site_id=nil)
    mecab_dir = "#{Rails.root}/config/mecab/"
    if _site_id.blank?
      dic = ::File.join(mecab_dir, "zomeki.dic")
    else
      site_dir  = ::File.join("#{mecab_dir}", "sites", format('%08d', _site_id).gsub(/((..)(..)(..)(..))/, '\\2/\\3/\\4/\\5/\\1'))
      dic = ::File.join(site_dir, "zomeki.dic")
    end
    
    if ::File.exists?(dic)
      return dic 
    else
      ::FileUtils.mkdir_p(site_dir) if !_site_id.blank? && !::File.exists?(site_dir)
      FileUtils.cp("#{mecab_dir}zomeki.dic.original", dic)
    end
    return dic
  end

  def self.site_mecab_rc(_site_id=nil)
    mecab_dir = "#{Rails.root}/config/mecab/"

    if _site_id.blank?
      rc = ::File.join(mecab_dir, "mecabrc")
    else
      site_dir  = ::File.join("sites", format('%08d', _site_id).gsub(/((..)(..)(..)(..))/, '\\2/\\3/\\4/\\5/\\1'))
      rc = ::File.join(mecab_dir, site_dir, "mecabrc")
    end

    if ::File.exists?(rc)
      return rc
    else
      ::FileUtils.mkdir_p(site_dir) if !_site_id.blank? && !::File.exists?(site_dir)
      originalrc = "#{mecab_dir}mecabrc"
      f = ::File.read(originalrc)
      data = f.gsub(/zomeki\.dic/, "#{site_dir}/zomeki.dic")
      ::File.write(rc, data)
    end
    return rc
  end
  
  def self.dic_mtime(_site_id=nil)
    pkey = "mecab_dic_mtime"
    return Core.config[pkey] if Core.config[pkey]
    
    file = user_dic(_site_id)
    return Core.config[pkey] = ::File.mtime(file)
  end
  
  def convert_csv
    csv = []
    
    body.split(/(\r\n|\n)/u).each_with_index do |line, idx|
      line = line.to_s.gsub(/#.*/, "")
      line.strip!
      next if line.blank?
      
      data = line.split(/\s*,\s*/)
      word = data[0].strip
      kana = data[1].strip.tr("ぁ-ん", "ァ-ン")
      hira = kana.tr("ァ-ン", "ぁ-ん")
      
      errors.add :base, "フォーマットエラー: #{line} (#{idx+1}行目)" if !data[1] || data[2]
      errors.add :base, "フォーマットエラー: #{line} (#{idx+1}行目)" if kana !~ /^[ァ-ンー]+$/
      return false if errors.size > 0
      
      csv << "#{word},*,*,100,名詞,固有名詞,*,*,*,*,#{hira},#{kana},#{kana}"
    end
    
    self.mecab_csv = csv.join("\n")
    
    return true
  end
  
  def self.make_dic_file(_site_id=nil)
    mecab_index = Zomeki.config.application['cms.mecab_index']
    mecab_dic   = Zomeki.config.application['cms.mecab_dic']
    
    errors = []
    data   = []

    items = self.order(:id)
    items = items.where(site_id: _site_id) if _site_id.present?
    items.each do |item|
      if item.mecab_csv == nil
        data << item.mecab_csv if item.convert_csv == true
        next 
      end
      data << item.mecab_csv if !item.mecab_csv.blank?
    end
    
    if data.blank?
      errors << "登録データが見つかりません。"
      return errors.size > 0 ? errors : true
    end
    
    csv = Tempfile::new(["mecab", ".csv"], '/tmp')
    csv.puts(data.join("\n"))
    csv.close
    
    dic = user_dic(_site_id)
    
    require "shell"
    sh = Shell.new
    sh.transact do
      res = system("#{mecab_index} -d#{mecab_dic} -u #{dic} -f utf8 -t utf8 #{csv.path}").to_s.strip
      errors << "辞書の作成に失敗しました" unless res =~ /done!$/
    end
    
    FileUtils.rm(csv.path) if FileTest.exists?(csv.path)
    
    return errors.size > 0 ? errors : true
  end
end
