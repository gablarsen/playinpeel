class DropboxesController < ApplicationController
  skip_authorization_check
  skip_before_action :authenticate_user!

  def index
  end

  def show
  end

  def sync
    render :text=>params[:challenge] and return unless params[:challenge].nil?

  	@result = DropboxHandler.get_activity
  	@result = DropboxHandler.get_facility unless @result.nil?
  	render :text=>!@result.nil?.to_s
  end
end
