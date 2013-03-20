# encoding: utf-8
module Newsletter::Model::Base::Delivery

  def delivery_states
    [['未配信','yet'], ['配信中','delivering'], ['配信済み','delivered'], ['配信失敗','error']]
  end

  def delivery_status_name
    delivery_states.each do |name, id|
      return name if delivery_state.to_s == id
    end
    nil
  end

  def deliverable?
    delivery_state != 'delivered'
  end

end