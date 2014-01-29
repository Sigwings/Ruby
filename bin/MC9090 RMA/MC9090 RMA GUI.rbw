require 'tk'
require 'tkextlib/tile' #Advanced GUI
require_relative '../WinBoxes'
require_relative '../Engineering'

require_relative 'GUI/MC9090 RMA GUI.rb'
require_relative 'Scripts/MC9090 RMA.rb'


=begin
#Ocra command for tk:
#ocra "MC9090 RMA GUI.rbw" --windows C:\Ruby193\lib\tcltk\ --no-autoload --add-all-core
=end

$EngineerConsoleLink=""
$title='Waitrose MC9090/MC9091 GUI'

if defined?(Ocra)
  #Let Ocra pick up the encryption...
  testy = Crypt::Blowfish.new("1").encrypt_string("Moose")
  p testy
  #Webdriver...
  testy = Watir::Browser.new
  testy.close
  MechReporter.new
  exit 
end


begin #ErrorHandler

  GUI = MC9090RMA_Gui.new
  class RDT;def puts(*args);GUI.gui_puts(args.join($/));end;end
  GUI.run
  
  #ErrorHandler
  rescue #Report on any error and quit

  puts %Q|Fatal error occurred:\n#{$!}\n\nDebugging Information:\n#{$@}|,"Error" #Logfile output
  exit

  ensure #This will execute even after an error


end #ErrorHandler
