class ActivitiesController < ApplicationController
  skip_authorization_check
  skip_before_action :authenticate_user!
  def index
  	render :text=>Activity.search(params).count
  end
end
