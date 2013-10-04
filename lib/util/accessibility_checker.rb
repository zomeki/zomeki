# encoding: utf-8
class Util::AccessibilityChecker
  
  
   def self.check(text, options={})
     errors ||= []
     
     errors.push("brタグが連続で存在") if !check_br(text)
     errors.push("空白のpタグが存在") if !check_p(text)
     errors.push("hタグの順番が不正") if !check_h(text)
     errors.push("テーブルにサマリー、キャプションが正しく入力されていない") if !check_table_sc(text)
     #errors.push("テーブルにヘッダーが正しく入力されていない") if !check_table_th(text)
     errors.push("テーブルに空白のセルが存在") if !check_table_cell(text)
     errors.push("リンクにアイコンクラスが設定されていない") if !check_href_icon(text, options[:host])
     
     return errors
    end

  def self.modify(text, options={})
    _text = modify_p(text)
    _text = modify_br(_text)
    _text = modify_h(_text)
    _text = modify_table_sc(_text)
    #_text = modify_table_th(_text)
    _text = modify_table_cell(_text)
    _text = modify_href_icon(_text, options[:host])
    return _text
  end
  
  def self.check_br(text)
    text.scan(/(?:<br\s*\/?>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;)*){2,}/) == []
  end
  
  def self.check_p(text)
    text.scan(/<p[^>]*?>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;)*<\/p\s*>/) == []
  end
  
  def self.check_h(text)
    h_num = 1
    check = true
    text.scan(/<h(\d)\s*>/){ |h|
    num = $1.to_i

    if num == 1 || num == 2 || h_num == num || (h_num + 1) == num
      h_num = num
    else
      check = false
      break
    end
    }
  return check
  end

  def self.check_table_sc(text)
  check = true
  text.scan(/<table(.*?)>(.*?)<\/table\s*>/m){
    table_1 = $1
    table_2 = $2
    summary = nil
    caption = nil
    
    table_1.scan(/summary=\"(.*?)\"/m){
      summary = $1
    }
    
    table_2.scan(/<caption\s*>(.*?)<\/caption\s*>/m){
      caption = $1
    }
    
    if !summary || summary == "" || summary == "&nbsp;" 
       check = false
       break
    elsif !caption || caption == "" || caption == "&nbsp;" 
       check = false
       break
    end  
  }
  check
end

def self.check_table_cell(text)
  check = true
  text.scan(/<table(.*?)>(.*?)<\/table\s*>/m){
    table_2 = $2
    table_2.scan(/<th.*?>.*?<\/th.*?>/m){ |td|
      break if !check
      
      if td =~ /<th.*?>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;|<p>&nbsp;<\/p>)*?<\/th.*?>/m
        check = false
      end
    }
    
    table_2.scan(/<td\s*>.*?<\/td\s*>/m){ |td|
      break if !check
      
      if td =~ /<td\s*>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;|<p>&nbsp;<\/p>)*?<\/td\s*>/m
        check = false
      end
    }
  }
  
  check
end  
  
  
=begin
  def self.check_table_cell(text)
  check = true
  text.scan(/<table(.*?)>(.*?)<\/table\s*>/m){
    table_2 = $2
    table_2.scan(/<td\s*>.*?<\/td\s*>/m){ |td|
      break if !check
      
      if td =~ /<td\s*>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;|<p>&nbsp;<\/p>)*?<\/td\s*>/m
        check = false
      end
    }
  }
  check
end
=end

def self.check_table_th(text)
  check = true  
  text.scan(/<table(.*?)>(.*?)<\/table\s*>/m){
    table_2 = $2
    
    if table_2 =~ /<thead\s*>.*?<\/thead\s*>/m
      check = true
      break
    elsif !(table_2 =~ /<th\s*>.*?<\/th\s*>/m)
      check = false
      break
    elsif table_2 =~ /<th\s*>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;|<p>&nbsp;<\/p>)*?<\/th\s*>/m
      check = false
      break
    end
  }
  check
end

