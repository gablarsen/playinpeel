namespace :db do
	task :clear_activity do
		Activity.destroy_all
	end

	task :clear_facility do
		Facility.destroy_all
	end
end