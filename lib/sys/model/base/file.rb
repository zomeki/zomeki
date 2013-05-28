# encoding: utf-8
module Sys::Model::Base::File
  def self.included(mod)
    mod.validates_presence_of :file, :if => "@_skip_upload != true"
    mod.validates_presence_of :name, :title
    mod.validate :validate_file_name
    mod.validate :validate_file_type
    mod.validate :validate_upload_file
    mod.after_save :upload_internal_file
    mod.after_destroy :remove_internal_file
  end
  
  @@_maxsize = 50# MegaBytes
  
  attr_accessor :file, :allowed_type
  
  def skip_upload(bool = true)
    @_skip_upload = bool
  end
  
  def validate_file_name
    return true if name.blank?

    if self.name !~ /^[0-9a-zA-Z\-\_\.]+$/
      errors.add :name, 'は半角英数字を入力してください。'
    elsif self.name !~ /^[^\.]+?\.[^\.]+$/
      errors.add(:name, 'を正しく入力してください。＜ファイル名.拡張子＞')
    elsif duplicated?
      errors.add :name, 'は既に存在しています。'
      return false
    end
    self.title = self.name if title.blank?
  end
  
  def validate_file_type
    return true if allowed_type.blank?
    
    types = {}
    allowed_type.to_s.split(/ *, */).each do |m|
      m = ".#{m.gsub(/ /, '').downcase}"
      types[m] = true if !m.blank?
    end
    
    if !name.blank?
      ext = ::File.extname(name.to_s).downcase
      if types[ext] != true
        errors.add_to_base "許可されていないファイルです。（#{allowed_type}）"
        return
      end
    end
    
    if !file.blank? && !file.original_filename.blank?
      ext = ::File.extname(file.original_filename.to_s).downcase
      if types[ext] != true
        errors.add_to_base "許可されていないファイルです。（#{allowed_type}）"
        return
      end
    end
  end
  
  def validate_upload_file
    return true if file.blank?
    
    maxsize = @maxsize || @@_maxsize
    if file.size > maxsize.to_i  * (1024**2)
      errors.add :file, "が容量制限を超えています。＜#{maxsize}MB＞"
      return true
    end
    
    self.mime_type    = file.content_type
    self.size         = file.size
    self.image_is     = 2
    self.image_width  = nil
    self.image_height = nil
    
    @_file_data = file.read
    
    if name =~ /\.(bmp|gif|jpg|jpeg|png)$/i
      begin
        require 'RMagick'
        image = Magick::Image.from_blob(@_file_data).shift
        if image.format =~ /(GIF|JPEG|PNG)/
          self.image_is = 1
          self.image_width  = image.columns
          self.image_height = image.rows
        end
      rescue LoadError => e
        warn_log(e.message)
      rescue Magick::ImageMagickError => e
        warn_log(e.message)
      rescue NoMethodError => e
        warn_log(e.message)
      end
    end
  end
  
  def upload_path
    md_dir  = "#{self.class.to_s.underscore.pluralize}"
    id_dir  = format('%08d', id).gsub(/(.*)(..)(..)(..)$/, '\1/\2/\3/\4/\1\2\3\4')
    id_file = format('%07d', id) + '.dat'
    "#{Rails.root}/upload/#{md_dir}/#{id_dir}/#{id_file}"
  end
  
  def readable
    return self
  end

  def editable
    return self
  end

  def deletable
    return self
  end
  
  def readable?
    return true
  end
  
  def creatable?
    return true
  end
  
  def editable?
    return true
  end
  
  def deletable?
    return true
  end
  
  def image_file?
    image_is == 1 ? true : nil 
  end
  
  def escaped_name
    CGI::escape(name)
  end
  
  def united_name
    title + '(' + eng_unit + ')'
  end
  
  def alt
    title.blank? ? name : title
  end
  
  def image_size
    return '' unless image_file?
    "( #{image_width}x#{image_height} )"
  end
  
  def duplicated?
    nil
  end
  
  def css_class
    if ext = File::extname(name).downcase[1..5]
      conv = {
        'xlsx' => 'xls',
      }
      ext = conv[ext] if conv[ext]
      ext = ext.gsub(/[^0-9a-z]/, '')
      return 'iconFile icon' + ext.gsub(/\b\w/) {|word| word.upcase}
    end
    return 'iconFile'
  end
  
  def eng_unit
    _size = size
    return '' unless _size.to_s =~ /^[0-9]+$/
    if _size >= 10**9
      _kilo = 3
      _unit = 'G'
    elsif _size >= 10**6
      _kilo = 2
      _unit = 'M'
    elsif _size >= 10**3
      _kilo = 1
      _unit = 'K'
    else
      _kilo = 0
      _unit = ''
    end
    
    if _kilo > 0
      _size = (_size.to_f / (1024**_kilo)).to_s + '000'
      _keta = _size.index('.')
      if _keta == 3
        _size = _size.slice(0, 3)
      else
        _size = _size.to_f * (10**(3-_keta))
        _size = _size.to_f.ceil.to_f / (10**(3-_keta))
      end
    end
    
    "#{_size}#{_unit}Bytes"
  end
  
  def reduced_size(options = {})
    return nil unless image_file?
    
    src_w  = image_width.to_f
    src_h  = image_height.to_f
    dst_w  = options[:width].to_f
    dst_h  = options[:height].to_f
    src_r    = (src_w / src_h)
    dst_r    = (dst_w / dst_h)
    if dst_r > src_r
      dst_w = (dst_h * src_r);
    else
      dst_h = (dst_w / src_r);
    end
    
    if options[:css]
      return "width: #{dst_w.ceil}px; height:#{dst_h.ceil}px;"
    end
    return {:width => dst_w.ceil, :height => dst_h.ceil}
  end
  
  def mobile_image(mobile, params = {})
    return nil unless mobile
    return nil if image_is != 1
    return nil if image_width <= 300 && image_height <= 400
    
    begin
      require 'RMagick'
      #info = Magick::Image::Info.new
      size = reduced_size(:width => 300, :height => 400)
      img  = Magick::Image.read(params[:path]).first
      img  = img.resize(size[:width], size[:height])
      
      case mobile
      when Jpmobile::Mobile::Docomo
        img.format = 'JPEG' if img.format == 'PNG'
      when Jpmobile::Mobile::Au
        img.format = 'PNG' if img.format == 'JPEG'
        img.format = 'GIF'
      when Jpmobile::Mobile::Softbank
        img.format = 'JPEG' if img.format == 'GIF'
      end
    rescue
      return nil
    end
    return img
  end

  def file_exist?
    return false if new_record?
    File.exist?(upload_path)
  end

private
  ## filter/aftar_save
  def upload_internal_file
    if @_file_data != nil
      Util::File.put(upload_path, :data => @_file_data, :mkdir => true)
    end
    return true
  end
  
  ## filter/aftar_destroy
  def remove_internal_file
    return true unless file_exist?
    FileUtils.remove_entry_secure(upload_path)
    return true
  end
end
