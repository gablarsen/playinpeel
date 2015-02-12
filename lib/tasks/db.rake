namespace :db do
	task :clear_activity => :environment do
		Activity.destroy_all
	end

	task :clear_facility => :environment do
		Facility.destroy_all
	end
end