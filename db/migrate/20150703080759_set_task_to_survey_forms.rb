class SetTaskToSurveyForms < ActiveRecord::Migration
  def change

    Survey::Form.new.find(:all).each do |form|
      now = Time.now

      if form.closed_at
        if form.closed_at < now && form.state_public?
          form.close
          next
        elsif form.closed_at < now && form.state == 'closed'
          
        else
          form.in_tasks = {:close => form.closed_at}
          form.save_tasks
        end
      end
      
      if form.opened_at
        if form.opened_at > now && form.state_public?
          form.update_column(:state, 'approved')
          form.in_tasks = {:publish => form.opened_at}
          form.save_tasks
        elsif form.opened_at < now && form.state_public?
          next
        elsif form.opened_at < now && form.state_approved?
          form.publish
        else
          form.in_tasks = {:publish => form.opened_at}
          form.save_tasks
        end
      end
      
    end
  end
end
