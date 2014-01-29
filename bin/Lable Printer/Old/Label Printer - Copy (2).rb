require 'tk' # GUI
require_relative '../MechReporter' # Reporter and link to RubyExcel

#
# Graphical interface for MechReporter
#

class LableGui #< Gtk::Window
  include RegistryTools
  include DateTools

  # Build the GUI
  def initialize
    b = proc {bexit}
    go = proc {go_go_go}
    @lbllength = 50
    $rad = TkVariable.new('Centrex Lable')

    @text = TkVariable.new
 
 root = TkRoot.new do
      title 'Lable Printer'
      resizable(0, 0)
   end
 
 top = TkFrame.new(root).pack('fill'=>'both', 'expand'=>true)
    
    @butl=TkButton.new(top) do
      text 'Print'
#			command proc {go_go_go}
      command go
      width(23)
      height(2)
      grid('row' => 0, 'column' => 0, 'columnspan' => 2, 'sticky'=>'nsew')
    end
    
    @butm=TkButton.new(top) do
#      text 'Open Report'
      state 'disabled'
      width(23)
      height(2)
      command b
      grid('row' => 0, 'column' => 2, 'columnspan' => 2, 'sticky'=>'nsew')
    end

    @butr=TkButton.new(top) do
      text 'Close' 
      width(23)
      height(2)
      command { exit }
      grid('row' => 0, 'column' => 4, 'columnspan' => 2, 'sticky'=>'nsew')
    end

   @radl = TkRadiobutton.new(top) do
      text 'Centrex Lable'
#      height(2)
      grid('row' => 1, 'column' => 0, 'columnspan' => 2, 'sticky'=>'nsew')
      
      variable $rad; value 'Centrex Lable'
    end

   @radm = TkRadiobutton.new(top) do
      text 'Stock Lable'
#      height(2)
      grid('row' => 1, 'column' => 2, 'columnspan' => 2, 'sticky'=>'nsew')
      
      variable $rad; value 'Stock Lable'
   end

   @radr = TkRadiobutton.new(top) do
      text 'Repair Lable'
#      height(2)
      grid('row' => 1, 'column' => 4, 'columnspan' => 2, 'sticky'=>'nsew')
      
      variable $rad; value 'Repair Lable'
    end

		@CkhButton1 = TkCheckButton.new(top) do
			text "Return Lables Only"
#      height(2)
      grid('row' => 2, 'column' => 0, 'columnspan' => 2, 'sticky'=>'nsew')
		end

    @textbox = TkText.new(top) do
      width 18
      height 10
      borderwidth 1
      grid('row' => 3, 'column' => 2, 'columnspan' => 2, 'sticky'=>'nsew')
    end

    bar = TkScrollbar.new(top) do
      grid('row' => 3, 'column' => 3, 'sticky'=>'nse')
      command {|first, last| textbox.yview first, last}
    end

    @textbox.yscrollcommand {|first, last| bar.set(first, last)}

    @lbl = TkLabel.new(top) do
      text ' '
      height(1)
      grid('row' => 4, 'column' => 0, 'columnspan' => 6, 'sticky'=>'ew')
    end

    @lbl2 = TkLabel.new(top) do
      text 'Waiting for User Input...'
      borderwidth 1
      height(2)
      relief 'sunken' 
      grid('row' => 5, 'column' => 0, 'columnspan' => 6, 'sticky'=>'ew')
    end
 
    top.pack('fill'=>'both', 'side' =>'top')
  end
  
   # Display the GUI
  def run
    Tk.mainloop
  end
  
  def label_selected
    @label_radio.each_with_index { |b,i| return i+1 if b.active? }
  end
  
  # Let there be a printing of labels!
  def go_go_go_go
  
    # Catch errors so the GUI doesn't just mysteriously disappear
    begin
    
      # Make sure they have a RDT username and password
      unless get_regkey_val('username') && get_regkey_val('password')
        return false unless ask_for_details( 'RDT Details:' )
      end
      
      # Make sure there's a list.txt to use
      unless File.exist?( @filename )
        error 'Unable to find ' + @filename
        return false
      end
      
      gui_puts 'Please Wait'
      
      q = RDTQuery.new 'http://centrex.redetrack.com/redetrack/bin/report.php?report_locations_list=T&select_div_last_shown=&report_limit_to_top_locations=N&action=ordtrack&num=OR0000857779&num_raisedtrack=&status=999&pod=A&status_code=&itemtype=&location=&value_location=&tf=current&days=365&befaft=b&dd=09&mon=08&yyyy=2013&fdays=1&fbefaft=a&fdd=09&fmon=08&fyyyy=2013&ardd=09&armon=08&aryyyy=2012'
      q.set_dates( today )
      
      r = RDTQuery.new 'http://centrex.redetrack.com/redetrack/bin/report.php?report_locations_list=T&select_div_last_shown=&report_limit_to_top_locations=N&action=custordtrack&num=INC000000814606&num_raisedtrack=&status=&pod=A&status_code=&itemtype=&location=&value_location=&tf=current&days=365&befaft=b&dd=23&mon=08&yyyy=2013&fdays=1&fbefaft=a&fdd=23&fmon=08&fyyyy=2013&ardd=23&armon=08&aryyyy=2012'
      r.set_dates( today )
      
      s = RDTQuery.new 'http://centrex.redetrack.com/redetrack/bin/report.php?report_locations_list=T&select_div_last_shown=&report_limit_to_top_locations=N&action=stockstatus&num=325-333-814&num_raisedtrack=&status=&pod=A&status_code=&itemtype=&location=&value_location=&tf=current&days=365&befaft=b&dd=26&mon=10&yyyy=2013&timetype=any&fdays=1&fbefaft=a&fdd=26&fmon=10&fyyyy=2013&ardd=26&armon=10&aryyyy=2012'
      s.set_dates( today )
      
      # Let's do this thing!
      m = MechReporter.new
      
      # We're going to take our list of CNTX and OR numbers and only end up with CNTX numbers
      keys = get_key.map do |k|
        
        # If it's an OR number
        if k =~ /^OR/i
          
          # Look up the "Returns" against this Order
          q[ 'num' ] = k
          res = m.run( q )
          
          # If there's no result, map nil
          if res.maxrow == 1
            nil
            
          # If there's a result, map the OR into all the CNTX numbers.
          else
            res.ch( 'Bar Code' ).each_wh.to_a
          end
        
        elsif k =~ /^INC/i
          
          # Look up the "Returns" against this Order
          r[ 'num' ] = k
          res = m.run( r )
          
          # If there's no result, map nil
          if res.maxrow == 1
            nil

          # If there's a result, map the OR into all the CNTX numbers.
          else
            res.ch( 'Bar Code' ).each_wh.to_a
          end
        
        # If it's a CNTX or STK, leave it alone
        elsif k =~ /^CNTX|^STK/i
        
          k
 
        # If its a serial number
        else
          s[ 'num' ] = k
          res = m.run( s )
          if res.empty?
            nil
          else
            res.last_row.val('Bar Code')
          end
          #raise ArgumentError, 'Invalid CNTX / OR Number: ' + k
        end
        
      end.flatten.compact
      
      # Get the labels and open the print dialog
