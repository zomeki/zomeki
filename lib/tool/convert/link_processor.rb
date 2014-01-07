# encoding: utf-8

require 'nokogiri.rb'
require 'uri'
require 'pathname'

class Tool::Convert::LinkProcessor

  def self.upload_file(doc, pfile, file_path)
    file = Sys::File.new
    
    if !File.exist?(file_path)
      puts "upload_file:ファイルが開けない:#{pfile[:file_path]}\t#{file_path}"
      return nil
    end
    
    file.file = Sys::Lib::File::NoUploadedFile.new(file_path, :mime_type => "application/#{File.extname(pfile[:name]).delete(".")}")

    file.parent_unid = doc.unid
    file.name = pfile[:name]
    file.title = pfile[:name]
    file.in_creator = doc.in_creator
    
    if !file.save
      puts "upload_file:アップロード失敗:#{pfile[:file_path]}\t#{file_path}"
      p file.errors.full_messages
      return nil
    else
      return file
    end
  end

  def self.sublink(text, cdoc, doc_node_public_uri)
    links = {}
    links[:html] = []
    links[:error] = []
    links[:upload] = []
    links[:body] = text.dup

    uri_path = cdoc.uri_path
    
  #  begin
    html_body = Nokogiri::HTML(text)
    html_body.xpath("//a[@href]|//img[@src]").each do |e|
      
      if e.name == "a"
        link = e["href"]
        tag = "a"
        attr = "href"
      else
        link = e["src"]
        tag = "img"
        attr = "src"
      end  
      
      link_uri = URI(link)
     
      if link_uri.scheme
         #他ホスト
         if link_uri.host && !Tool::ConvertDoc.find(:first, :conditions => {:host => link_uri.host})
            links[:error].push({:uri_path => uri_path, :link => link, :e_msg => "他ホストへのリンク"})
            next
         #スキーマ不明
         elsif link_uri.scheme != 'http' && link_uri.scheme != 'https'
            links[:error].push({:uri_path => uri_path, :link => link, :e_msg => "スキーマ不明"})
            next
         end

         link_uri_path = link_uri.host + link_uri.path
      else
        if link.present? && link[0] == "/"
          link_uri_path = cdoc.host + link
        else
          link_uri_path = (Pathname(File.dirname(uri_path)) + link).to_s     
        end
      end

      #拡張子判定
      if link_uri_path[-1] == "/"
        link_uri_path += "index.html"
      end
      
      if link_uri_path.index("html#")
        link_uri_path.gsub!(/#.*$/, "")
      end
        
      case ext = File.extname(link_uri_path).downcase
      when '.html' then #----------------------------------------------------------------html----------------------------------------------------

        link_cdoc = Tool::ConvertDoc.find(:first, :conditions => {:uri_path => link_uri_path})

        if link_cdoc
           links[:body].gsub!(link, "#{doc_node_public_uri}#{link_cdoc.name}/")
           links[:html].push({:uri_path => uri_path, :link => link, :conv_link => "#{doc_node_public_uri}#{link_cdoc.name}/"})
        else
           puts "error sublink: 移行後の記事がデータベース内に見つからない #{link}"
           links[:error].push({:uri_path => uri_path, :link => link, :e_msg => "移行後の記事がConvertDoc内に見つからない"})
           next
        end

      when '.pdf', '.xls', '.doc' then  #---------------------------------------------------------------'.pdf', '.xls', '.doc'----------------------------------------------------
        
        upload_filename = link_uri_path.sub(/^\//, "").gsub(/\/|\.|\(|\)/, "_")
        upload_filename[upload_filename.rindex("_")] = "."
        upload_filename = cdoc.name + "_" + upload_filename
        
        replace = e.to_s.scan(/<.*?>/).shift
        links[:body].gsub!(replace, "<a class=\"iconFile icon#{ext.sub(".", "").capitalize}\" href=\"./file_contents/#{upload_filename}\">")

        if links[:upload].map{|link| link[:name]}.index(upload_filename)
          #同記事にすでにアップロードリンクが存在
          next
        end
      
        links[:upload].push({:uri_path => uri_path, :link_uri_path => link_uri_path, :link => link, :name => upload_filename,  :conv_link => "./file_contents/#{upload_filename}"})


      when '.jpg', '.jpeg', '.gif'  then #---------------------------------------------------------------'.jpg','.jpeg','.gif'----------------------------------------------------

        upload_filename = link_uri_path.sub(/^\//, "").gsub(/\/|\.|\(|\)/, "_")
        upload_filename[upload_filename.rindex("_")] = "."
        upload_filename = cdoc.name + "_" + upload_filename
        
        replace = e.to_s.scan(/<.*?>/).shift
        links[:body].gsub!(replace, "<#{tag} #{attr}=\"./file_contents/#{upload_filename}\">")


        if links[:upload].map{|link| link[:name]}.index(upload_filename)
          #同記事にすでにアップロードリンクが存在
          next
        end

        links[:upload].push({:uri_path => uri_path, :link_uri_path => link_uri_path, :link => link, :name => upload_filename,  :conv_link => "./file_contents/#{upload_filename}"})


      else
        #puts "error linksub: 不明な拡張子 #{link}"
        links[:error].push({:uri_path => uri_path, :link_uri_path => link_uri_path, :link => link, :e_msg => "不明な拡張子"})
      end

      end

   links
  end

end
