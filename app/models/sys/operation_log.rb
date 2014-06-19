class Sys::OperationLog < ActiveRecord::Base
  include Sys::Model::Base

  default_scope order('updated_at DESC')

  belongs_to :loggable, :polymorphic => true
  belongs_to :user, :class_name => 'Sys::User'

  validates :loggable, :presence => true
  validates :user, :presence => true

  def self.log(request, options = {})
    params = request.params

    log = self.new
    log.uri       = Core.request_uri
    log.action    = params[:do]
    log.action    = params[:action] if params[:do].blank?
    log.ipaddr    = request.remote_addr
    log.site_id   = Core.site.id rescue 0

    if user = options[:user]
      log.user_id   = user.id
      log.user_name = user.name
    elsif user = Core.user
      log.user_id   = user.id
      log.user_name = user.name
    end


    if item = options[:item]
      log.item_model  = item.class.to_s
      log.item_id     = item.id rescue nil
      log.item_unid   = item.unid rescue nil
      log.item_name   = item.title rescue nil
      log.item_name ||= item.name rescue nil
      log.item_name ||= "##{item.id}" rescue nil
      log.item_name   = log.item_name.to_s.split(//u).slice(0, 80).join if !log.item_name.blank?
    end
    log.save(:validate => false)
  end

  def search(params)
    params.each do |n, v|
      next if v.to_s == ''

      case n
      when 's_id'
        self.and :id, v
      when 's_user_id'
        self.and :user_id, v
      when 's_action'
        self.and :action, v
      when 's_keyword'
        self.and_keywords v, :item_unid, :item_name, :item_model
      end
    end if params.size != 0

    return self
  end

end
