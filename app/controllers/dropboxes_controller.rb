class DropboxesController < ApplicationController
  skip_authorization_check
  skip_before_action :authenticate_user!

  def index
  end

  def show
  end

  def sync
    render :text=>params[:challenge] and return unless params[:challenge].nil?
  	DropboxWorker.perform_async
    render :text=>'true'
  end
end
