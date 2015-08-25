require 'mime/types'
require 'RMagick'
require 'shellwords'

class Sys::Lib::File::NoUploadedFile
  def initialize(path, options = {})
    not_image = false

    case path
    when Hash
      options = path
      @data = options[:data]
    when String
      @data = ::File.read(path)
      @mime_type = options[:mime_type] || MIME::Types.type_for(path)[0].to_s
      `type file > /dev/null 2>&1`
      if $?.exitstatus == 0
        not_image = `file #{path.shellescape}` !~ /GIF|JPEG|PNG/
      end
    end

    @filename = options[:filename]
    @size = @data.size if @data

    @image = validate_image unless not_image
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

  def image?
    !!@image
  end

  def image_width
    @image ? @image.columns : nil
  end

  def image_height
    @image ? @image.rows : nil
  end

  def validate_image
    begin
      image = Magick::Image.from_blob(@data).first
      if image.format =~ /GIF|JPEG|PNG/
        image
      else
        nil
      end
    rescue => e
      warn_log "#{e.class}: #{e.message}"
      nil
    end
  end
end
