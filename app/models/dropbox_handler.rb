class DropboxHandler
  include Mongoid::Document
	require 'dropbox_sdk'
  def self.get_activity
  	file = get_file('PlayInPeelAutoImport/PlayInPeelActivities_Gabrieal.csv')
  	return nil if file.nil?
  	get_csv(file).each do |row|
  		Activity.create({
  			Name: row['Activity.Name'].force_encoding('UTF-8'),
  			Description: row['Description'].force_encoding('UTF-8'),
  			AgeFrom: row['Age.Start'],
  			AgeTo: row['Age.End'],
  			Code: row['Activity.Code'],
  			DropIn: (row['Drop.In']=='Yes')?true:false,
  			Fees: [{
  				Name: row['Fee.Description'].force_encoding('UTF-8'),
  				Description: row['Fee.Description'].force_encoding('UTF-8'),
  				Cost: row['Fee']
  			}],
  			Times: get_times(
  				{
  					days: row['Days'],
  					start: {
  						date: row['Start.Date'],
  						time: row['Start.Time']
  					},
  					:'end' => {
  						date: row['End.Date'],
  						time: row['End.Time']
  					}
  				}
  			)
  		})
  	end
  	#rm_dropbox_file 'PlayInPeelAutoImport/PlayInPeelActivities_Gabrieal.csv'
  	return true
  end

  def self.get_facility
  	file = get_file('PlayInPeelAutoImport/PlayInPeelFacilities_Gabriel.csv')
  	return nil if file.nil?
  	get_csv(file).each do |row|
  		Facility.create({
  			Name: row['Facility Name'].nil? ? "":row['Facility Name'].force_encoding('UTF-8'),
  			Aliases: row['Aliases (optional)'].nil? ? "":row['Aliases (optional)'].force_encoding('UTF-8'),
  			Address: row['Full Address'].nil? ? "":row['Full Address'].force_encoding('UTF-8'),
  			City: row['City'].nil? ? "":row['City'].force_encoding('UTF-8'),
  			Phone: row['Phone'].nil? ? "":row['Phone'].force_encoding('UTF-8'),
  			Lat: row['Latitude'],
  			Lon: row['Logitude']
  		})
  	end
  	#rm_dropbox_file 'PlayInPeelAutoImport/PlayInPeelFacilities_Gabriel.csv'
  	return true
  end

  private

  	def self.rm_dropbox_file(path)
			client = DropboxClient.new(DropboxToken.last[:token])
			client.file_delete(path)
  	end

	  def self.get_csv(contents)
	  	return CSV.parse(contents, :headers => true)
	  end

	  def self.get_csv_from_file(file)
	    CSV.foreach(file.path, headers: true) do |row|
	      lovedone = row.to_hash
	      lovedone = Lovedone.new ({
	        city: lovedone["City"],
	        county: lovedone["County"]
	      })
	    end
	  end


	  def self.get_file(from_file)
	  	begin
				client = DropboxClient.new(DropboxToken.last[:token])
				contents = client.get_file(from_file)
				return contents
			rescue
				return nil
			end

=begin
		# this section is the feature for case when we need to handle big file contents
		prefix = 'mydata'
		suffix = '.csv'
		file = Tempfile.new [prefix, suffix], "#{Rails.root}/tmp"
		file.write contents
		file.rewind
		file.close
		return file.path
=end
  	end

  	def self.get_times(params)
  		days = params[:days]
  		times = {}

			days = ['M','Tu','W','Th','F','Sa','Su']
			days1 = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']

			#row = {Days: 'M, Tu-F, Su'}
			input = params[:days]

			ret_false = {
			    Monday: false,
			    Tuesday: false,
			    Wednesday: false,
			    Thursday: false,
			    Friday: false,
			    Saturday: false,
			    Sunday: false,
			}

			times = ret_false
			input.split(', ').each do |r|
			    if input == 'Daily'
			        days1.each do |day|
			            times[day] = true
			        end
			    else
			        unless days.index(r) == nil
			            times[:"#{days1[days.index(r)]}"] = true
			        else
			            unless r.index('-') == nil
			                rr = r.split('-')
			                if rr.count==2 and days.index(rr[0])!=nil and days.index(rr[1])!=nil
			                    days1[days.index(rr[0])..days.index(rr[1])].each do |day|
			                        times[:"#{day}"] = true
			                    end
			                end
			            end
			        end
			    end
			end

			puts "params[:start][:date]"
			puts params[:start][:date]
			puts params[:start][:time]
			ampm = params[:start][:time].last(2).upcase
			if ampm == "AM" || ampm == "PM"
  			times[:StartDate] = DateTime::strptime("#{params[:start][:date]}T#{params[:start][:time]}",  '%Y-%m-%dT%H:%M %p')
  		else
  			times[:StartDate] = DateTime::strptime("#{params[:start][:date]}T#{params[:start][:time]}",  '%Y-%m-%dT%H:%M')
  		end

			ampm = params[:end][:time].last(2).upcase
			if ampm == "AM" || ampm == "PM"
  			times[:EndDate] = DateTime::strptime("#{params[:end][:date]}T#{params[:end][:time]}",  '%Y-%m-%dT%H:%M %p')
  		else
  			times[:EndDate] = DateTime::strptime("#{params[:end][:date]}T#{params[:end][:time]}",  '%Y-%m-%dT%H:%M')
  		end

  		times[:TimeOfDay] = params[:start][:time].last(2)

  		times
  	end
end
