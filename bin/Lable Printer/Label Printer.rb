require 'tk' # GUI
require 'tkextlib/tile' #Advanced GUI
require_relative '../MechReporter' # Reporter and link to RubyExcel
require_relative '../Directory' # Reporter and link to RubyExcel

require_relative 'GUI/Label Printer GUI.rb'
require_relative 'Scripts/Label Printer.rb'

$title = 'Label Printer'

# Allows EXE builds without showing the GUI
MechReporter.new if defined?( Ocra )

unless defined?(Ocra)
	#Output log
	orig_std_out = STDOUT.clone #Make a record of the default console output to return to it later
  logdir = documents_path + '\Ruby Logs'
  check_dir_path(logdir)
  $logfile = logdir + '\Label Printer.log'
	$stdout.reopen($logfile, 'w') #Create / overwrite logfile
	$stdout.sync = true #Allow interception of console output
	$stderr.reopen($stdout) #Pass errors to logfile
end

if defined?(Ocra)
  #Let Ocra pick up the encryption...
  testy = Crypt::Blowfish.new("1").encrypt_string("Moose")
  p testy
#  #Webdriver...
#  testy = Watir::Browser.new
#  testy.close
  MechReporter.new
  exit 
end

begin #ErrorHandler

	# Let there be a GUI!
	GUI = LabelGui.new

	class MechReporter;def puts(*args);GUI.gui_puts(args.join($/));end;end
	
	# Go!
	GUI.run
  
  #ErrorHandler
  rescue #Report on any error and quit

  puts %Q|Fatal error occurred:\n#{$!}\n\nDebugging Information:\n#{$@}|,"Error" #Logfile output
  exit

  ensure #This will execute even after an error


end #ErrorHandler
