class FacilitiesController < ApplicationController
  skip_authorization_check
  skip_before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token
  def show
    @search_url = state_pages_post_url
  end
end
