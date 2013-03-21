# encoding: utf-8
require 'nkf'
class Cms::Lib::Navi::Ruby
  def self.convert(str)
    ENV['PATH'] = ENV['PATH'].split(':').concat(%w!/usr/local/sbin /usr/local/bin!).uniq.join(':')

    return str if str.to_s == ''
    
    chasenrc = './config/chasenrc_ruby'
    format   = '%ps %pe %m %y\n'
    chars    = []
    
    str.gsub!(/(.{2000}.*?。)/u, '\1' + "\n") # over than 5,800bytes?
    cstr = str.gsub(/ |\t/, '_')
    
    if 0 && str =~ /\r\n|\r|\n/
      tmp = Tempfile::new("ruby_text", '/tmp')
      tmp.puts cstr#.gsub(/ |\t/, '_')
      tmp.close
      command  = "cat #{tmp.path} | chasen -i w -r #{chasenrc} -F '#{format}'"
    else
      command  = "echo \"" + cstr.gsub('"', '\\"') + "\" | chasen -i w -r #{chasenrc} -F '#{format}'"
    end
    
    require 'shell'
    sh = Shell.cd("#{Rails.root}/ext")
    
    res = nil
    sh.transact { res = system("#{command}").to_s }
    res = NKF.nkf('-w', res.to_s)
    res.split(/^EOS/).each_with_index do |res, line|
      res.strip.split(/\n/).each do |p|
        chars << {:line => line, :data => p.split(/ /)}
      end
    end
    
    ## next char
    next_char = Proc.new do |i|
      chars[i].blank? ? nil : chars[i][:data][2]
    end
    
    ## forward char
    forward_char = lambda do |_char, i|
      while _c = next_char.call(i)
        return i if _c == _char
        i += 1
      end
    end
    
    kana_arr = {}
    i = 0
    while i < chars.size
      break unless c = next_char.call(i)
      if c == '<' # tag
        break unless c = next_char.call(i+=1)
        if c == 'style'
          i = forward_char.call('>', i)
          while i = forward_char.call('<', i) do
            break if i > chars.size
            break if next_char.call(i+=1) == '/' && next_char.call(i+=1) == 'style'
          end
        elsif c == 'script'
          i = forward_char.call('>', i)
          while i = forward_char.call('<', i) do
            break if i > chars.size
            break if next_char.call(i+=1) == '/' && next_char.call(i+=1) == 'script'
          end
#        elsif c == '!'
#          while i = forward_char.call('-', i) do
#            break if i > chars.size
#            break if next_char.call(i+=1) == '-' && next_char.call(i+=1) == '>'
#          end
        elsif c == '<'
          # <<
        else
          i = forward_char.call('>', i)
        end
      else
        if chars[i][:data][3].to_s.strip != '' && chars[i][:data][4] != '81' && c =~ /[一-龠]/
          kana_arr[chars[i][:line]] ||= []
          kana_arr[chars[i][:line]] << chars[i]
        end
      end
      break if i.nil?
      i += 1
    end
    
    str_arr = str.split(/\r\n|\r|\n/)
    kana_arr.each do |tmp|
      line = tmp[0]
      pos  = 0
      kana_str = ''
      tmp[1].each do |kana|
        spos = kana[:data][0].to_i
        epos = kana[:data][1].to_i
        
        if str_arr[line] && str = slice(str_arr[line], pos, spos - pos)
          kana_str += str
          kana_str += "<ruby><rb>#{kana[:data][2]}</rb><rp>" +
            "(</rp><rt>#{kana[:data][3].tr('ァ-ン', 'ぁ-ん')}</rt><rp>)</rp></ruby>"
        end
        pos = epos
      end
      if str_arr[line] && str = slice(str_arr[line], pos, str_arr[line].bytesize - pos)
        kana_str += str
      end
      str_arr[line] = kana_str
    end
    
    return str_arr.join("\n")
  end
  
  def self.slice(str, start, length)
    "#{str}".force_encoding('ascii').slice(start, length).to_s.force_encoding('utf-8')
  end
end
