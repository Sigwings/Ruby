module Directory

	def create_directory(directory)

		unless File.directory?(directory)
			Dir::mkdir(directory)
		end
		directory
	end

	def check_dir_path( filename )

		dir_split = ( File.dirname( filename ) ).split( /\\/)

		dir = ''
		dir_split.each { |a| 
			dir = dir + a; 
			create_directory(dir); 
			dir = (dir + '\ ').chop; 
		}
		filename
	end
  
	def get_current_directory
	
		dir = Dir.pwd
		
	end

end