# encoding: utf-8

require 'nokogiri'

class Tool::Convert::PageParseInfo

  attr_reader :file_path, :uri_path, :options, :html_doc, :host,
              :title, :body

  def initialize(host, file_path, uri_path, options={})
    @host = host
    @file_path = file_path
    @uri_path = uri_path
    @options = {
      title_xpath: "",
      body_xpath: ""
    }.merge options
  end

  # 記事ページである判断
  def is_kiji_page?
    @title.present? && @body.present?
  end

  def parse
    @html_doc = Nokogiri::HTML(open(file_path))
    @title = @html_doc.xpath(@options[:title_xpath]).inner_text.strip
    @body = @html_doc.xpath(@options[:body_xpath]).inner_html
  end

end
