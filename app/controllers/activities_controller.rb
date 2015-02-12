class ActivitiesController < ApplicationController
  skip_authorization_check
  skip_before_action :authenticate_user!
  def index
  	search_result = []
  	callback = params[:callback]
  	Activity.search(params).each do |activity|
  		search_result << tweak_activity(activity)
  	end

  	render :text=> "#{callback}(#{search_result.to_json})" and return
  end

  def show
    callback = params[:callback]

    activity = Activity.find(params[:id])
    activity = tweak_activity(activity)
    render :text=> "#{callback}(#{activity.to_json})" and return
  end

  private
    def tweak_activity(activity)
      activity['Id'] = activity.id.to_s
      activity['Resource'] = activity.id.to_s
      activity['Exceptions'] = []
      activity['Fees'] = [{
        Cost: activity['Fee'],
        Description: activity['FeeDescription'],
        Id: 0,
        Name: ''
        }]
      activity["Organization"] = {
        "Id" => 1, 
        "Name" => activity['Name'],
        "GeneralActivityDescription" => activity['Description'],
        "ServiceLink" => "",
        "Activities" => []
      }

      activity['Facility']['Id'] = activity['Facility']['_id'].to_s
      
      activity["Resource"] = {
        "Id" => 0, 
        "Activities" => [],
        "Name" => activity['Name'],
        "GeneralActivityDescription" => activity['Description'],
        "Facility" => activity['Facility'],
        "Location" => [activity['location'][0], activity['location'][1]],
        "Lat" => activity['location'][1],
        "Lon" => activity['location'][0],
      }

      activity["Times"] = [activity["Times"]]

      activity["SearchTags"] = ''
      activity
    end
end
