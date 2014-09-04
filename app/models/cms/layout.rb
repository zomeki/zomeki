# encoding: utf-8
class Cms::Layout < ActiveRecord::Base
  include Sys::Model::Base
  include Cms::Model::Base::Page::Publisher
  include Sys::Model::Rel::Unid
  include Sys::Model::Rel::Creator
  include Cms::Model::Rel::Site
  include Cms::Model::Rel::Concept
  include Cms::Model::Auth::Concept

  belongs_to :status,  :foreign_key => :state, :class_name => 'Sys::Base::Status'
  
  validates_presence_of :state, :name, :title
  validates_uniqueness_of :name, :scope => :concept_id
  validates_format_of :name, :with => /^[0-9a-zA-Z\-_]+$/, :if => "!name.blank?",
    :message => "は半角英数字、ハイフン、アンダースコアで入力してください。"
  
  after_destroy :remove_css_files
  
  def states
    [['公開','public']]
  end
  
  def publishable? # TODO dummy
    return true
  end
  
  def node_is(node)
    node = Cms::Node.find(:first, :conditions => {:id => node}) if node.class != Cms::Node
    self.and :id, node.inherited_layout.id if node
  end
  
  def piece_names
    names = []
    body.scan(/\[\[piece\/([0-9a-zA-Z_-]+)\]\]/) do |name|
      names << name[0]
    end
    return names.uniq
  end
  
  def pieces(concept = nil)
    pieces = []
    piece_names.each do |name|
      if concept
        piece = Cms::Piece.find(:first, :conditions => {:name => name, :concept_id => concept}, :order => :id)
      end
      unless piece
        piece = Cms::Piece.find(:first, :conditions => {:name => name, :concept_id => self.concept}, :order => :id)
      end
      unless piece
        piece = Cms::Piece.find(:first, :conditions => {:name => name, :concept_id => nil}, :order => :id)
      end
      pieces << piece if piece
    end
    return pieces
  end
  
  def head_tag(request)
    tag = head_tag_with_request(request)
    tag = tag.gsub(/<link [^>]+>/i, '').gsub(/(\r\n|\n)+/, "\n") if request.mobile?
    tag.html_safe
  end
  
  def head_tag_with_request(request)
    tags = []
    
    if uri = stylesheet_uri(request)
      tags << %Q(<link href="#{uri}" media="all" rel="stylesheet" type="text/css" />)
    end
    
    if request.mobile? && !mobile_head.blank?
      tags << mobile_head
    elsif request.smart_phone? && !smart_phone_head.blank?
      tags << smart_phone_head
    else
      tags << head.to_s
    end
                    
    tags.delete('')
    tags.join("\n")
  end
  
  def body_tag(request)
    if request.mobile? && !mobile_body.blank?
      mobile_body.html_safe
    elsif request.smart_phone? && !smart_phone_body.blank?
      smart_phone_body.html_safe
    else
      body.html_safe
    end
  end
  
  def stylesheet_uri(request)
    return nil unless id
    dir = site.uri + '_layouts/' + Util::String::CheckDigit.check(format('%07d', id))
    
    if request.mobile? && !mobile_stylesheet.blank?
      dir + '/mobile.css'
    elsif request.smart_phone? && !smart_phone_stylesheet.blank?
      dir + '/smart_phone.css'
    else
      dir + '/style.css' 
    end
  end
  
  def stylesheet_path
    return nil unless id
    dir = Util::String::CheckDigit.check(format('%07d', id))
    dir = dir.gsub(/(\d\d)(\d\d)(\d\d)(\d\d)/, '\1/\2/\3/\4/\1\2\3\4')
    dir = site.public_path + '/_layouts/' + dir
    
    return dir + '/style.css'
  end
  
  def public_path
    site.public_path + '/layout/' + name + '/style.css' 
  end
  
  def public_uri # TODO dummy
    '/layout/' + name + '/style.css' 
  end
  
  def request_publish_data # TODO dummy
    _res = {
      :page_type => 'text/css',
      :page_size => stylesheet.size,
      :page_data => stylesheet,
    }
  end
  
  def tamtam_css(request)
    tag = head_tag_with_request(request)
    
    css = ''
    tag.scan(/<link [^>]*?rel="stylesheet"[^>]*?>/i) do |m|
      css += %Q(@import "#{m.gsub(/.*href="(.*?)".*/, '\1')}";\n)
    end
    css += mobile_stylesheet if !mobile_stylesheet.blank?
    
    4.times do
      css = convert_css_for_tamtam(css)
    end
    css.gsub!(/^@.*/, '')
    css.gsub!(/[a-z]:after/i, '-after')
    css
  end
  
  def convert_css_for_tamtam(css)
    css.gsub(/^@import .*/) do |m|
      path = m.gsub(/^@import ['"](.*?)['"];/, '\1')
      dir  = (path =~ /^\/_common\//) ? "#{Rails.root}/public" : site.public_path
      file = "#{dir}#{path}"
      if FileTest.exist?(file)
        d = ::File.read(file).encode(Encoding::UTF_8, invalid: :replace, undef: :replace)
        m = d.gsub(/(\r\n|\n|\r)/, "\n").gsub(/^@import ['"](.*?)['"];/) do |m2|
          p = m2.gsub(/.*?["'](.*?)["'].*/, '\1')
          p = ::File.expand_path(p, ::File.dirname(path)) if p =~ /^\./
          %Q(@import "#{p}";)
        end
      else
        m = ''
      end
      m
    end
  end
  
  def extended_css(options = {})
    css = extend_css(public_path)
    if options[:skip_charset] == true
      css.gsub!(/(^|\n)@charset .*?(\n|$)/, '\1')
    end
  end
  
  def extend_css(path)
    return '' unless FileTest.exist?(path)
    css = ::File.new(path).read
    if css =~ /^@import/
      css.gsub!(/(^|\n)@import .*?(\n|$)/iom) do |m|
        src = m.gsub(/(^|\n)@import ["](.*)["].*?(\n|$)/, '\2')
        if src.slice(0, 9) == '/_common/'
          src = "#{Rails.root}/public#{src}"
        elsif src.slice(0, 1) != '/'
          src = ::File.dirname(path) + '/' + src
        else
          '/* skip */'
        end
        extend_css(src) + "\n"
      end
    end
    css
  end
  
  def put_css_files
    path = stylesheet_path
    Util::File.put(path, :data => stylesheet.to_s, :mkdir => true)
    
    path = ::File.dirname(path) + '/mobile.css'
    Util::File.put(path, :data => mobile_stylesheet.to_s, :mkdir => true)
    
    path = ::File.dirname(path) + '/smart_phone.css'
    Util::File.put(path, :data => smart_phone_stylesheet.to_s, :mkdir => true)
    
    return true
  end
  
  def remove_css_files
    path = stylesheet_path
    FileUtils.rm_f(path)
    
    path = ::File.dirname(path) + '/mobile.css'
    FileUtils.rm_f(path)
    
    path = ::File.dirname(path) + '/smart_phone.css'
    FileUtils.rm_f(path)
    
    FileUtils.rmdir(::File.dirname(path)) rescue nil
    return true
  end
  
  def duplicate(rel_type = nil)
    item = self.class.new(self.attributes)
    item.id            = nil
    item.unid          = nil
    item.created_at    = nil
    item.updated_at    = nil
    item.recognized_at = nil
    item.published_at  = nil
    
    if rel_type == nil
      item.name          = nil
      item.title         = item.title.gsub(/^(【複製】)*/, "【複製】")
    end
    
    return item.save(:validate => false)
  end
end
