# encoding: utf-8
class Util::AccessibilityChecker

def self.check(text, options={})
     errors ||= []

     errors.push("brタグが連続で存在") if !check_br(text)
     #errors.push("空白のpタグが存在") if !check_p(text)
     errors.push("hタグの順番が不正") if !check_h(text)
     errors.push("テーブルにサマリー、キャプションが正しく入力されていない") if !check_table_sc(text)
     errors.push("テーブルにヘッダーが正しく入力されていない") if !check_table_th(text)
     errors.push("テーブルに空白のセルが存在") if !check_table_cell(text)
     #errors.push("リンクにアイコンクラスが設定されていない") if !check_href_icon(text, options[:host])

     if result = Util::String.search_platform_dependent_characters(text)
       errors.push("機種依存文字が存在:#{result}")
     end

     return errors
end

def self.modify(text, options={})

    _text = modify_platform_dependent_characters(text)

    _text = modify_p(_text)
    _text = modify_br(_text)
    _text = modify_h(_text)
    _text = modify_table_sc(_text)
    _text = modify_table_th(_text)
    _text = modify_table_cell(_text)
    #_text = modify_href_icon(_text, options[:host])

    return _text
end

def self.check_br(text)
    text.scan(/(?:<br\s*\/?>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;)*){2,}/) == []
end

def self.check_p(text)
    text.scan(/<p[^>]*?>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;)*<\/p\s*>/) == []
end

  def self.parse_h(text)
    doc = Nokogiri::HTML.fragment(text)
    nodes = doc.xpath((1..6).map{|i| "h#{i} | .//h#{i}"}.join(' | ')).to_a

    (1..6).each do |no|
      (0..nodes.size-1).each do |i|
        node1 = nodes[i]
        node2 = nodes[i+1]
        if node1.name == "h#{no}" || node1['acc-modify-name'] == "h#{no}"
          node1['acc-state'] ||= 'OK'
          if node2 && !node2['acc-state'] && !node2.name.in?(%W(h#{no} h#{no+1}))
            node2['acc-state'] = 'NG'
            node2['acc-error-h'] = '1'
            node2['acc-modify-name'] = "h#{no+1}"
          end
        end
      end
    end

    nodes.each do |node|
      node.remove_attribute('acc-state')
    end

    doc
  end

  def self.check_h(text)
    doc = parse_h(text)
    doc.css('[@acc-error-h]').blank?
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
  doc = Hpricot(text)

  chk = Proc.new do |elm|
    check = (elm.inner_text.gsub(/(\302\240|\s|　)/, "") != "")
    if !check
      elm.search("img").each do |img|
        check = img.attributes['alt'].to_s != "" && img.attributes['title'].to_s != ""
      end
    end
  end

  doc.search("table").each do |table|

    table.search("th").each do |th|
      chk.call(th)
      break if !check
    end

    break if !check

    table.search("td").each do |td|
      chk.call(td)
      break if !check
    end

    break if !check
  end

  check
end

=begin
def self.check_table_cell(text)
  check = true
  text.scan(/<table(.*?)>(.*?)<\/table\s*>/m){
    table_2 = $2

    table_2.scan(/<thead>(.*?)<\/thead>/m){
      thead = $1
      thead.scan(/<th.*?>.*?<\/th.*?>/m){ |td|
        if td =~ /<th.*?>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;|<p>|<\/p>)*?<\/th.*?>/m
          check = false
        end
      }
    }

    return check if !check

    table_2.scan(/<td.*?>.*?<\/td.*?>/m){ |td|
      if td =~ /<td.*?>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;)*<\/td.*?>/m
                 raise td
        check = false
      end
    }
    return check if !check

  }
  check
end
=end

def self.check_table_th(text)
  doc = Hpricot(text)

  check = true

  doc.search("table").each do |table|
     check = (table.search("thead").to_s != "")
     check = (table.search("th").to_s != "")

     break if !check
  end

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
    doc = parse_h(text)
    doc.css("[@acc-error-h]").each do |node|
      node.remove_attribute('acc-error-h')
      if node['acc-modify-name']
        node.name = node['acc-modify-name']
        node.remove_attribute('acc-modify-name')
      end
    end
    doc.to_s
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
doc = Hpricot(text)

  check = true
  chk = Proc.new do |elm|
    check = (elm.inner_text.gsub(/(\302\240|\s|　)/, "") != "")
    if !check
      elm.search("img").each do |img|
        check = img.attributes['alt'].to_s != "" && img.attributes['title'].to_s != ""
      end
    end
  end

  doc.search("table").each do |table|

    table.search("th").each do |th|
      chk.call(th)
      th.inner_html = "セル" unless check
    end

    table.search("td").each do |td|
      chk.call(td)
      td.inner_html = "セル" unless check
    end
  end

  doc.to_s
end

=begin
def self.modify_table_cell(text)
    text_ = text.gsub(/<table(.*?)>(.*?)<\/table\s*>/m){
    table_1 = $1
    table_2 = $2
    table_2.gsub!(/<td(.*?)>.*?<\/td>/m){ |td|
      td_1 = $1

      if td =~ /<td.*?>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;|<p>|<\/p>)*<\/td.*?>/m
        "<td#{td_1}>セル</td>"
      else
        td
      end
    }

    "<table#{table_1}>\n#{table_2}\n</table>"
    }

    text_ = text_.gsub(/<thead>(.*?)<\/thead>/m){
    thead = $1
    thead.gsub!(/<th(.*?)>(.*?)<\/th>/m){|th|
      th_1 = $1
      th_2 = $2

      if th =~ /<th.*?>(?:\s|　|&nbsp;|&ensp;|&emsp;|&thinsp;|<p>|<\/p>)*<\/th\s*>/m
        "<th #{th_1}>セル</th>"
      else
        th
      end
    }

    "<thead>#{thead}</thead>"
  }
end
=end

def self.modify_table_th(text)

  return text if check_table_th(text)

  text.gsub(/<table(.*?)>(.*?)<\/table\s*>/m){
    table_1 = $1
    table_2 = $2

    td_count = 0
    tr = table_2.scan(/<tr>.*?<\/tr>/m).shift
    td_count = tr ? tr.scan("<td>").size : 0
    #TODO
    table_2.sub!(/<tbody>.*?<\/tbody>/m){ |tbody|
      tbody = "<thead>\n<tr>\n" + ("<th scope=\"col\">&nbsp;</th>\n" * td_count) + "</tr>\n</thead>\n" +  tbody
    }

    #raise "<table#{table_1}>#{table_2}</table>"

    "<table#{table_1}>#{table_2}</table>"

  }
end

=begin
def self.modify_table_th(text)

  return text if check_table_th(text)

  text.gsub(/<table(.*?)>(.*?)<\/table\s*>/m){
    table_1 = $1
    table_2 = $2

    td_count = 0
    tr = table_2.scan(/<tr>.*?<\/tr>/m).shift
    td_count = tr ? tr.scan("<td>").size : 0
    #TODO
    table_2.sub!(/<tbody>.*?<\/tbody>/m){ |tbody|
      tbody = "<thead>\n<tr>\n" + ("<th scope=\"col\">&nbsp;</th>\n" * td_count) + "</tr>\n</thead>\n" +  tbody
    }

    #raise "<table#{table_1}>#{table_2}</table>"

    "<table#{table_1}>#{table_2}</table>"

  }
end
=end

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

def self.modify_platform_dependent_characters(text)

    if result = Util::String.search_platform_dependent_characters(text)
      text.gsub(/[#{result}]/, "【機種依存文字】")
    else
      text
    end
end
end
