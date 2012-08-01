# encoding: utf-8
module Jpmobile
  module SessionID
    def self.generate_sid
      
    end
  end
  
  class Resolver < ActionView::FileSystemResolver
    def query(path, exts, formats, mobile)
      query = File.join(@path, path)
      query << '{' << mobile.map {|v| "_#{v}"}.join(',') << ',}' if mobile and mobile.respond_to?(:map)
      exts.each do |ext|
        query << '{' << ext.map {|e| e && ".#{e}" }.join(',') << ',}'
      end

      query.gsub!(/\{\.html,/, "{.html,.text.html,")
      query.gsub!(/\{\.text,/, "{.text,.text.plain,")

      Dir[query].reject { |p| File.directory?(p) }.map do |p|
        handler, format = extract_handler_and_format(p, formats)


        contents = File.open(p, "rb") {|io| io.read }
#        variant = p.match(/.+#{path}(.+)\.#{format.to_sym.to_s}.*$/) ? $1 : ''
        variant = format ? ( p.match(/.+#{path}(.+)\.#{format.to_sym.to_s}.*$/) ? $1 : '' ) : ''

        ActionView::Template.new(contents, File.expand_path(p), handler,
          :virtual_path => path + variant, :format => format)
      end
    end
  end
end
