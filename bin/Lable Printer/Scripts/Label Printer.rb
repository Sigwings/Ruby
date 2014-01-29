include RegistryTools

class LabelGui
  include DateTools

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

    @lbl2.configure('text'=>str)
    Tk.update
    
	end
 
	# Let there be a printing of labels!
  def go_go_go
 
    Tk.update
 
    # Catch errors so the GUI doesn't just mysteriously disappear
    begin
    
      # Make sure they have a RDT username and password
      unless get_regkey_val('username') && get_regkey_val('password')
        return false unless ask_for_details( 'RDT Details:' )
      end
      
      puts
      gui_puts 'Please Wait'
      
      q = RDTQuery.new 'http://centrex.redetrack.com/redetrack/bin/report.php?report_locations_list=T&select_div_last_shown=&report_limit_to_top_locations=N&action=ordtrack&num=OR0000857779&num_raisedtrack=&status=999&pod=A&status_code=&itemtype=&location=&value_location=&tf=current&days=365&befaft=b&dd=09&mon=08&yyyy=2013&fdays=1&fbefaft=a&fdd=09&fmon=08&fyyyy=2013&ardd=09&armon=08&aryyyy=2012'
      q.set_dates( today )
      q[ 'status' ] = '' unless $cb # == true
      
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
        elsif k =~ /^CNTX|^NBC|^STK/i
        
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
      if $dp == false ? m.print_prompt( m.save_labels( keys, $rad ) ) : m.print_label( m.save_labels( keys, $rad ) ); end
      
      sleep 2
      
    # Catch and report errors
    rescue => e
      puts %Q|Fatal error occurred:\n#{$!}\n\nDebugging Information:\n#{$@.first}|,'Error' #Logfile output
      #error "#{ e.to_s.scan(/(.{1,200}\s?.{1,200}+)/).first.join($/) }\n\n#{ e.backtrace.first }"
      gui_puts 'Error!'
    else
      gui_puts 'Task Complete.'
    end
    
    # Quit
    #Gtk.main_quit
  end

  # Extract the contents of the Textbox into an array
  def get_key
    @textbox.get(1.0, 'end').split(/\s+/).reject( &:empty? )
  end
  # Update the label we're using to communicate with the user

  # Open log file in Notepad
  def open_log (filename)
    File.exist?( filename ) || File.write( filename, '' )
    Thread.new { system "notepad #{ filename }" }
  end
  
end
