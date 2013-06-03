# encoding: utf-8
module Cms::Model::Base::Page
  STATE_OPTIONS = [['公開', 'public'], ['非公開', 'closed']]

  def states
    [['公開','public'],['非公開','closed']]
  end

  def public
    self.and "#{self.class.table_name}.state", 'public'
    self
  end

  def public?
    return state == 'public'
  end

  def public_or_preview
    return self if Core.mode == 'preview'
    public
  end
end
