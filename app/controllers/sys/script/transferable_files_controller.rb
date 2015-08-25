class Sys::Script::TransferableFilesController < ApplicationController
  include Sys::Lib::File::Transfer

  def push
    transfer_files(:logging => true)
    render(:text => "OK")
  rescue => e
    raise "error #{e}"
  end
end
