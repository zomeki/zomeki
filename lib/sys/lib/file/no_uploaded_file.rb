class Sys::Lib::File::NoUploadedFile
  def initialize(path, options = {})
    if path.class == Hash
      options    = path
      @data      = options[:data]
    else
      require 'mime/types'
      file       = ::File.new(path)
      @data      = file.read
      @mime_type = MIME::Types.type_for(path)[0].to_s
    end
    @filename  = options[:filename]
    @size      = @data.size if @data
    @image     = validate_image
  end
  
  def errors
    @errors
  end
  
  def read
    @data
  end
  
  def original_filename
    @original_filename
  end
  
  def size
    @size
  end
  
  def mime_type
    @image ? @image.mime_type : @mime_type
  end
  
  def content_type
    mime_type
  end
  
  def image_is
    @image ? 1 : 2
  end
  
  def image_width
    @image ? @image.columns : nil
  end
  
  def image_height
    @image ? @image.rows : nil
  end
  
  def validate_image
    begin
      require 'RMagick'
      image = Magick::Image.from_blob(@data).shift
      if image.format =~ /(GIF|JPEG|PNG)/
        return image
      end
    rescue LoadError
      return nil
    rescue Magick::ImageMagickError
      return nil
    rescue NoMethodError
      return nil
    rescue
      return nil
    end
  end
end