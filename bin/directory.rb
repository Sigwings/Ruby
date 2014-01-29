#require_relative '../RegistryTools'

#include RegistryTools

	def create_directory(directory)

		unless File.directory?(directory)
			Dir::mkdir(directory)
			puts 'Created Directory ' + directory
		end
		directory
	end

	def check_dir_path(directory)

		dir_split = directory.split( /\\/)

		dir = ''
		dir_split.each { |a| 
			dir = dir + a; 
			create_directory(dir); 
			dir = (dir + '\ ').chop; 
	#		puts dir
		}
		directory
	end