def self.check_href_icon(text, host)
  check = true
  text.scan(/<a(.*?)>/){
    a = $1
    link = a.scan(/href=\"(.*?)\"/).shift
    
    if link
      
      begin
        uri = URI(link.shift)
      rescue
        next
      end
        
      if uri.path && (!uri.scheme || uri.host == host)
        ext = File.extname(uri.path).downcase
        case ext
        when ".bmp", ".gif", ".csv", ".doc", ".jpg", ".xls", ".pdf", ".png", ".ppt", ".txt", ".zip", ".lzh"
          if !(a=~ /class=\"iconFile icon.*?\"/)
            check = false
          end
        end
        
        break if !check
      end
    end
   
  }
  check
end

  def self.modify_br(text)
    text.gsub(/(?:<br\s*\/?>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;)*){2,}/, "<br />\n")
  end
  
  def self.modify_p(text)
    text.gsub(/<p[^>]*?>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;)*<\/p\s*>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;)*/, "")
  end
  
  def self.modify_h(text)
    h_num = 1
    return text.gsub(/<h(\d)\s*>(.*?)<\/h(\d)\s*>/m){ |h|
    num = $1.to_i
  
    if num == 1 || num == 2 || h_num == num || (h_num + 1) == num
      h_num = num
      h
    else
      h_num += 1 if h_num == 1
      "<h#{h_num}>#{$2}</h#{h_num}>"
    end
    }
  end

def self.modify_table_sc(text)
  return text.gsub(/<table(.*?)>(.*?)<\/table\s*>/m){
    table_1 = $1
    table_2 = $2
    
    if !(table_1 =~ /summary=\".*?\"/m)
      table_1 = table_1 + " summary=\"サマリー\""
    else
      table_1.gsub!(/summary=\"(.*?)\"/m){ |s|
        if $1 == "" || $1 == "&nbsp;"
          "summary=\"サマリー\""
        else
          s
        end
      }
    end
    
    if !(table_2 =~ /<caption\s*>.*?<\/caption\s*>/m)
      table_2 = "<caption>キャプション</caption>" + table_2
    else
      table_2.gsub!(/<caption\s*>(.*?)<\/caption\s*>/m){ |c|
        if $1 == "" || $1 == "&nbsp;"
          "<caption>キャプション</caption>"
        else
          c
        end
      }
    end
    "<table #{table_1}>#{table_2}</table>"
  }
end

def self.modify_table_cell(text)
  text.gsub(/<table(.*?)>(.*?)<\/table\s*>/m){
    table_1 = $1
    table_2 = $2
    table_2.gsub!(/<td\s*>.*?<\/td\s*>/m){ |td|
      if td =~ /<td\s*>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;|<p>&nbsp;<\/p>)*<\/td\s*>/m
        "<td>セル</td>"
      else
        td
      end
    }
    
    table_2.gsub!(/<th(.*?)>(.*?)<\/th\s*>/m){ |th|
      th_1 = $1
      
      if th =~ /<th.*?>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;|<p>&nbsp;<\/p>)*<\/th\s*>/m
        "<th #{th_1}>セル</th>"
      else
        th
      end
    }
    
    
    "<table#{table_1}>\n#{table_2}\n</table>"
  }
end

def self.modify_table_th(text)
  text.gsub(/<table(.*?)>(.*?)<\/table\s*>/m){ |table|
    table_1 = $1
    table_2 = $2
    if !(table_2 =~ /<thead\s*>.*?<\/thead\s*>/m)
      table_2 = "<thead><tr><th>ヘッダー</th></tr></thead>" + table_2
      "<table#{table_1}>#{table_2}</table>"
    else
      table
    end
  }
end

def self.modify_href_icon(text, host)
 text.gsub(/<a(.*?)>/){
    a = $1
    link = a.scan(/href=\"(.*?)\"/).shift
    
    if link
      uri = URI(link.shift) 
      
      if !uri.scheme || uri.host == host
        
        
        ext = File.extname(uri.path).downcase
        case ext
        when ".bmp", ".gif", ".csv", ".doc", ".jpg", ".xls", ".pdf", ".png", ".ppt", ".txt", ".zip", ".lzh"
         if !(a=~ /class=\"iconFile icon.*?\"/)
           a = a + " class=\"iconFile icon#{ext.gsub(/\./, "").capitalize}\""
         end
        end
      end
    end
    "<a#{a}>"
  }
end
  
  
end