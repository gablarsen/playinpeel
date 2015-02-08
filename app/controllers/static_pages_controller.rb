class StaticPagesController < ApplicationController
  skip_authorization_check
  skip_before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token
  def index
    @search_url = state_pages_post_url


    search_params = {
      description: 'Canoe',    # search keyward -> description
      astart_date: '2014/7/21',
      aend_date: '2014/7/31',
      registration: true,
      drop_in: false,
      time_of_day_am: "AM",
      time_of_day_pm: "PM",
      days:['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'],
      page: 0,
    }


    #Activity.where("Times.StartDate"=>{"$gt"=>Date.new(2014,6,12),"$lt"=>Date.new(2014,6,13)} ).count

    data_count = 20

    start_date_flag = !search_params[:start_date].nil?
    end_date_flag   = !search_params[:end_date].nil?

    registration_flag = !search_params[:registration].nil? || !search_params[:drop_in].nil?
    registration_n_drop_in = [search_params[:registration], search_params[:drop_in]]  #search keyword -> Activity Type: Registration: false, Drop-In: true

    time_of_day_flag = !search_params[:time_of_day_am].nil? || !search_params[:time_of_day_pm].nil?
    time_of_day = [
      search_params[:time_of_day_am], search_params[:time_of_day_pm]
    ]  #search keyword -> Activity Type: Drop-In


    days_flag = search_params[:days].count>0





    activities = Activity.any_of({ :Description => /.*#{search_params[:description]}*/ })
    @activities = []

    start_index = search_params[:page].to_i
    end_index = search_params[:page].to_i+data_count;
    activities.each_with_index do |activity, index|
      unless activity[:Times].first.nil?
        flag = true
        flag = (activity[:Times].first[:StartDate].to_date == search_params[:start_date].to_date) if start_date_flag && flag
        flag = (activity[:Times].first[:EndDate].to_date == search_params[:end_date].to_date) if end_date_flag && flag
        flag = registration_n_drop_in.index(activity[:DropIn]) != nil if registration_flag && flag
        flag = time_of_day.index(activity[:Times].first[:TimeOfDay]) != nil if time_of_day_flag && flag

        if days_flag && flag
          flag = false
          search_params[:days].each do |day|
            if activity[:Times].first["#{day}"]
              flag = true 
              break
            end
          end
        end
        if flag
          next if index < start_index
          break if index > end_index
          @activities << activity
        end
      end
    end

   
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
