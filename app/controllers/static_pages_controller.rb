class StaticPagesController < ApplicationController
  skip_authorization_check
  skip_before_action :authenticate_user!
  def index
    @activities = Activity.any_of({ :Name => /.*Canoe*/ })
    respond_to do |format|
      format.html
      format.json
    end
  end

  def new
  end

  def edit
  end

  def home
  end

  def search
  end
end
