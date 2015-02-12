class DropboxWorker
  include Mongoid::Document
  include Sidekiq::Worker

	require 'dropbox_sdk'


	@@client = DropboxClient.new(DropboxToken.last[:token])
	@@root_path = '/PlayInPeelAutoImport'
	@@imported_prefix = '-(imported)'



	def perform
		get_facility
		get_activity
	end

  def get_activity
  	get_activity_files.each do |path|
  		next unless path.index(@@imported_prefix)==nil
  		file = get_file(path)
  		next if file == nil?
	  	get_csv(file).each do |row|
	  		Activity.create({
	  			FacilityName: row['Facility'].force_encoding('UTF-8'),
	  			Name: row['Activity.Name'].force_encoding('UTF-8'),
	  			Description: row['Description'].force_encoding('UTF-8'),
	  			AgeFrom: valid_s(row['Age.Start']).to_i,
	  			AgeTo: valid_s(row['Age.End']).to_i,
	  			Code: row['Activity.Code'],
	  			DropIn: (row['Drop.In']=='Yes')?true:false,
  				Fee: row['Fee'].to_f,
  				FeeDescription: row['Fee.Description'].force_encoding('UTF-8'),
	  			Times: get_times({
						days: row['Days'],
						start: {
							date: row['Start.Date'],
							time: row['Start.Time']
						},
						:'end' => {
							date: row['End.Date'],
							time: row['End.Time']
						}
					})
	  		})
	  	end
	  	imported_file = "#{path}#{@@imported_prefix}"
			begin 
				@@client.file_delete imported_file 
			rescue
			end
	  	@@client.file_move path, imported_file
  	end
  	return true
  end

  def get_facility
  	get_facility_files.each do |path|
  		next unless path.index(@@imported_prefix)==nil
  		file = get_file(path)
  		next if file == nil?
	  	get_csv(file).each do |row|
	  		Facility.create({
	  			Name: row['Facility Name'].nil? ? "":row['Facility Name'].force_encoding('UTF-8'),
	  			Aliases: row['Aliases (optional)'].nil? ? "":row['Aliases (optional)'].force_encoding('UTF-8'),
	  			Address: row['Full Address'].nil? ? "":row['Full Address'].force_encoding('UTF-8'),
	  			City: row['City'].nil? ? "":row['City'].force_encoding('UTF-8'),
	  			Phone: row['Phone'].nil? ? "":row['Phone'].force_encoding('UTF-8'),
	  			Lat: row['Latitude'].to_f,
	  			Lon: row['Logitude'].to_f
	  		})
	  	end
	  	imported_file = "#{path}#{@@imported_prefix}"
			begin 
				@@client.file_delete imported_file 
			rescue
			end
	  	@@client.file_move path, imported_file
  	end
  	return true
  end

  private

  	def rm_dropbox_file(path)
			@@client.file_delete(path)
  	end

	  def get_csv(contents)
	  	return CSV.parse(contents, :headers => true)
	  end

	  def get_activity_files
	  	search_files(@@root_path, 'activities .csv')
	  end

	  def get_facility_files
	  	search_files(@@root_path, 'facilities .csv')
	  end

	  def search_files(path, pattern)
	  	paths = []
	  	@@client.search(path, pattern).each do |f|
	  		paths << f['path']
	  	end
	  	paths
	  end

	  def get_file(from_file)
	  	begin
				contents = @@client.get_file(from_file)
				return contents
			rescue
				return nil
			end
  	end

  	def get_times(params)
  		days = params[:days]
  		times = {}

			days = ['M','Tu','W','Th','F','Sa','Su']
			days1 = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']

			#row = {Days: 'M, Tu-F, Su'}
			input = params[:days]

			ret_false = {
				_id: 0,
				"Monday" => false,
				"Tuesday" => false,
				"Wednesday" => false,
				"Thursday" => false,
				"Friday" => false,
				"Saturday" => false,
				"Sunday" => false,
			}

			times = ret_false

			input.split(', ').each do |r|
			    if input.upcase == 'DAILY'
			        days1.each do |day|
			            times[day] = true
			        end
			    else
			        unless days.index(r) == nil
			            times["#{days1[days.index(r)]}"] = true
			        else
			            unless r.index('-') == nil
			                rr = r.split('-')
			                if rr.count==2 and days.index(rr[0])!=nil and days.index(rr[1])!=nil
			                    days1[days.index(rr[0])..days.index(rr[1])].each do |day|
			                        times["#{day}"] = true
			                    end
			                end
			            end
			        end
			    end
			end

			ampm = params[:start][:time].last(2).upcase
			dt = "#{strpdate(params[:start][:date])}T#{params[:start][:time]}"

			if ampm == "AM" || ampm == "PM"
  			times[:StartDate] = DateTime::strptime(dt,  '%Y-%m-%dT%H:%M %p')
  		else
  			times[:StartDate] = DateTime::strptime(dt,  '%Y-%m-%dT%H:%M')
  		end

			ampm = params[:end][:time].last(2).upcase
			dt = "#{strpdate(params[:end][:date])}T#{params[:end][:time]}"

			if ampm == "AM" || ampm == "PM"
  			times[:EndDate] = DateTime::strptime(dt,  '%Y-%m-%dT%H:%M %p')
  		else
  			times[:EndDate] = DateTime::strptime(dt,  '%Y-%m-%dT%H:%M')
  		end

  		times[:TimeOfDay] = params[:start][:time].last(2)

  		times
  	end

  	def strpdate(date_s)
  		return date_s if date_s.size == 10
  		"20#{date_s}"
  	end

  	def valid_s(val)
  		return "" if val == nil
  		val.to_s
  	end
end
