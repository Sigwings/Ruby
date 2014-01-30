require 'tk' # GUI
require 'tkextlib/tile' #Advanced GUI
require_relative '../MechReporter' # Reporter and link to RubyExcel
require_relative '../RubyLogger' # Log file Logger


require_relative 'GUI/Label Printer GUI.rb'
require_relative 'Scripts/Label Printer.rb'

# Allows EXE builds without showing the GUI
MechReporter.new.ocra_build if defined?( Ocra )

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
