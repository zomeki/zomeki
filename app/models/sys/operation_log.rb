class Sys::OperationLog < ActiveRecord::Base
  include Sys::Model::Base

  default_scope order('updated_at DESC')

  ACTION_OPTIONS = [["作成","create"], ["更新","update"], ["承認","recognize"], ["承認","approve"], ["削除","destroy"], ["公開","publish"], ["非公開","close"], ["ログイン","login"], ["ログアウト","logout"]]

  belongs_to :loggable, :polymorphic => true
  belongs_to :user, :class_name => 'Sys::User'

  validates :loggable, :presence => true
  validates :user, :presence => true

  def action_text
    ACTION_OPTIONS.detect{|o| o.last == action }.try(:first).to_s
  end

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

  def self.script_log(options = {})
    unless options[:action]
      return self
    end

    log = self.new
    log.uri       = ''
    log.action    = options[:action]
    log.site_id   = options[:site].id rescue 0

    user_name = options[:user_name] || 'CMS'
    log.user_id   = 0
    log.user_name = user_name

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
        if v == 'recognize'
          self.and :action, ['recognize', 'approve']
        else
          self.and :action, v
        end
      when 's_keyword'
        self.and_keywords v, :item_unid, :item_name, :item_model
      end
    end if params.size != 0

    return self
  end

end
