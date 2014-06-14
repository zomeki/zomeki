# encoding: utf-8

class Sys::Script::RunnerController < ApplicationController
  def run
    Dir.chdir("#{Rails.root}")
    
    ctl = ::File.dirname(params[:path])
    act = ::File.basename(params[:path])
      
    res = render_component :controller => ctl, :action => act, :params => params
    logger.info "OK (#{res.body})"

  rescue Script::InterruptException => e
    Script.log "Interrupt: #{e}"
  rescue LoadError => e
    Script.error "#{e}"
  rescue Exception => e
    Script.error "#{e}"
  end
  
  def runn
    puts "runn"
    render :text => "runn"
  end
end
