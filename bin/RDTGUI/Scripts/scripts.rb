class RDTGUI

  ###################################################################################################
  ###################################################################################################
  def startBrowserAndGotoLink(linkname)
    #linkname: String which identifies the RDT tool to use

    @user = getlink("username")
    @pass = getlink("password")
    if @user == false or @pass == false then setStatus "Unable to find username / password. Please click the 'RDT Details' button" ; return false end

    #Kill Firefox sessions to avoid errors
    begin #Ignore error (this command doesn't like XP unless it's in the main script)
    Sys::ProcTable.ps.each { |ps|
      if ps.name.downcase == "firefox.exe"
      Process.kill('KILL', ps.pid)
      end
    }
    rescue
      errorstring = "#{$!}".gsub("\n"," - ")
      puts "Error when trying to kill firefox: #{errorstring}"
    end
    
    #Set the download options for the current session
    #@download_directory = Dir.pwd
    @download_directory = $working_dir
    puts @download_directory
    @download_directory = "#{@download_directory}/RubyDownloads"
    @download_directory = @download_directory.gsub("/",%Q|\\|)

    puts @download_directory

    unless File.directory?(@download_directory)
      Dir::mkdir(@download_directory)
      puts "Created #{@download_directory}"
    end

    @profile = Selenium::WebDriver::Firefox::Profile.from_name 'default'
    @profile.native_events = false

    @profile['browser.download.folderList'] = 2 # custom location
    @profile['browser.download.dir'] = @download_directory
    @profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/pdf, application/x-pdf, application/x-download'
    @profile['browser.download.manager.showWhenStarting'] = false
    #@profile['dom.max_script_run_time'] = 0

    #Disable images to increase speed
    @profile['permissions.default.image'] = 2
    
    #Set Default timeout
    @client = Selenium::WebDriver::Remote::Http::Default.new
    @client.timeout = 300 # seconds – default is 60
    
    puts "Opening Firefox"
    #Open firefox with default profile (default avoids using multiple licences)  
    @@driver = Watir::Browser.new :firefox, :profile => @profile, :http_client => @client
    
    setStatus("Navigating to login page")
    @@driver.goto "http://centrex.redetrack.com/?action=logout"

    @@driver.text_field(:id => 'org').when_present.set "xtx957000033"
    @@driver.text_field(:id => 'password').when_present.set @pass
    @@driver.text_field(:id => 'username').when_present.set @user

    @@driver.button(:value => 'Login').click if @@driver.button(:value => 'Login').present?
    
    setStatus("Looking for #{linkname}")
    
    @@driver.button(:value => 'Logout').wait_until_present

    linkaddress = ''

    @@driver.div(:id => 'content').links.each do |linky|
      if linky.text != ""
        if linky.text == linkname
          splitarray = linky.attribute_value('onclick').split("'")
          linkaddress = "http://centrex.redetrack.com#{splitarray[1]}"
          puts "Found the link: #{linkaddress}"
          break linky
        end
      end
    end

    if linkaddress == '' then setStatus "#{linkname} not found" ; return false end

    @@driver.goto linkaddress
    @linkaddress = linkaddress
    
    return true

  rescue
    errorstring = "#{$!}".gsub("\n"," - ")
    setStatus "Error in startBrowserAndGotoLink module: #{errorstring}"
    return false
  end #end startBrowserAndGotoLink
  ###################################################################################################
  ###################################################################################################


  ###################################################################################################
  ###################################################################################################
  def gatherUserInput(type)
    if @ListBox.size == 0 then return false end
    
    #Colour everything in the list back to white
    @ListBox.size.times do |index|
      @ListBox.itemconfigure(index, :background => "white")
    end
    
    #Get the user's job list
    dataArray =  @ListBox.get(0,'end')
    
    #Check whether the data entry matches the listbox, in case they forgot to hit "use data entry" after changing the data
    teststring = dataArray.join("\n").upcase
    datastring = @TextField.get(1.0, 'end').chomp.strip.upcase
    
    if datastring != "" && datastring != teststring 
      result = Tk.messageBox(
        'type'    => "yesno",  
        'icon'    => "warning",
        'title'   => "Data Entry Mismatch",
        'message' => "Data Entry doesn't match List, are you sure you want to continue?",
        'default' => "yes"
      )
      
      puts "Continue on Data Entry Mismatch? #{result}"
      
      if result == "no" then return false end
      
    end
    
    if type == 1 #If it's a list of CNTX numbers
      puts "Expecting CNTX numbers"
      dataArray.each do |cntx| #Loop through all the numbers
        puts "looping with #{cntx}"
        if cntx.length.between?(0, 5)
          puts "#{cntx} invalid"
          @ListBox.itemconfigure(dataArray.index(cntx), :background => "red")
          return false
        elsif cntx.length.between?(6, 10)
          #Make it a properly formatted CNTX number
          puts "#{cntx} is invalid length"
          newcntx = (sprintf '%010i', cntx).to_s
          newcntx = "CNTX#{newcntx}"
          cntx.replace(newcntx)
          puts "changed to #{newcntx}"
        elsif cntx.length.between?(11,13)
          if cntx.length != 11
            unless cntx =~ /STK/i
              @ListBox.itemconfigure(dataArray.index(cntx), :background => "red")
              return false
            end
          end
        elsif cntx.length == 14
          puts "#{cntx} validated"
        else
          puts "#{cntx} invalid"
          @ListBox.itemconfigure(dataArray.index(cntx), :background => "red")
          return false
        end
      end
    elsif @TypeCode.value == "PO & Line Report"
      dataArray.each do |poline|
        unless poline.upcase.include?("L")
          puts "PO and line number must be seperated by an 'L'"
          @ListBox.itemconfigure(dataArray.index(cntx), :background => "red")
          return false
        end
      end
    end
    puts "Using this list:"
    puts dataArray
    
    return dataArray
  end #End gatherUserInput
  ###################################################################################################
  ###################################################################################################


  ###################################################################################################
  ###################################################################################################  
  def engineerConsoleScript(inputconsole,jobsToProcess,location,statusvar,reasonvar,slavar,bervar,notestext)

    def definePartNumbers
      
      @@partsarray = ["EXTERNAL-BYBOX (External Repair Via By-Box)", "EXTERNAL-INGENICO (External Repair Via Ingenico)", "EXTERNAL-VERIFONE (External Repair Via Verifone)", "XXX-BOX-PHX (Various Box)"]
      @@pnarray = ["EXTERNAL-BYBOX", "EXTERNAL-INGENICO", "EXTERNAL-VERIFONE", "XXX-BOX-PHX"]
      
    end #End DefinePartNumbers def

    def linkPartNumberToPart(celltext,statusvar)

      unless statusvar == "Box Uplift"

        celltext = celltext[(celltext.index('Item: ',1)+6)..(celltext.index('Fault:',1)-2)].upcase
        puts "Part number is: #{celltext}"

        if celltext.include?("SCRING3300A")
          extreptype = "EXTERNAL-INGENICO"
        elsif celltext.include?("SECRA")
          extreptype = "EXTERNAL-VERIFONE"
        elsif celltext.include?("COM-SCA-00001")
          extreptype = "EXTERNAL-VERIFONE"
        else
          extreptype = false
        end #End part number to external repairer match
      
      else
        extreptype = "XXX-BOX-PHX"
      end #end box-only deviation
        
        unless extreptype == false then "External repair type is: " + extreptype end
        
        if extreptype != false
          arrayindex = @@pnarray.index(extreptype)
          p arrayindex
        else
          puts "No suitable external repairer found"
        end
          
        if extreptype == false
          return nil
        else
          return arrayindex
        end #End return value deviation

    end

    #--------------------------------
    #Begin user-options sequence

    if notestext == "Job Notes" then notestext = "" end
    if statusvar == "Box Uplift" then notestext = "Box" end
    
    definePartNumbers

    #puts "Parts Array: #{@@partsarray}"
    #puts "Part Number Array: #{@@pnarray}"
    
    counter = 1
    errorcount = 0
    
    #Difference in "BER Request Email" options:
    if statusvar == "BER Request Email"
      bervar = bervar.gsub(" - BER","R - BER")
    end

    firsttime = true
    
    #Begin looping through jobs
    jobsToProcess.each_with_index do |cntx, index|

      setStatus("Processing item #{index+1} of #{jobsToProcess.length} with #{errorcount} errors")
      @ListBox.see index
      
      puts "Looping with #{cntx}"

      unless firsttime == true #Avoid double-refreshing the engineer console the first time through
        
        puts "Force page refresh by going to blank page"
        @@driver.goto "about:blank" rescue puts "Rescued error on about:blank"
        
        puts "Navigating to engineer console"
        @@driver.goto "#{inputconsole}"
        
      end #End firsttime check

      firsttime = false
      
      #Look for webpage
      puts "Loading engineer console and waiting for table to appear"
      unless @Supervisor.value == '1'
        @@driver.table(:class => 'jobstable').wait_until_present(2) rescue puts "No jobs found in jobs table, attempting to continue."
      else
        @@driver.div(:id => 'jobsarea').wait_until_present
      end
      
      puts "Looking for cntx"
      
      updateProgBar((counter.quo(jobsToProcess.size)*100)-1)
      counter += 1

      #Split for Supervisor Console allocation
      unless @Supervisor.value == '1'
      
        #Only allocate if not already allocated
        unless @@driver.table(:id => 'jobstable').td(:text => cntx).exists?
          puts 'Unable to locate job in table, attempting to allocate.'
          @@driver.button(:id, 'getJob').when_present.click
          puts "Waiting for allocation screen"
          @@driver.table(:class => 'unallocatedjobs').wait_until_present
          
          puts "Clicking the link for #{cntx} in unallocated list"
          
          begin #Trap jobs that don't show up in the unallocated list
            @@driver.table(:class => 'unallocatedjobs').td(:text, cntx).parent.button(:index,0).click
          rescue
            if @IgnoreErrors.value.to_i != 1
              raise "Unable to locate #{cntx} in unallocated jobs list"
            else
              @ListBox.itemconfigure(jobsToProcess.index(cntx), :background => "red")
              if @ErrorFlag == 0 then @TextField.delete(1.0,'end') end
              @ErrorFlag = 1
              errorcount += 1
              puts "Unable to locate #{cntx} in unallocated jobs list. Error ignored."
              @CurrentError = "Unable to locate job in unallocated list."
              @ErrorList.push("#{cntx} - #{@CurrentError}")
              @TextField.insert 'end', "#{cntx}\n"
              next #next cntx number in jobs loop
            end
          end
          
          puts "Bypassing confirm message"  
          @@driver.alert.ok
          @@driver.alert.close
          
          puts "Waiting for the job to appear in the jobs table"
          @@driver.table(:class => 'jobstable').td(:text => cntx).wait_until_present
          
        end   #End allocate unless present
        
        puts "Clicking the link for #{cntx}"
        @@driver.table(:id => 'jobstable').td(:text => cntx).parent.links.first.fire_event("onclick")
        
      else #If the Supervisor Console is selected
              
        @@driver.text_field(:name => 'barcode').when_present.set cntx
        
        @@driver.button(:value => 'Get Job').when_present.click
        
        puts "Waiting for error message"
        tempvar = Time.now
        if @@driver.alert.exists?(0.5)

          unless @IgnoreErrors.value.to_i == 1
            raise "Unable to allocate"
          else
            @ListBox.itemconfigure(jobsToProcess.index(cntx), :background => "red")
            if @ErrorFlag == 0 then @TextField.delete(1.0,'end') end
            @ErrorFlag = 1
            errorcount += 1
            puts "Unable to allocate. Error ignored."
            @CurrentError = "Unable to allocate."
            @ErrorList.push("#{cntx} - #{@CurrentError}")
            @TextField.insert 'end', "#{cntx}\n"
            @@driver.alert.close
            next #next cntx number in jobs loop
          end #Catch non-existent CNTX errors
        end #End error message check
        puts "Finished waiting #{Time.now-tempvar} seconds for error message"
      
      end #End Supervisor allocation deviation
      
      if statusvar == "Allocate Only" #Don't do anything else if the user chose to simply allocate the job
        puts "Completed #{cntx}"
        @ListBox.itemconfigure(jobsToProcess.index(cntx), :background => "green")
        next
      end
      
      begin #Watch out for warranty window
        puts "Checking for warranty window"
        tempvar = Time.now
        @@driver.div(:id => 'WarrantyWindow').wait_until_present(1)
        unless @IgnoreErrors.value.to_i == 1
          raise "Item triggered warranty window"
        else
          @ListBox.itemconfigure(jobsToProcess.index(cntx), :background => "red")
          if @ErrorFlag == 0 then @TextField.delete(1.0,'end') end
          @ErrorFlag = 1
          errorcount += 1
          puts "Item triggered warranty window. Error ignored."
          @CurrentError = "Item triggered warranty window."
          @ErrorList.push("#{cntx} - #{@CurrentError}")
          @TextField.insert 'end', "#{cntx}\n"
          
          #Request void if it isn't marked as warranty
          unless @@driver.table(:class => 'jobstable').td(:text, cntx).parent.td(:text,/(?i)warranty/).exists?
            puts "No 'Warranty' note found, requesting warranty void for #{cntx}."
            @@driver.div(:id => 'WarrantyWindow').text_field(:id => 'warrantycomment').set "Not warranty"
            @@driver.div(:id => 'WarrantyWindow').button(:value => 'Void Warranty Repair').click
          end
          
          next #next cntx number in jobs loop
        end
      rescue "Item triggered warranty window" #Hand a specific raised error to the next errorhandler up
        raise "Item triggered warranty window"
      rescue Watir::Wait::TimeoutError => error #Couldn't find warranty window, carry on.
        puts "Rescued expected error: #{error.class}\n#{error.message}"
        puts "Finished waiting #{Time.now-tempvar} seconds for warranty window"
        #Continue if it doesn't appear
      rescue => error  #Hand an unhandled error to the next errorhandler up
        puts "Rescued unexpected error: #{error.class}\n#{error.message}\n#{error.backtrace.first}"
        raise error
      end

      @@driver.div(:class => 'currentjob', :text => /#{cntx}/).wait_until_present
      
      #Start work
      if @@driver.div(:class => 'currentjob').button(:value => 'Start Work').present? && @Supervisor.value != '1' then @@driver.div(:class => 'currentjob').button(:value => 'Start Work').click end
      
      puts "Check for external repair option"
      if statusvar == "On Hold - External Repair" or statusvar == "Box Uplift"
        
        @celltext = @@driver.div(:class => 'currentjob').text
        
        @arrayindex = linkPartNumberToPart(@celltext,statusvar)
        
        unless @arrayindex.nil?
          puts "Part number linked to external repairer: " + @@pnarray[@arrayindex]
        else
          puts "No external repairer found."
        end
        
        unless @arrayindex.nil?
          @@ifchecker = @@driver.table(:class => 'stockalltable').td(:text => @@pnarray[@arrayindex] + ":").present?
          puts "Looking for " + @@pnarray[@arrayindex] + ":"
          puts "Part already assigned? #{@@ifchecker}"
          
          unless @@ifchecker == true
            @@driver.input(:id => 'searchStockBox_component').send_keys @@pnarray[@arrayindex]
            @@driver.div(:class => 'hiddenfilterselectordiv').select_list(:class => 'hiddenfilterselector').select @@partsarray[@arrayindex]
                      
            @@driver.div(:id => 'componentpart').input(:value => 'Search Stock').click
            
            if location == "MK"
              @@driver.div(:id => 'rightarea').div(:id => 'stocksearch_div').div(:id => 'stockresults').table(:class => 'stocktable').td(:text => 'MK Repair Component Goods In:').wait_until_present
            else
              @@driver.div(:id => 'rightarea').div(:id => 'stocksearch_div').div(:id => 'stockresults').table(:class => 'stocktable').td(:text => 'Ashington Spares:').wait_until_present
            end
            
            @@driver.tr(:class => 'stock_row').parent.links.first.fire_event("onclick")
            @@driver.alert.set('1') #Return '1' to the prompt box
            @@driver.alert.ok #Confirm 1
            @@driver.alert.close #Close "part allocated" message
            
            puts "waiting for part to be allocated"
            @@driver.table(:class => 'stockalltable').td(:text => "#{@@pnarray[@arrayindex]}:").wait_until_present
                            
            puts "Assigned part to job: #{@@pnarray[@arrayindex]}"
            
          end #End part allocated check
        end #End part check
      end #End ext rep check
      
    #If it's a BER Request Email we'll need to remove all the parts first.
    if statusvar == "BER Request Email"
      #Unallocate all the parts before requesting BER
      while @@driver.img(:title => 'Unconsume Part').exist?
        puts "Found part attached to job, removing."
        @@driver.tr(:class => 'alstock_row').parent.links.first.fire_event("onclick")
        @@driver.alert.ok
        sleep 1
      end
      #Cancel ordered parts before requesting BER
      while @@driver.img(:title => 'Cancel Stock Request').exist?
        puts "Found part attached to job, removing."
        @@driver.tr(:class => 'alstock_row').parent.links.first.fire_event("onclick")
        @@driver.alert.ok
        sleep 1
      end
    end #End if BER Request
      
      if statusvar == "Box Uplift" then 
        @@driver.select_list(:id => 'status').when_present.select("Uplift Request Email")
        puts "Setting status as Uplift Request Email"
      else  
        @@driver.select_list(:id => 'status').when_present.select(statusvar)
        puts "Setting status as #{statusvar}"
      end
      
      if statusvar == "Beyond Economical Repair" && @@driver.div(:id => "historyarea").table(:index => 0).td(:text => "BER Request Email").exists?
        
        ber_request_notes = @@driver.div(:id => "historyarea").table(:index => 0).tds(:text => "BER Request Email").last.parent.div(:index => 0).text
        @@driver.text_field(:id,'tnotes').when_present.set(ber_request_notes)
        puts "Setting notes as #{ber_request_notes}"
      
      else #If it's anything other than BER...
      
        @@driver.text_field(:id,'tnotes').when_present.set(notestext)
        puts "Setting notes as #{notestext}"
        
      end #End BER notes deviation
      
      #"Repair Complete" causes suboptions to appear, deal with these
      if statusvar == "Repair Complete"
        
        @@driver.select_list(:id => 'repcode').when_present.select(reasonvar)
        puts "Setting reason as #{reasonvar}"
        
        #Look for SLA code and provide if required
        if @@driver.select_list(:id => 'slacode').present?
          @@driver.select_list(:id => 'slacode').select(slavar)
          puts "Setting SLA as #{slavar}"
        end #End "SLA code" option

      end #End "Repair Complete" deviation

      if statusvar == "Beyond Economical Repair"
      
        @@driver.select_list(:id => 'bercode').when_present.select(bervar)
        puts "Setting BER reason as #{bervar}"
        
      elsif @StatusCode.value == "BER Request Email"
      
        @@driver.select_list(:id => 'berraisecode').when_present.select(bervar)
        puts "Setting BER reason as #{bervar}"
      
      end #End "Beyond Economical Repair" / BER Request deviation

      @@driver.button(:id, 'submit').click
      case statusvar 
      when "Returned at Customers Request" , "Beyond Economical Repair", "Repair Complete"
        
        #Deal with the initial "Are you sure" message
        puts "Confirming #{statusvar}"
        @@driver.alert.ok
        
        #Look out for error message:
        puts "Waiting for response message after job completion."
        if @@driver.alert.exists?(10)
        
          #Catch common failure message. 
          unless @@driver.alert.text.include?("Job Closed")
            
            #Raise or handle, depending on user setting.
            unless @IgnoreErrors.value.to_i == 1
              raise "Unable to close #{cntx}. Item is on a queue."
            else
              @ListBox.itemconfigure(jobsToProcess.index(cntx), :background => "red")
              if @ErrorFlag == 0 then @TextField.delete(1.0,'end') end
              @ErrorFlag = 1
              errorcount += 1
              puts "Item is on a queue. Unable to complete job. Error ignored."
              @CurrentError = "Item is on a queue."
              @ErrorList.push("#{cntx} - #{@CurrentError}")
              @TextField.insert 'end', "#{cntx}\n"
              @@driver.alert.close
              next #next cntx number in jobs loop
            end #End ignore errors check
          else
            #All looks ok, carry on.
            @@driver.alert.close
          end #End catch jobs still in queues
        else
          raise "Timed out waiting for success / failure message."
        end
      when "Uplift Request Email"
        if @@driver.alert.exists?(2)
          #Catch common failure message. 
          if @@driver.alert.text.include?("Not Sent") || @@driver.alert.text.include?("On Void Warranty Queue")
            
            #Raise or handle, depending on user setting.
            unless @IgnoreErrors.value.to_i == 1
              raise "Unable to uplift #{cntx}. Item is on a queue."
            else
              @ListBox.itemconfigure(jobsToProcess.index(cntx), :background => "red")
              if @ErrorFlag == 0 then @TextField.delete(1.0,'end') end
              @ErrorFlag = 1
              errorcount += 1
              puts "Item is on a queue. Unable to uplift job. Error ignored."
              @CurrentError = "Item is on a queue."
              @ErrorList.push("#{cntx} - #{@CurrentError}")
              @TextField.insert 'end', "#{cntx}\n"
              @@driver.alert.close
              next #next cntx number in jobs loop
            end #End ignore errors check
          else
            #All looks ok, carry on.
            @@driver.alert.close
          end #End catch jobs still in queues
        else
          raise "Timed out waiting for success / failure message."
        end
      when "BER Request Email"
        if @@driver.alert.exists?(1)
          #Catch common failure message. 
          if @@driver.alert.text.include?("Not Sent") || @@driver.alert.text.include?("On Void Warranty Queue")
            
            #Raise or handle, depending on user setting.
            unless @IgnoreErrors.value.to_i == 1
              raise "Unable to uplift #{cntx}. Item is on a queue."
            else
              @ListBox.itemconfigure(jobsToProcess.index(cntx), :background => "red")
              if @ErrorFlag == 0 then @TextField.delete(1.0,'end') end
              @ErrorFlag = 1
              errorcount += 1
              puts "Item is on a queue. Unable to uplift job. Error ignored."
              @CurrentError = "Item is on a queue."
              @ErrorList.push("#{cntx} - #{@CurrentError}")
              @TextField.insert 'end', "#{cntx}\n"
              @@driver.alert.close
              next #next cntx number in jobs loop
            end #End ignore errors check
          else
            #All looks ok, carry on.
            @@driver.alert.close
          end #End catch jobs still in queues
        else
          #This option doesn't currently give a success message, if there isn't one carry on as normal.
          #raise "Timed out waiting for success / failure message."
        end
      end
      
      puts "Completed #{cntx}"
      @ListBox.itemconfigure(jobsToProcess.index(cntx), :background => "green")
      
      sleep 0.5
      
    end #Loop for the next cntx
    
    Tk.update

    return true
    
  #ErrorHandler
  rescue #Report on any error and quit
    errorstring = "#{$!}".gsub("\n"," - ")
    puts %Q|Fatal error occurred:\n#{$!}\n\nDebugging Information:\n#{$@.first}|,"Error" #Logfile output
    setStatus "Fatal error. #{errorstring}"
    return false

  end #End engineerConsoleScript
  ###################################################################################################
  ###################################################################################################


  ###################################################################################################
  ###################################################################################################
  def reportingScript(inputconsole,jobsToProcess,typevar,detailvar)

    File.open("ReportOutput.txt","w") {|reportfile| reportfile.write('') } #Overwrite old output file with blank data


    if typevar == "PO & Line Report"
      result = po_and_line_report(inputconsole,jobsToProcess,typevar,detailvar)
      return result
    end

    @firsttime = true
    
    progCounter = 1
    
    jobsToProcess.each do |jobref|
    
      setStatus("Processing item #{progCounter} of #{jobsToProcess.length} with 0 errors")
      @ListBox.see progCounter
    
      oldjobref = ''
      #puts "Progressbar calculation: (#{progCounter} / #{jobsToProcess.size} * 100) - 1"
      puts "looping with jobref: #{jobref}"
    
      @@driver.select_list(:id => 'days').when_present(180).select("1 year")
      
      case typevar
      
      when "Report by CNTX"
        @@driver.text_field(:id => 'num').when_present.set(jobref)
      when "Report by Serial"
        @@driver.select_list(:id => 'trackselect').when_present.select("Serial Number")
        @@driver.text_field(:id => 'num').when_present.set(jobref)
      when "Workshop Report by CNTX"
        @@driver.select_list(:id => 'berhandle').when_present.select("are always shown")
        @@driver.text_field(:name => 'barcode').when_present.set(jobref)
      when "Workshop Report by Serial"
        @@driver.select_list(:id => 'reptype').when_present.select("Serial Number Report")
        @@driver.select_list(:id => 'berhandle').when_present.select("are always shown")
        @@driver.text_field(:name => 'serial').when_present.set(jobref)
      when "PO Report"
        @@driver.select_list(:id => 'berhandle').when_present.select("are always shown")
        @@driver.text_field(:name => 'custordref').when_present.set(jobref)
      when "History Report by CNTX"
        @@driver.select_list(:id => 'reptype').when_present.select("History Report")
        @@driver.select_list(:id => 'berhandle').when_present.select("are always shown")
        @@driver.text_field(:name => 'barcode').when_present.set(jobref)
      when "History Report by Serial"
        @@driver.select_list(:id => 'reptype').when_present.select("History Report")
        @@driver.select_list(:id => 'berhandle').when_present.select("are always shown")
        @@driver.text_field(:name => 'serial').when_present.set(jobref)
      when "Complete Report by INC"
        @@driver.text_field(:name => 'custordref').when_present.set(jobref)
        @@driver.select_list(:name => 'status').when_present.select("Repair Complete")
      when "PO & Line Report"
        @@driver.select_list(:id => 'berhandle').when_present.select("are always shown")
        line = jobref.slice(7..(jobref.length))
        po = jobref.slice(0..5)
        puts "PO: #{po} Line: #{line}"
        @@driver.text_field(:name => 'custordref').when_present.set(po)
        oldjobref = jobref.to_s
        jobref = po
      else
        puts "Invalid report type"
        return false
      end #end typevar case
      
      if inputconsole.downcase.include?("centrexticketreport") && detailvar.include?("With Unallocated")
        @@driver.checkbox(:id => 'includeuaj').when_present.set
      end
      
      if inputconsole.downcase.include?("centrexticketreport") && detailvar.include?("Single") && typevar != "Complete Report by INC"
        @@driver.checkbox(:id => 'groupbyjob').when_present.set
      elsif inputconsole.downcase.include?("centrexticketreport") && detailvar.include?("Full")
        @@driver.checkbox(:id => 'groupbyjob').when_present.clear
      elsif !(inputconsole.downcase.include?("centrexticketreport")) && detailvar.include?("Full")
        @@driver.checkbox(:id => "history").when_present.set
      end
      
      #puts "Waiting for search button to appear"
      @@driver.button(:value, 'Search').click
      
      puts "loading report table for job ref: #{jobref}"
      @@driver.table(:id => 'reporttable').wait_until_present(300)
      
      tableHTML = @@driver.table(:id => 'reporttable').html
      
      doc = Nokogiri::HTML(tableHTML)
      
      currentTableData = ''
      
      found = false
      
      updateProgBar((progCounter.quo(jobsToProcess.size)*100)-1)
      progCounter +=1
      
      doc.css('table[@id="reporttable"] tr').each do |row|
        counter = 0
        row.css('th').each do |cell|
          if @firsttime
            counter += 1
            if counter > 3 || inputconsole.downcase.include?("centrexticketreport")
              currentTableData = "#{currentTableData}#{cell.text.gsub(/\t/,'').gsub(/\n/,'')}\t"
            end #end counter check
          end #end firsttime check
        end #End header loop
        
        if row.text.include?(jobref)
          row.css('td').each do |cell|
            if tableHTML.include?(jobref)
              currentTableData = "#{currentTableData}#{cell.text.gsub(/\t/,'').gsub(/\n/,'')}\t"
            end #end jobref check
          end #end cell loop
        end #end line check
        
        if row.text.include?(jobref) || @firsttime == true
          found = true
          unless currentTableData.gsub(/\t/,'') == '' then currentTableData = "#{currentTableData.chomp}\n" end
        end
        
        if @firsttime then @firsttime = false; found = false end
        
      end #End table row loop
      
        if tableHTML.include?(jobref)
          found = true
        end
      
      unless found
      
        currentTableData = currentTableData + jobref + "\tNot Found" + "\n"
          
        @ListBox.itemconfigure(jobsToProcess.index(jobref), :background => "red")
        
      else
      
        @ListBox.itemconfigure(jobsToProcess.index(jobref), :background => "green")
        
      end #end unless found

      File.open("ReportOutput.txt","a") {|reportfile| reportfile.write(currentTableData) } #append the data into report file
      currentTableData = ''
      
    end #end jobsToProcess loop
    
    Tk.update

  @@driver.close

  #Open the report in excel
  setStatus("Opening report in Excel...")
  currentdir = Dir.pwd
  filename = currentdir + "\\ReportOutput.txt"
  CoInitialize.call( 0 )
  excel = WIN32OLE::new("excel.application")
  personal = "#{Dir.home.gsub("/","\\")}\\AppData\\Roaming\\Microsoft\\Excel\\XLSTART\\PERSONAL.XLSB"
  if File.exists?(personal) then excel.Workbooks.Open(personal) rescue nil end #Personal workbook for macros  
  excel.Workbooks.Open(filename)
  excel.visible = true

  return true

  rescue
    errorstring = "#{$!}".gsub("\n"," - ")
    puts %Q|Fatal error occurred:\n#{$!}\n\nDebugging Information:\n#{$@.first}|,"Error" #Logfile output
    setStatus "Fatal error. #{errorstring}"
    return false
  end #End reporting script
  ###################################################################################################
  ###################################################################################################


  ###################################################################################################
  ###################################################################################################
  def unallocateScript(inputconsole,jobsToProcess,location)

=begin
  if location == "Ashington"
      locncode = 0 
    else
      locncode = @@driver.spans.collect(&:text).index ( @@driver.span( :text => /Centrex Computing Services/ ) ).text
    end
=end
	locncode = 1
    counter = 1
    errorcount = 0

    #Begin looping through jobs
    jobsToProcess.each_with_index do |cntx, index|
    
      setStatus("Processing item #{index+1} of #{jobsToProcess.length} with #{errorcount} errors")
      @ListBox.see index

      puts "Looping with #{cntx}"

      puts "Force page refresh by going to blank page"
      @@driver.goto "about:blank"
      
      puts "Navigating to allocation console"
      @@driver.goto inputconsole

      puts "Waiting for page to load"
      @@driver.div(:class => 'droptool').wait_until_present
      
      @retry = true
      
      updateProgBar((counter.quo(jobsToProcess.size)*100)-1)
      counter +=1
      
      begin
        
        puts "executing script command with #{cntx}"
        @@driver.execute_script("unassignBarcode_action('#{locncode}','#{cntx}','o',0);")
        @ListBox.itemconfigure(jobsToProcess.index(cntx), :background => "green")
      rescue 
        if @retry
          sleep 1
          @retry = false
          puts "Error encountered: #{$!}"
          retry
        else
          unless @IgnoreErrors.value.to_i == 1
            raise "Failed to execute unallocate script twice in a row." 
          else
            @ListBox.itemconfigure(jobsToProcess.index(cntx), :background => "red")
            if @ErrorFlag == 0 then @TextField.delete(1.0,'end') end
            @ErrorFlag = 1
            errorcount += 1
            @TextField.insert 'end', "#{cntx}\n"
            puts "Unable to unallocate #{cntx}. Error ignored."            
            @CurrentError = "Unable to unallocate."
            @ErrorList.push("#{cntx} - #{@CurrentError}")
          end
        end
        sleep 1
      end
    
    end #Loop next cntx

    Tk.update

    @@driver.close
    return true
  rescue
    errorstring = "#{$!}".gsub("\n"," - ")
    puts %Q|Fatal error occurred:\n#{$!}\n\nDebugging Information:\n#{$@.first}|,"Error" #Logfile output
    setStatus "Fatal error. #{errorstring}"
    return false
  end
  ###################################################################################################
  ###################################################################################################

  def waitForDownload
    
    #Find the newest file
    difference = [1,2]
    until difference.size == 1
      difference = Dir.entries(@download_directory) - @current_downloads
      sleep 0.5
    end
    file_name = difference.first
    puts "Found new file: #{file_name}"
    
    new_size = 0
    current_size = -1
    
    #Wait for file size to stop changing
    until current_size == new_size
      current_size = File.size("#{@download_directory}\\#{file_name}")
      puts "current file size: #{current_size}"
      sleep 0.5
      new_size = File.size("#{@download_directory}\\#{file_name}")
      puts "new file size: #{new_size}"
      sleep 0.5
    end
    
  end


  ###################################################################################################
  ###################################################################################################
  def printLabelsScript(inputconsole,jobsToProcess)
    
    if @RemoveOldLabels.value.to_i == 1
      puts "Remove Old Labels selected, deleting older labels"
      Dir["#{@download_directory.gsub("\\","/")}/*.pdf"].each {|f| puts "#{f} Deleted"; File.delete(f) }
    end
    
    counter = 1

    jobsToProcess.each_with_index do |cntx, index|   
    
      @current_downloads = Dir.entries @download_directory      
      
      setStatus("Processing item #{index+1} of #{jobsToProcess.length} with 0 errors")
      @ListBox.see index

      puts "Looping with #{cntx}"  
      
      @@driver.select_list(:id => 'days').when_present.select("1 year")
      
      @@driver.text_field(:id => 'num').when_present.set(cntx)
      
      @@driver.button(:id, 'mainsearchbutton').when_present.click
      
      puts "Waiting for #{cntx} to appear"
        
      @@driver.table(:id => 'reporttable').td(:text => cntx).wait_until_present(90)
      
      @@driver.table(:id => 'reporttable').checkbox(:value => cntx).when_present.set

      puts "selecting label type"
      
      unless cntx =~ /STK/i
        @@driver.select_list(:name => 'print_link').when_present.select("repair label")
      else
        @@driver.select_list(:name => 'print_link').when_present.select("stock label")
      end
      puts "Clicking print"
      @@driver.button(:value => 'Print Checked').when_present.click
      @@driver.alert.close
      @@driver.button(:id, 'mainsearchbutton').wait_until_present(90)
      
      updateProgBar((counter.quo(jobsToProcess.size)*100)-1)
      counter +=1 
      
      puts "Waiting for download to complete"
        
      waitForDownload
      
      puts "Finished waiting for download"
      
      @ListBox.itemconfigure(jobsToProcess.index(cntx), :background => "green")
      
    end #Loop next cntx
    
    system("start #{@download_directory}")
    
    Tk.update

    @@driver.close
    return true
  rescue
    errorstring = "#{$!}".gsub("\n"," - ")
    puts %Q|Fatal error occurred:\n#{$!}\n\nDebugging Information:\n#{$@.first}|,"Error" #Logfile output
    setStatus "Fatal error. #{errorstring}"
    return false
  end
  ###################################################################################################
  ###################################################################################################

  def po_and_line_report(inputconsole,jobsToProcess,typevar,detailvar)

    File.open("ReportOutput.txt","w") {|reportfile| reportfile.write('') } #Overwrite old output file with blank data

    @firsttime = true
    
    progCounter = 1
    
    #puts "Array before sorting: #{jobsToProcess}"
    
    jobsToProcess.sort!
    
    #puts "Array after sorting: #{jobsToProcess}"
    
    #Write the sorted array back into the listbox and list.txt
    @ListBox.delete(0,'end')
    jobsToProcess.each{|i| @ListBox.insert 'end', i}
    File.open("list.txt","w") {|listfile| listfile.write(jobsToProcess.join("\n")) }
    
    previousPO = 0
    
    jobsToProcess.each do |jobref|
    
      setStatus("Processing item #{progCounter} of #{jobsToProcess.length} with 0 errors")
      @ListBox.see progCounter
    
      oldjobref = ''
      puts "looping with jobref: #{jobref}"
    
      @@driver.select_list(:id => 'days').when_present(300).select("1 year")
      @@driver.checkbox(:id => 'includeuaj').set if detailvar.include?("With Unallocated")

      @@driver.select_list(:id => 'berhandle').when_present.select("are always shown")
      line = jobref.slice(7..(jobref.length))
      po = jobref.slice(0..5)
      puts "PO: #{po} Line: #{line}"
      @@driver.text_field(:name => 'custordref').when_present.set(po)
      oldjobref = jobref.to_s
      jobref = po
      
      if inputconsole.downcase.include?("centrexticketreport") && detailvar.include?("With Unallocated")
        @@driver.checkbox(:id => 'includeuaj').when_present.set
      end
      
      if inputconsole.downcase.include?("centrexticketreport") && detailvar.include?("Single")
        @@driver.checkbox(:id => 'groupbyjob').when_present.set
      elsif !(inputconsole.downcase.include?("centrexticketreport")) && detailvar.include?("Full")
        @@driver.checkbox(:id => "history").when_present.set
      end
      
      puts "Waiting for search button to appear"
      @@driver.button(:value, 'Search').when_present(300).click if previousPO != po
      
      puts "loading report table for job ref: #{jobref}"
      @@driver.table(:id => 'reporttable').wait_until_present(300)
      
      tableHTML = @@driver.table(:id => 'reporttable').html
      
      doc = Nokogiri::HTML(tableHTML)
      
      currentTableData = ''
      
      found = false
      
      updateProgBar((progCounter.quo(jobsToProcess.size)*100)-1)
      progCounter +=1
      
      doc.css('table[@id="reporttable"] tr').each do |row|
        counter = 0
        row.css('th').each do |cell|
          if @firsttime
            counter += 1
            if counter > 3 || inputconsole.downcase.include?("centrexticketreport")
              currentTableData = "#{currentTableData}#{cell.text.gsub(/\t/,'').gsub(/\n/,'')}\t"
            end #end counter check
          end #end firsttime check
        end #End header loop
        
                  
        if row.css('td[11]').text == line || (row.text.include?(jobref) && typevar != "PO & Line Report")
          row.css('td').each do |cell|
            if tableHTML.include?(jobref)
              currentTableData = "#{currentTableData}#{cell.text.gsub(/\t/,'').gsub(/\n/,'')}\t"
            end #end jobref check
          end #end cell loop
        end #end line check
        
        if row.css('td[11]').text == line || (row.text.include?(jobref) && typevar != "PO & Line Report") || @firsttime == true
          found = true
          unless currentTableData.gsub(/\t/,'') == '' then currentTableData = "#{currentTableData.chomp}\n" end
        end
        
        if @firsttime then @firsttime = false; found = false end
        
      end #End table row loop
          
      unless found
      
        currentTableData = currentTableData + oldjobref + "\tNot Found" + "\n"
          
        @ListBox.itemconfigure(jobsToProcess.index(oldjobref), :background => "red")
        
      else
      
        @ListBox.itemconfigure(jobsToProcess.index(oldjobref), :background => "green")
        
      end #end unless found

      File.open("ReportOutput.txt","a") {|reportfile| reportfile.write(currentTableData) } #append the data into report file
      currentTableData = ''
      
      previousPO = po
      
    end #end jobsToProcess loop
    
    Tk.update
    
    @@driver.close

    #Open the report in excel
    setStatus("Opening report in Excel...")
    currentdir = Dir.pwd
    filename = currentdir + "\\ReportOutput.txt"
    CoInitialize.call( 0 )
    excel = WIN32OLE::new("excel.application")
    personal = "#{Dir.home.gsub("/","\\")}\\AppData\\Roaming\\Microsoft\\Excel\\XLSTART\\PERSONAL.XLSB"
    if File.exists?(personal) then excel.Workbooks.Open(personal) rescue nil end #Personal workbook for macros
    excel.Workbooks.Open(filename)
    excel.visible = true

    return true

  rescue
    errorstring = "#{$!}".gsub("\n"," - ")
    puts %Q|Fatal error occurred:\n#{$!}\n\nDebugging Information:\n#{$@.first}|,"Error" #Logfile output
    setStatus "Fatal error. #{errorstring}"
    return false
  end #End PO & Line report

end
