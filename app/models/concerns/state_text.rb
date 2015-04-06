module StateText
  extend ActiveSupport::Concern

  class Responder
    def self.state_text(state)
      case state
      when 'enabled'; '有効'
      when 'disabled'; '無効'
      when 'visible'; '表示'
      when 'hidden'; '非表示'
      when 'draft'; '下書き'
      when 'recognize'; '承認待ち'
      when 'approvable'; '承認待ち'
      when 'recognized'; '公開待ち'
      when 'approved'; '公開待ち'
      when 'prepared'; '公開'
      when 'public'; '公開中'
      when 'closed'; '非公開'
      when 'completed'; '完了'
      when 'archived'; '履歴'
      when 'synced'; '同期済'
      else ''
      end
    end

    def initialize(stateable, attribute_name=:state)
      @stateable = stateable
      @attribute_name = attribute_name
    end

    def name
      self.class.state_text(@stateable.send(@attribute_name))
    end
  end

  def status
    Responder.new(self)
  end

  def web_status
    Responder.new(self, :web_state)
  end

  def portal_group_status
    Responder.new(self, :portal_group_state)
  end

  def state_text
    Responder.state_text(self.state)
  end

  def web_state_text
    Responder.state_text(self.web_state)
  end

  def portal_group_state_text
    Responder.state_text(self.portal_group_state)
  end
end
