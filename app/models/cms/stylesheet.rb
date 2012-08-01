# encoding: utf-8
require 'mime/types'
class Cms::Stylesheet < Sys::Model::ValidationModel::Base
  attr_reader   :full_path, :path
  attr_accessor :name, :body
  attr_accessor :new_directory, :new_file, :new_upload
  
  validates_presence_of :name
  validates_format_of :name, :with=> /^[0-9A-Za-z@\.\-\_]+$/, :message=> :not_a_filename
  
  def initialize(full_path, params = {})
    @full_path  = full_path
    @root       = params[:root]
    @path       = @full_path
    @path       = @path.gsub(@root + '/', '') if @root
    @base_uri   = params[:base_uri] || ""
    @new_record = params[:new_record] ? true : false
    self.name   = ::File.basename(@path)
  end
  
  def self.find(full_path, params = {})
    params[:new_record] = false
    self.new(full_path, params)
  end
  
  def child_directories
    items = []
    Dir::entries(@full_path).sort.each do |name|
      next if name =~ /^\.+/
      path = ::File.join(@full_path, name)
      next if ::FileTest.file?(path)
      items << self.class.find(path, :root => @root, :base_uri => @base_uri)
    end
    items
  end
  
  def child_files
    items = []
    Dir::entries(@full_path).sort.each do |name|
      next if name =~ /^\.+/
      path = ::File.join(@full_path, name)
      next if ::FileTest.directory?(path)
      items << self.class.find(path, :root => @root, :base_uri => @base_uri)
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
    mime_type.blank? || mime_type =~ /^text/i
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
    self.body = NKF.nkf('-w', ::File.new(@full_path).read.to_s) if textfile?
  rescue Exception
    self.body = "#読み込みに失敗しました。"
  end
  
  ## Validation
  def valid_filename?(name, value)
    if value.blank?
      errors.add name, :empty
    elsif value !~ /^[0-9A-Za-z@\.\-\_]+$/
      errors.add name, :not_a_filename
    elsif value =~ /^[\.]+$/
      errors.add name, :not_a_filename
    end
    return errors.size == 0
  end
  
  def valid_path?(name, value)
    if value.blank?
      errors.add name, :empty
    elsif value !~ /^[0-9A-Za-z@\.\-\_\/]+$/
      errors.add name, :not_a_filename
    elsif value =~ /(^|\/)\.+(\/|$)/
      errors.add name, :not_a_filename
    end
    return errors.size == 0
  end
  
  def valid_exist?(path, type = nil)
    return true unless ::File.exist?(path)
    if type == nil
      errors.add_to_base "ファイルが既に存在します。"
    elsif type == :file
      errors.add_to_base "ファイルが既に存在します。" if ::File.file?(path)
    elsif type == :directory
      errors.add_to_base "ディレクトリが既に存在します。" if ::File.file?(path)
    end
    return errors.size == 0
  end
  
  ## Atcion methods
  
  def save
    File.open(@full_path,'w') {|f| f.write(self.body) }
    return true
  rescue => e
    errors.add_to_base(e.to_s)
    return false
  end
  
  def create_directory(name)
    @new_directory = name.to_s
    return false unless valid_filename?(:new_directory, @new_directory)
    
    src = ::File::join(@full_path, @new_directory)
    return false unless valid_exist?(src)
    
    FileUtils.mkdir(src)
  rescue => e
    errors.add_to_base(e.to_s)
    return false
  end
  
  def create_file(name)
    @new_file = name.to_s
    return false unless valid_filename?(:new_file, @new_file)
    
    src = ::File::join(@full_path, @new_file)
    return false unless valid_exist?(src)
    
    FileUtils.touch(src)
  rescue => e
    errors.add_to_base(e.to_s)
    return false
  end
  
  def upload_file(file)
    unless file
      errors.add :new_upload, :empty
      return false
    end
    
    src = ::File::join(@full_path, file.original_filename)
    if ::File.exist?(src) && FileTest.directory?(src)
      errors.add_to_base "同名のディレクトリが既に存在します。"
      return false
    end
    
    File.open(src,'w') {|f| f.write(file.read.force_encoding('utf-8')) }
    return true
  rescue => e
    errors.add_to_base(e.to_s)
    return false
  end
  
  def rename(name)
    @name = name.to_s
    return false unless valid_filename?(:name, @name)
    
    src = @full_path
    dst = ::File::join(::File.dirname(@full_path), @name)
    return true if src == dst
    
    FileUtils.mv(src, dst)
    return true
  rescue => e
    errors.add_to_base(e.to_s)
    return false
  end
  
  def move(new_path)
    @path = new_path.to_s.gsub(/\/+/, '/')
    
    return false unless valid_path?(:path, @path)
    
    src = @full_path
    dst = ::File::join(@root, @path)
    return true if src == dst
    
    if !::File.exist?(::File.dirname(dst))
      dir = ::File.dirname(dst.gsub(@base_uri[0], @base_uri[1]))
      errors.add_to_base "ディレクトリが見つかりません。（ #{dir} ）"
    elsif file? && !::File.exist?(::File.dirname(dst))
      dir = ::File.dirname(dst.gsub(@base_uri[0], @base_uri[1]))
      errors.add_to_base "ディレクトリが見つかりません。（ #{dir} ）"
    end
    return false if errors.size != 0
    return false unless valid_exist?(dst, :file)
    
    FileUtils.mv(src, dst)
    return true
  rescue => e
    if e.to_s =~ /^same file/i
      return true
    elsif e.to_s =~ /^Not a directory/i
      errors.add_to_base "ディレクトリが見つかりません。（ #{dst} ）"
    else
      errors.add_to_base(e.to_s)
    end
    return false
  end
  
  def destroy
    src = @full_path
    FileUtils.rm_rf(src)
    return true
  rescue => e
    errors.add_to_base(e.to_s)
    return false
  end
end