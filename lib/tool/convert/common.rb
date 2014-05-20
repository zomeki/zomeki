# encoding: utf-8
module Tool::Convert::Common

  # 例:
  #  <div id="main"><p class="title"><h1>
  #   =>  "//div[@id='main']/p[@class='title']/h1",
  def self.convert_to_xpath(str)
    return "" unless str.present?
    doc = Nokogiri::parse(str)
    tmp = doc
    elements = []
    while tmp.children.present? do
      elements << tmp.children[0]
      tmp = tmp.children[0]
    end

    return "" unless elements.present?

    result = "//"
    elements.each do |e|
      result << e.name
      id = e.attributes["id"].value if e.attributes["id"].present?
      cls = e.attributes["class"].value if e.attributes["class"].present?
      result << "[@id='#{id}']" if id.present?
      result << "[@class='#{cls}']" if cls.present?
      result << "/"
    end

    return result[0..-2]
  end
end
