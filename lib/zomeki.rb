# encoding: utf-8
module Zomeki
  def self.version
    "1.1.0"
  end
  
  def self.default_config
    { "application" => {
      "sys.crypt_pass"                => "zomeki",
      "sys.recognizers_include_admin" => false,
      "sys.auto_link_check"           => true,
      "cms.publish_more_pages"        => 0
    }}
  end
  
  def self.config
    $zomeki_config ||= {}
    Zomeki::Config
  end
  
  class Zomeki::Config
    def self.application
      return $zomeki_config[:imap_settings] if $zomeki_config[:imap_settings]
      
      config = Zomeki.default_config["application"]
      file   = "#{Rails.root}/config/application.yml"
      if ::File.exist?(file)
        yml = YAML.load_file(file)
        yml.each do |mod, values|
          values.each do |key, value|
            config["#{mod}.#{key}"] = value unless value.nil?
          end if values
        end if yml
      end
      $zomeki_config[:application] = config
    end
  end
end