#      m.print_prompt( m.save_labels( keys, label_selected ) )
      m.print_label( m.save_labels( keys, label_selected ) )
      
      sleep 2
      
    # Catch and report errors
    rescue => e
      error "#{ e.to_s.scan(/(.{1,200}\s?.{1,200}+)/).first.join($/) }\n\n#{ e.backtrace.first }"
      gui_puts 'Error!'
    else
      gui_puts 'Task Complete.'
    end
    
    # Quit
    #Gtk.main_quit
  end

  # Open list.txt in Notepad
  def open_list
    File.exist?( @filename ) || File.write( @filename, '' )
    Thread.new { system "notepad #{ @filename }" }
  end
  
  # Filename for ( Documents / My Documents ) list.txt
  def get_filename
    Win32::Registry::HKEY_CURRENT_USER.open('SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders')['Personal'] + '\\labelGUI.txt'
  end
  
  # Extract the contents of list.txt into an array
  def get_key
    @textbox.get(1.0, 'end').split(/\s/).map{ |v| v.strip!; v.empty? ? nil : v }.compact
  end

=begin 
  # Report an error
  def error( msg )
    md = Gtk::MessageDialog.new( nil, Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::WARNING, Gtk::MessageDialog::BUTTONS_CLOSE, msg )
    md.signal_connect('response') { md.destroy }
    md.run
  end
  
 # Get input
  def ask_for_details( msg )
  
    # Create a standard dialog
    md = Gtk::Dialog.new( msg, nil, Gtk::Dialog::DESTROY_WITH_PARENT, [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_ACCEPT ], [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_REJECT] )

    # Ask for the username
    userlabel = Gtk::Label.new 'Username: '
    md.vbox.add userlabel
    username = Gtk::Entry.new
    md.vbox.add username
    
    # Ask for the password
    passlabel = Gtk::Label.new 'Password: '
    md.vbox.add passlabel
    password = Gtk::Entry.new
    password.visibility = false
    password.caps_lock_warning = true
    md.vbox.add password
    
    # Display the dialog
    md.show_all
    
    # Handle the response
    ret = false
    md.run do |response|
      if response == Gtk::Dialog::RESPONSE_ACCEPT
        set_regkey_val 'username', username.text
        set_regkey_val 'password', password.text
        ret = true
      else
      end
      md.destroy
    end
    
    # Return true if the user hit ok, false if they hit cancel
    ret
  end
=end

  # Update the label we're using to communicate with the user
  def gui_puts( str, internal=true )
    @msg = str if internal
    str = @msg + ' - ' + str unless internal

    if str.length > @lbllength
      lbllth = (str.length) / 3  
      @lbllength = str.length
      if (lbllth.round * 3) < @lbllength
        @lbllength = lbllth.round * 3
      end
#      @lbl.configure('width'=>@lbllength)
      @lbl2.configure('width'=>@lbllength)
      @butm.configure('width'=>lbllth.round - 1)
      @butl.configure('width'=>lbllth.round - 1)
      @butr.configure('width'=>lbllth.round - 1)
    end

    puts str
 #   @lbl.configure('text'=>@CkhButton1.get_value.to_s)
    @lbl.configure('text'=>@textbox.get(1.0, 'end').to_s)	#.chomp.strip)
		@textbox
    @lbl2.configure('text'=>str)

		end
 
#  def bexit(str)
  def bexit
  
    gui_puts 'Goodbye, Cruel World! 403333333332222222222222222222223344455556666777788888888888888888889999999999'
    
  end
  
  def go_go_go
  
    begin
      case $rad
        when 'Centrex Lable'
          gui_puts 'Centrex Lable'
        when 'Stock Lable'
          gui_puts 'Stock Lable'
        when 'Repair Lable'
          gui_puts 'Repair Lable'
      end
    end
    
  end
 
end

# Allows EXE builds without showing the GUI
MechReporter.new if defined?( Ocra )

# Let there be a GUI!
GUI = LableGui.new

# A bit of devious metaprogramming to pass through messages from the reporter
class MechReporter
  def puts( str )
    GUI.gui_puts str, false
  end
end

# Go!
GUI.run
#Tk.mainloop
