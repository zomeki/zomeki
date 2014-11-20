require 'RMagick'

module Sys::Model::Base::File
  IMAGE_RESIZE_OPTIONS = [['320px', '320'], ['640px', '640'], ['800px', '800'],
                          ['1280px', '1280'], ['1600px', '1600'], ['1920px', '1920']]

  def self.included(mod)
    mod.validates_presence_of :file, :unless => :skip_upload?
    mod.validates_presence_of :name, :title
    mod.validate :validate_file_name
    mod.validate :validate_file_type
    mod.validate :validate_upload_file
    mod.after_save :upload_internal_file
    mod.after_destroy :remove_internal_file
  end

  @@_maxsize = 50 # MegaBytes

  attr_accessor :file, :allowed_type, :image_resize

  def skip_upload(skip=true)
    @skip_upload = skip
  end

  def skip_upload?
    @skip_upload
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

    if name.present?
      ext = ::File.extname(name.to_s).downcase
      if types[ext] != true
        errors.add_to_base "許可されていないファイルです。（#{allowed_type}）"
        return
      end
    end

    if file.present? && file.original_filename.present?
      ext = ::File.extname(file.original_filename.to_s).downcase
      unless types[ext]
        errors.add_to_base "許可されていないファイルです。（#{allowed_type}）"
        return
      end
    end
  end

  def validate_upload_file
    return true if file.blank?

    maxsize = @maxsize || Sys::Setting.value(:file_upload_max_size).to_i
    if file.size > maxsize.to_i  * (1024**2)
      errors.add :file, "が容量制限を超えています。＜#{maxsize}MB＞"
      return true
    end

    self.mime_type    = file.content_type
    self.size         = file.size
    self.image_is     = 2
    self.image_width  = nil
    self.image_height = nil

    begin
      image = case file
              when ActionDispatch::Http::UploadedFile
                not_image = false

                `type file > /dev/null 2>&1`
                if $?.exitstatus == 0
                  not_image = `file #{file.path}` !~ /GIF|JPEG|PNG/
                end

                Magick::Image.read(file.path).first unless not_image
              when Sys::Lib::File::NoUploadedFile
                self.skip_upload(true)
                Magick::Image.from_blob(file.read).first if file.image?
              else
                raise %Q!"#{file.class}" is not supported.!
              end
      if image && image.format.in?(%w!GIF JPEG PNG!)
        image.auto_orient!
        image.resize_to_fit!(image_resize.to_i) if image_resize.present?
        image.write(file.path) unless skip_upload?

        # Overwrite browser declaration
        self.mime_type = case image.format
                         when 'GIF'
                           'image/gif'
                         when 'JPEG'
                           'image/jpeg'
                         when 'PNG'
                           'image/png'
                         end
        self.size = File.size(file.path) unless skip_upload?

        self.image_is = 1
        self.image_width = image.columns
        self.image_height = image.rows
      end
    rescue => e
      warn_log("#{self.mime_type}: #{e.message}")
    end

    @file_content = file.read
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
    image_is == 1
  end

  def escaped_name
    CGI::escape(name)
  end

  def united_name
    "#{title}[#{::File.extname(name.to_s).gsub(/\./, '').upcase}：#{eng_unit}]"
  end

  def alt
    title.presence || name
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
      'iconFile icon' + ext.gsub(/\b\w/) {|word| word.upcase}
    else
      'iconFile'
    end
  end

  def eng_unit
    _size = size
    return _size if _size.to_s !~ /^[0-9]+$/
    
    if _size >= 1024**3
      bs = (_size.to_f / (1024**3)).round#.to_s + '000'
      return "#{bs}GB"
    elsif _size >= 1024**2
      bs = (_size.to_f / (1024**2)).round#.to_s + '000'
      return "#{bs}MB"
    elsif _size >= 1000
      bs = (_size.to_f / 1024).round#.to_s + '000'
      return "#{bs}KB"
    end
    return "#{_size}Bytes"
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

  def crop(x, y, w, h)
    return false unless image_file?
    image = Magick::Image.from_blob(File.read(upload_path)).first

    if image && image.format.in?(%w!GIF JPEG PNG!)
      image.crop!(Magick::NorthWestGravity, x, y, w, h)
      image.write(upload_path)
    end

    update_attribute(:size, File.size(upload_path))
    update_attribute(:image_width,  image.columns)
    update_attribute(:image_height, image.rows)

    return true
  end

  private

  ## filter/aftar_save
  def upload_internal_file
    Util::File.put(upload_path, :data => @file_content, :mkdir => true) unless @file_content.nil?
    return true
  end

  ## filter/aftar_destroy
  def remove_internal_file
    return true unless file_exist?
    FileUtils.remove_entry_secure(upload_path)
    return true
  end
end
