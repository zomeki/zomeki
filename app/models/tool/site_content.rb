# encoding: utf-8
require 'mime/types'
class Tool::SiteContent < Sys::Model::ValidationModel::Base
  attr_reader   :site_url, :full_path, :path
  attr_accessor :name, :body
  
  def initialize(site_url, full_path, params = {})
    @site_url  = site_url
    @full_path  = full_path
    @root       = params[:root]
    @path       = @full_path
    @path       = @path.gsub(@root + '/', '') if @root
    @base_uri   = params[:base_uri] || ""
    self.name   = ::File.basename(@path)
  end
  
  def child_directories
    return [] if @site_url.blank?
    items = []
    Dir::entries(@full_path).sort.each do |name|
      next if name =~ /^\.+/
      path = ::File.join(@full_path, name)
      next if ::FileTest.file?(path)
      items << self.class.new(@site_url, path, :root => @root, :base_uri => @base_uri)
    end
    items
  end
  
  def child_files
    return [] if @site_url.blank?
    items = []
    Dir::entries(@full_path).sort.each do |name|
      next if name =~ /^\.+/
      path = ::File.join(@full_path, name)
      next if ::FileTest.directory?(path)
      items << self.class.new(@site_url, path, :root => @root, :base_uri => @base_uri)
    end
    items
  end
  
  ## Attributes
  
  def directory?
    ::FileTest.directory?(@full_path)
  end
  
  def file?
    ::FileTest.file?(@full_path)
  end
  
  def textfile?
    return false unless file?
    mime_type.blank? || mime_type =~ /(text|javascript)/i
  end
  
  def escaped_path
    URI.escape(path)
  end
  
  def uri
    @full_path.gsub(@base_uri[0], @base_uri[1])
  end
  
  def mime_type
    unless @_mime_type
      @_mime_type = MIME::Types.type_for(@full_path)[0].to_s
    end
    @_mime_type
  end
  
  def type
    return 'text' if mime_type == "text/plain"
    mime_type.gsub(/.*\//, '')
  end
  
  def read_stat
    unless @_stat
      @_stat = ::File.stat(@full_path)
    end
    @_stat
  end
  
  def size(unit = nil)
    read_stat
    if unit == :kb
      (@_stat.size.to_f/1024).ceil
    else
      @_stat.size
    end
  end
  
  def updated_at
    read_stat
    @_stat.mtime
  end
  
  def read_body
    self.body = File.read(@full_path).encode(Encoding::UTF_8) if textfile?
  rescue Exception => e
    warn_log(e.message)
    self.body = "#読み込みに失敗しました。"
  end
  
end
