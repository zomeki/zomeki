class Sys::Script::TasksController < ApplicationController
  def exec
    tasks = Sys::Task.where(Sys::Task.arel_table[:process_at].lteq(3.minutes.since))
                     .order(:process_at)
                     .includes(:unid_data)

    Script.total tasks.size

    return render(:text => 'No Tasks') if tasks.empty?

    tasks.each do |task|
      begin
        unless unid = task.unid_data
          task.destroy
          raise 'Unid Not Found'
        end
        
        model = unid.model.underscore.pluralize
        item  = eval(unid.model).find_by_unid(unid.id)
        
        model = "cms/nodes" if model == "cms/model/node/pages" # for v1.1.7
        ctl   = model.gsub(/^(.*?)\//, '\1/script/')
        act   = "#{task.name}_by_task"
        
        params.merge!({:unid => unid, :task => task, :item => item})
        render_component_into_view :controller => ctl, :action => act, :params => params
      rescue => e
        Script.error e
        puts "Error: #{e}"
      end
    end
    
    render(:text => "OK")
  end
end
