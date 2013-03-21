# encoding: utf-8
class Cms::KanaDictionary < ActiveRecord::Base
  include Sys::Model::Base
  include Sys::Model::Base::Config
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Sys::Model::Auth::Manager
  
  validates_presence_of :name
  
  before_save :convert_to_dic
  
  def self.dic_mtime(type)
    dic = nil
    if type == :ruby
      dic = "ipadic"
    elsif type == :talk
      dic = "unidic"
    end
    if dic
      pkey = "kana_#{dic}_mtime"
      file = "#{Rails.root}/ext/morph/#{dic}/cmsdic.da"
      return Core.config[pkey] if Core.config[pkey]
      return nil unless ::File.exist?(file)
      return Core.config[pkey] = ::File.stat(file).mtime #TODO
    end
    return nil
  end
  
  def search_category(str, type)
    ENV['PATH'] = ENV['PATH'].split(':').concat(%w!/usr/local/sbin /usr/local/bin!).uniq.join(':')

    unless @sh
      require 'shell'
      @sh = Shell.cd("#{Rails.root}/ext")
    end
    if type == :ruby
      @sh.cd("#{Rails.root}/ext")
      chasenrc = './config/chasenrc_ruby'
    else
      @sh.cd("#{Rails.root}/ext/gtalk")
      chasenrc = '../config/chasenrc_gtalk'
    end
    format   = '%P /'
    logger.info command = "echo \"#{str}\" | chasen -i w -r #{chasenrc} -F '#{format}'"
    
    res = nil
    @sh.transact { res = system("#{command}").to_s }
    logger.info res
    return res.to_s.force_encoding('utf-8').gsub(/\/.*/, '').strip
  end
  
  def convert_to_dic
    self.ipadic_body = ''
    self.unidic_body = ''
    
    words = self.body.split(/\n/u)
    words.each_with_index do |line, idx|
      next if line.strip == ''
      next if line.slice(0, 1) == '#'
      
      data = line.split(/,/)
      if !data[1] || data[2]
        errors.add_to_base "フォーマットエラー: #{line} (#{idx+1}行目)"
        return false
      end
      word = data[0].strip
      kana = data[1].strip.tr("ぁ-ん", "ァ-ン")
      kana.gsub!(/([アカサタナハマヤラワガザダバパァャヮ])ー/u, '\1ア')
      kana.gsub!(/([イキシチニヒミリギジヂビピィ])ー/u, '\1イ')
      kana.gsub!(/([ウクスツヌフムルグズヅブプゥュ])ー/u, '\1ウ')
      kana.gsub!(/([エケセテネヘメレゲゼデベペェ])ー/u, '\1エ')
      kana.gsub!(/([オコソトノホモロヲゴゾドボポォョ])ー/u, '\1オ')
      
      ## ipadic
      category = search_category(word, :ruby)
      if !category.blank?
        self.ipadic_body += '(品詞 (' + category + '))' +
          ' ((見出し語 (' + word+ ' 500)) (読み ' + kana + ') (発音 ' + kana + '))' + "\n"
      end
      
      ## unidic
      goshu = '和'
      if word =~ /^[一-龠]+/
        goshu = '漢'
      elsif word =~ /^[Ａ-Ｚ]+/
        goshu = '記号'
      end
      word.tr!("0-9a-zA-Z", "０-９ａ-ｚＡ-Ｚ")
      kana.gsub!(/[^ァ-ン]/, '')
      category = search_category(word, :gtalk)
      if !category.blank?
        self.unidic_body += '(POS (' + category + '))' +
          ' ((LEX (' + word + ' 500)) (READING ' + kana + ') (PRON ' + kana + ')'+
          ' (INFO "lForm=\"' + kana + '\" lemma=\"' + word + '\" orthBase=\"' + word + '\"' +
          ' pronBase=\"' + kana + '\" kanaBase=\"' + kana + '\" formBase=\"' + kana + '\"' +
          ' goshu=\"' + goshu + '\" aType=\"0\" aConType=\"C2\""))' + "\n"
      end
    end
    return true
  end
  
  def self.make_dic_file
    ENV['PATH'] = ENV['PATH'].split(':').concat(%w!/usr/local/sbin /usr/local/bin!).uniq.join(':')

    dic_data = {:ipadic => '', :unidic => ''}
    
    self.find(:all, :order => "id").each do |item|
      dic_data[:ipadic] += item.ipadic_body.gsub(/\r\n/, "\n") + "\n"
      dic_data[:unidic] += item.unidic_body.gsub(/\r\n/, "\n") + "\n"
    end

    if dic_data[:ipadic].blank?
      dic_data[:ipadic] = '(品詞 (記号 アルファベット)) ((見出し語 (ZOMEKI 500)) (読み ゾメキ) (発音 ゾメキ))'
    end
    if dic_data[:unidic].blank?
      dic_data[:unidic] = '(POS (記号 文字))' +
        ' ((LEX (ＺＯＭＥＫＩ 500)) (READING ゾメキ) (PRON ゾメキ)' +
        ' (INFO "lForm=\"ゾメキ\" lemma=\"ＺＯＭＥＫＩ\" orthBase=\"ＺＯＭＥＫＩ\"' +
        ' pronBase=\"ゾメキ\" kanaBase=\"ゾメキ\" formBase=\"ゾメキ\"' +
        ' goshu=\"記号\" aType=\"0\" aConType=\"C2\""))'
    end

    require 'shell'
    errors = []
    
    ## ipadic
    dir = "#{Rails.root}/ext/morph/ipadic"
    tmp = Tempfile::new('cmsdic', dir)
    tmp.puts(dic_data[:ipadic])
    tmp.close
    
    sh = Shell.cd(dir)
    logger.info command = "`chasen-config --mkchadic`/makeda -i w #{tmp.path}_dat #{tmp.path}"
    logger.info sh.system(command).to_s
    if success = FileTest.exist?(tmp.path + '_dat.da')
      FileUtils.mv(tmp.path + '_dat.da' , dir + '/cmsdic.da')
      FileUtils.mv(tmp.path + '_dat.dat', dir + '/cmsdic.dat')
      FileUtils.mv(tmp.path + '_dat.lex', dir + '/cmsdic.lex')
      FileUtils.mv(tmp.path, dir + '/cmsdic.dic')
    end
    FileUtils.rm(tmp.path + '_dat.da')  if FileTest.exist?(tmp.path + '_dat.da')
    FileUtils.rm(tmp.path + '_dat.dat') if FileTest.exist?(tmp.path + '_dat.dat')
    FileUtils.rm(tmp.path + '_dat.lex') if FileTest.exist?(tmp.path + '_dat.lex')
    FileUtils.rm(tmp.path + '_dat.tmp') if FileTest.exist?(tmp.path + '_dat.tmp')
    FileUtils.rm(tmp.path) if FileTest.exist?(tmp.path)
    errors << '辞書の作成に失敗しました（ふりがな）' unless success
    
    ## unidic
    dir = "#{Rails.root}/ext/morph/unidic"
    tmp = Tempfile::new('unidic', dir)
    tmp.puts(dic_data[:unidic])
    tmp.close
    
    sh = Shell.cd(dir)
    logger.info command = "`chasen-config --mkchadic`/makeda -i w #{tmp.path}_dat #{tmp.path}"
    logger.info sh.system(command).to_s
    if success = FileTest.exist?(tmp.path + '_dat.da')
      FileUtils.mv(tmp.path + '_dat.da' , dir + '/cmsdic.da')
      FileUtils.mv(tmp.path + '_dat.dat', dir + '/cmsdic.dat')
      FileUtils.mv(tmp.path + '_dat.lex', dir + '/cmsdic.lex')
      FileUtils.mv(tmp.path, dir + '/cmsdic.dic')
    end
    FileUtils.rm(tmp.path + '_dat.da')  if FileTest.exist?(tmp.path + '_dat.da')
    FileUtils.rm(tmp.path + '_dat.dat') if FileTest.exist?(tmp.path + '_dat.dat')
    FileUtils.rm(tmp.path + '_dat.lex') if FileTest.exist?(tmp.path + '_dat.lex')
    FileUtils.rm(tmp.path + '_dat.tmp') if FileTest.exist?(tmp.path + '_dat.tmp')
    FileUtils.rm(tmp.path) if FileTest.exist?(tmp.path)
    errors << '辞書の作成に失敗しました（読み上げ）' unless success
    
    return errors
  end
end
