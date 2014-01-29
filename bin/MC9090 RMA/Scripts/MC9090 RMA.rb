require 'sys/proctable' #Process table

include RegistryTools

class MC9090RMA_Gui

  include WinBoxes
      
  def gui_puts(str)
   
    if str.length > @lbllength
      if str.length > 90
        lbllth = 30  
        @lbllength = 90
      else
        lbllth = (str.length - 15) / 3  
        @lbllength = str.length
        lbllength = str.length - 15
        if (lbllth.round * 3) < lbllength
          lbllength = lbllth.round * 3
        end
      end
      @lbl.configure('width'=> lbllength)
      @lbl2.configure('width'=> lbllength)
#      @butm.configure('width'=>lbllth.round - 1)
      @butl.configure('width'=>lbllth.round - 1)
      @butr.configure('width'=>lbllth.round - 1)
    end

    puts str

    @lbl2.configure('text'=>str)
    Tk.update
  end # End gui_puts
  
  def go_go_go

    return false if (@textbox.get(1.0, 'end').chomp.strip == '')
    
    cntx_rma_array = @textbox.get(1.0, 'end').split(/\n/).reject{ |el| el==''}.map { |line| line.split(/\s+/) }

    #check all entries have valid CNTX and RMA
    unless cntx_rma_array.all? { |array| Array === array && array.length == 2 && array[1] =~ /\A\d{7}\z/ && MechReporter.cntxify( array[0] ) rescue false }
      gui_puts 'Invalid input'
      errbox 'Invalid input'
      return false
    end
    
    #Count Firefox sessions
    pids = Sys::ProcTable.ps.map { |ps|
      if ps.name.downcase == 'firefox.exe'
      #Process.kill('KILL', ps.pid)
        ps.pid
      else
        nil
      end
    }.compact
      
    confirmationresult = true

    #Warn Firefox will be closed if open
    if pids.any? && engineering.nil?
  
      confirmMessage = "Warning: Any open Firefox sessions will be closed!\n\nDo you wish to Continue"

      confirmationresult = msgbox(confirmMessage,'Are you sure?',VBYESNO + VBQUESTION)

    end
      
    if confirmationresult == VBYES #then

      # Kill Firefox sessions
      if engineering.nil?
        pids.each { |pid| Process.kill('KILL', pid) }
      end
    
    end
    
    unless confirmationresult == VBNO

      self.engineering = Engineering.new( self ) if engineering.nil? || ( engineering.driver.title == 'waaaghhh' rescue true )
      
      engineering.ext_all_rma cntx_rma_array
      
      if engineering.errors.any?
        #puts engineering.errors
        msgbox engineering.errors.map { |cntx, rma| "#{cntx}\t#{rma}" }.join($/), 'Unable to Complete Jobs', VBSYSTEMMODAL
      end
      
      gui_puts 'Completed'
      #gui_puts 'Waiting for User Input...'
      
    end
    
  end

  #begin

  unless defined?(Ocra)
    #Output log
		orig_std_out = STDOUT.clone #Make a record of the default console output to return to it later
		logdir = documents_path + '\Ruby Logs'
		check_dir_path(logdir)
		$logfile = logdir + '\MC9090 RMA.log'
		$stdout.reopen($logfile, 'w') #Create / overwrite logfile
		$stdout.sync = true #Allow interception of console output
		$stderr.reopen($stdout) #Pass errors to logfile

  end


end

