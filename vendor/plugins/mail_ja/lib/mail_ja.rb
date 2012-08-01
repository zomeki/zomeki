module Mail
  class Message
    def process_body_raw_with_iso_2022_jp_encoding
      if @charset.to_s.downcase == 'iso-2022-jp'
        @body_raw = NKF.nkf('-j', @body_raw)
      end
      process_body_raw_without_iso_2022_jp_encoding
    end
    alias_method :process_body_raw_without_iso_2022_jp_encoding, :process_body_raw
    alias_method :process_body_raw, :process_body_raw_with_iso_2022_jp_encoding
  end

  class SubjectField < UnstructuredField
    def initialize_with_iso_2022_jp_encoding(value = nil, charset = 'utf-8')
      if charset.to_s.downcase == 'iso-2022-jp'
        value = NKF.nkf('--cp932 -M', NKF.nkf('--cp932 -j', value)).gsub("\n", '').strip
      end
      initialize_without_iso_2022_jp_encoding(value, charset)
    end
    alias_method :initialize_without_iso_2022_jp_encoding, :initialize
    alias_method :initialize, :initialize_with_iso_2022_jp_encoding

    private
    def do_decode_with_iso_2022_jp_encoding
      if charset.to_s.downcase == 'iso-2022-jp'
        value
      else
        do_decode_without_iso_2022_jp_encoding
      end
    end
    alias_method :do_decode_without_iso_2022_jp_encoding, :do_decode
    alias_method :do_decode, :do_decode_with_iso_2022_jp_encoding
  end
end
