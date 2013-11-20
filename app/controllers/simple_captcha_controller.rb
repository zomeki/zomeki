# encoding: utf-8
class SimpleCaptchaController < ApplicationController
  include SimpleCaptcha::ControllerHelpers
  
  def index
  end
  
  def talk
    return http_error(404) if params[:key].blank?
    
    data = SimpleCaptcha::SimpleCaptchaData.find_by_key(params[:key])
    return http_error(404) if data.blank?
    
    jtalk = Cms::Lib::Navi::Jtalk.new
    jtalk.make data.value
    file = jtalk.output
    send_file(file[:path], :type => file[:mime_type], :filename => 'sound.mp3', :disposition => 'inline')
  end
end
