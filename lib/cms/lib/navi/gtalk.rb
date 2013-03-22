# encoding: utf-8
require 'nkf'
class Cms::Lib::Navi::Gtalk
  def self.make_text(content)
    text = self.html_to_string(NKF.nkf('-w', content.to_s))
    return self.to_gtalk_string(text)
  end
  
  def make(*args)
    ENV['PATH'] = ENV['PATH'].split(':').concat(%w!/usr/local/sbin /usr/local/bin!).uniq.join(':')

    text    = nil
    options = {}
    
    if args[0].class == String
      text    = args[0]
      options = args[1] || {}
    elsif args[0].class == Hash
      options = args[0]
    end
    
    if options[:uri]
      options[:uri].sub!(/\/index\.html$/, '/')
      res = Util::Http::Request.send(options[:uri])
      text = res.status == 200 ? res.body : nil
    end
    return false unless text
    
    text = self.class.make_text(text)
    text = text[0, 500]
    
    cnf = Tempfile::new("gtalk_cnf", '/tmp')
    wav = Tempfile::new("gtalk_wav", '/tmp')
    mp3 = Tempfile::new("gtalk_mp3", '/tmp')
    
    speaker = options[:speaker] || 'female01'
    cnf.puts("set Log = No\n")
    #cnf.puts("set Err = No\n")
    cnf.puts("set Speaker = #{speaker}\n")
    cnf.puts("set Text = #{text}\n")
    cnf.puts("set SaveWAV = #{wav.path}\n")
    cnf.puts("set Run = EXIT\n")
    cnf.close
    
    require 'shell'
    dir = "#{Rails.root}/ext/gtalk"
    sh  = Shell.cd(dir)
    sh.transact { system("#{dir}/gtalk -C #{dir}/ssm.conf < #{cnf.path} >/dev/null 2>&1").to_s }
    
    if FileTest.exists?(wav.path)
      sh.transact { system("lame --scale 5 #{wav.path} #{mp3.path} >/dev/null 2>&1").to_s }
    end
    
    [cnf.path, wav.path, "#{wav.path}.info"].each do |file|
      FileUtils.rm(file) if FileTest.exists?(file)
    end
    
    @mp3 = nil
    if FileTest.exists?(mp3.path)
      @mp3 = mp3
    end
  end
  
  def output
    if @mp3 && FileTest.exists?(@mp3.path)
      return {:path => @mp3.path, :mime_type => 'audio/mp3'}
    end
    return nil
  end
  
private
  def self.html_to_string(text)
    if text =~ /<div id="content">/
      text.gsub!(/.*?<div id="content">(.*)<!-- end #content --><\/div>.*/im, '\1')
    elsif text =~ /<body.*?>/
      text.sub!(/.*<body.*?>(.*)<\/body.*/im, '\1')
    end
    
    ## remove specific tags
    ['script', 'style', 'rp', 'rt'].each do |element|
      text.gsub!(/<#{element}.*?>.*?<\/#{element}>/im, '')
    end
    
    ## modify img tags
    text.gsub!(/<img .*?>/i) do |m|
      alt = nil
      if m =~ / title=".*"/
        alt = m.sub(/.* title="(.*?)".*/i, '\1')
      elsif m =~ / alt=".*"/
        alt = m.sub(/.* alt="(.*?)".*/i, '\1')
      end
      alt ? "イメージ、#{alt}、" : ''
      alt
    end
    
    ## strip tags ( excluding the comment tag )
    text.gsub!(/<[^!][^<>]*>/, '、')
    text.gsub!(/(、|\r\n|\n)+/, '、')
    
    ## skip reading
    i     = 0
    tmp   = ''
    skip  = 0
    chars = text.split(//u)
    while i < chars.size do
      c = chars[i]
      if c == '<'
        tag = chars.slice(i, 22).join
        if tag.index('<!-- skip reading -->') == 0
          i += 21
          skip += 1
          next
        elsif tag == '<!-- /skip reading -->'
          i += 22
          skip -= 1
          skip = 0 if skip < 0
          next
        end
      end
      tmp += c if skip < 1
      i += 1
    end
    text = tmp
    
    ## strip tags
    text.gsub!(/<[^<>]*>/, '、')
    
    ## oversize
    text.gsub!(/[^、]{60}/u) {|m| "#{m}、"}
    
    return text
  end
  
  def self.to_gtalk_string(text)
    require 'cgi'
    text = CGI.unescapeHTML(text)
    
    text.gsub!(/([0-9]日)(\(|（)(月|火|水|木|金|土|日)(\)|）)/, '\1、\3曜日、')
    text.gsub!(/(\r\n|\n|\r|\t| )+/m, '、')
    text.gsub!(/&[0-9a-zA-Z]+;/im, '')
    text.tr!("0-9a-zA-Z", "０-９ａ-ｚＡ-Ｚ")
    text.tr!("a-zA-Z", "ａ-ｚＡ-Ｚ")
    text.gsub!(/[!"\#\$%&'\(\)=~\|\{\`\+\*\}_\?\>\<\/\]:;\[\^,\\]/, '、')
    text.gsub!(/／|：|～|｜|・|，|　/, "、")
    text.tr!("-", "－")
    text.gsub!(/[.．]/, "、ドット、")
    text.gsub!(/[@＠]/, "、アットマーク、")
    text.gsub!(/。、+/, "。")
    text.gsub!(/、。+/, "。")
    text.gsub!(/、+/, "、")
    text.gsub!(/^(、|。)+/, "")
    text.gsub!(/(、|。)+$/, "")
    return text
  end
end
