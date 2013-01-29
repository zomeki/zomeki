# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ZomekiCMS::Application.initialize!

private
  def pp(*objs)
    logger = Logger.new File.join(Rails.root, 'log', 'out.log')
    objs.each { |obj| logger.debug PP.pp(obj, '') }
    nil
  end
