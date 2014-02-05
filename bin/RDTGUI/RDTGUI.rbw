=begin
Version control:
0.1 it works, it's aliiiive!
0.2 getting and setting location in registry.
0.3 There can be only one!
0.4 remember other settings.
0.5 Sort XP incompatibility, reports askew.
0.6 Fixed PO&Line reporting, and the error reporting in the Report script. 
0.7 Optimised PO & Line report for speed by sorting the array and only searching for new PO numbers.
0.8 Sorted error from "BER Request", personalised title on start, cleaned up temp files.
0.9 Stopped "Use 'Data Entry' As List" from blanking the list in case of accidental button press; added "Remove Old Labels" option
1.0 Prevented pesky users from resizing the window, Added better feedback for Data validation, added BER job notes length check because of Phoenix.
1.1 Added more accurate feedback during operation and better error reporting on ignored errors. When an error is ignored the number will be dropped back into the data entry field
1.2 Made listbox autoscroll to show the current item
1.3 Added BER dropdown menu due to RDT update
1.4 Changed shortcut keys for menu options, altered dropdown box enable/disable code.
1.5 Added real-time title change when username is entered. Check for difference between list and data entry
1.6 Altered duplicate check to alter listbox and total
1.7 Sorted listbox and re-wrote to list.txt when sorting PO&Line input
1.8 Styled with windows colour scheme
1.9 Updated for RDT changes
2.0 Allowed macros to be used after opening excel
2.1 Added bugfix line for excel in XP
2.2 Altered page load timeout from 60 seconds to 5 minutes, auto-request warranty void if item is not marked as warranty.
2.3 Added autofocus to Data Entry on start
2.4 Added Supervisor console option
2.5 Added History Report option, fixed glitch caused by supervisor code which didn't highlight items green in engineer script.
2.6 Allowed for ISWare's bug in supervisor console which caused job numbers to always fail on the first request (Removed in update).
2.7 Added menu option to fill the notes field with preset values. 
2.8 When confirming BER, it will now use the last BER Request email notes rather than the given notes, if those notes are on the history.
2.9 Added Complete Report by INC for Ronnie
3.0 Split into multiple files, notes menu now changes comboboxes too.
3.1 Added check for completing a job in a queue. Fixed a quirk in finding the working directory after running from a shortcut.
3.2 Altered PO&Line report to account for RDT change.
3.3 Added ability to run reports and print labels with STK references.
3.4 Altered maximum script runtime for dealing with long JavaScript functions
3.5 Added block comments, gem list from working build, and contents of modified alert.rb
3.6 Now opens download directory in explorer when saving labels. Also added code to remove and cancel parts when requesting BER.
3.7 Disabled images to increase speed
3.8 Fixed a glitch caused by clicking a link in a hidden picture. Used fire_event("onclick") instead.
3.9 Added "Component Repair" as an engineer console option.
4.0 Updated the unallocate tool to dynamically find the MK workshop index and changed "b" to "o" to unallocate orders rather than individual barcodes (at Jon's recommendation)
=end

$title = "ReDeTrack Interface version 4.0"

#Require external libraries
require 'tk' #GUI
require 'tkextlib/tile' #Advanced GUI
require 'win32/registry' #Registry
require 'crypt/blowfish' #Encryption
require 'sys/proctable' #Process table
require 'watir-webdriver' #Browser
require 'nokogiri' #Parse HTML with speed
require 'win32ole' #For Excel handling
require 'win32/process' #Ability to launch separate process
require 'Win32API' #Backward compatibility with excel on XP
require_relative '../WinBoxes'
require_relative '../Engineering'
require_relative 'GUI/RDTGUI' #RDT GUI Class

#No longer an issue in latest webdriver?
#addressable version must be 2.2.8 or lower and libwebsocket 0.1.3 due to compatibility issues with ocra and webdriver
#win32-process must be 0.6.6 for compatibility with windows XP


=begin
#Ocra command for tk:
#ocra "RDTGUI.rbw" C:\Ruby193\lib\tcltk\ --no-autoload --add-all-core
=end


#Help XP work with excel
CoInitialize = Win32API.new('ole32', 'CoInitialize', 'P', 'L')

#Output log
$working_dir = Dir.pwd #Use the working directory
orig_std_out = STDOUT.clone #Make a record of the default console output to return to it later
$stdout.reopen($working_dir + "/Rubylog.txt", "w") #Create / overwrite logfile
$stdout.sync = true #Allow interception of console output
$stderr.reopen($stdout) #Pass errors to logfile

#There can be only one!
unless defined?(Ocra)
  begin 
    tried = false
    #Make a lockfile
    @@Highlander = File.open($working_dir + "/Highlander.dat","w")
  rescue
    #Oh no, there's already one there and it's hidden!
    if tried == true then raise "Error with lockfile" end #Don't get caught in a loop
    tried = true 
    File.delete($working_dir + "/Highlander.dat") #Get rid of the one left by a previous unexpected termination
    retry
  end
  #In order to hide the file from a console-less version of Ruby in Windows 7, you need to run a seperate console window.
  #Either that or dig around in APIs, which I can't be bothered to do.
  File.open($working_dir + "/Hideit.bat",'w') {|f| f.write("attrib +h Highlander.dat") }
  Process.create :app_name => $working_dir + "/Hideit.bat"
  sleep 1
  File.delete($working_dir + "/Hideit.bat")

  exit unless @@Highlander.flock( File::LOCK_NB | File::LOCK_EX ) #This ensures you can only run one instance of this (from the same location)
end

begin #errorhandler

#Exit if Ocra is building the program
  RDT.new
=begin  
  if defined?(Ocra)
    #Let Ocra pick up the encryption...
    testy = Crypt::Blowfish.new("1").encrypt_string("Moose")
    p testy
    #Webdriver...
    testy = Watir::Browser.new
    testy.close
    exit 
  end
=end


#Here's the trigger for the main application
RDTGUI.new.run

#ErrorHandler
rescue #Report on any error and quit

puts %Q|Fatal error occurred:\n#{$!}\n\nDebugging Information:\n#{$@}|,"Error" #Logfile output
exit

ensure #This will execute even after an error

puts "Quitting program"
@@driver.close rescue nil #Close browser at end of code, no matter what

unless defined?(Ocra)
  #Release and remove the lockfile
  @@Highlander.flock(File::LOCK_UN)
  @@Highlander.close
  File.delete(@@Highlander)
end
STDOUT.reopen(orig_std_out) #Restore output to console

end #errorhandler



#Regex true/false:
#unless warranty_state =~ /(?i)warranty/

#Regex to find numbers immediately after a hash symbol: 
#/(?<=#)\d+/

#How to control excel's macros from ruby:
#excel.run("PERSONAL.XLSB!DeleteBlankRows")

#Regex to find all the consonants
#str.scan(/[a-z&&[^aeiou]]/i)
