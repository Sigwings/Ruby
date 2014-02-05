require_relative 'scripts'

class RDTGUI

  def regDefault(switch,location,value="Default") #Read / Write, Keyname, Value for write
    #switch: 1 is write, 0 is read
    #location: the keyname in the registry
    #value: if switch is 1, value to write

    if switch == 1 && value == "Default" then return false end
    
    if switch == 0
      keyvalue = Win32::Registry::HKEY_CURRENT_USER.open("SOFTWARE\\ReDeTrackRuby")[location] #This'll cause an error if nothing's there
      puts "Found preset #{location}: '#{keyvalue}' in registry"
      return "#{keyvalue}"
    else
      puts "Writing #{location}: #{value} into registry"
      #Create the registry path and dump their link into the value
      Win32::Registry::HKEY_CURRENT_USER.create "SOFTWARE\\ReDeTrackRuby"
      Win32::Registry::HKEY_CURRENT_USER.open("SOFTWARE\\ReDeTrackRuby",Win32::Registry::KEY_ALL_ACCESS).write(location,Win32::Registry::REG_SZ,value)
      return true
    end #End switch
  rescue
    puts "No preset #{location} found in registry, returning false"
    return false
  end #End regDefault

  def editListInDataEntry
    #Pull the listbox into the textbox
    dataArray =  @ListBox.get(0,'end')
    stringy = dataArray.join("\n")
    @TextField.delete(1.0,'end')
    @TextField.insert 'end', stringy
  end #End editListInDataEntry

  def dataEntryAsList
    if (@TextField.get(1.0, 'end').chomp.strip == "") then return false end
    #Pull the textbox into the listbox
    @ListBox.delete(0,'end')
    createArray(@TextField.get(1.0, 'end')).each{|i| @ListBox.insert 'end', i}
    @ListBox.configure(:background => "white")
    @ListBoxTotal.configure :text=>"Total: " + @ListBox.size.to_s
    File.open("list.txt","w") {|listfile| listfile.write(@TextField.get(1.0, 'end')) }
  end #End dataEntryAsList

  def timer
    #report time difference
    end_time = Time.now
    puts "Time elapsed #{(end_time - @beginning_time)} seconds"
    @beginning_time = Time.now
  end #End timer
    
  def updatenotes(inputstring, main_dropdown=nil, optional1=nil, optional2=nil)
    #Make sure the engineer option is active to unlock the notes field
    @EngineerButton.select
    radioSwitch(0)
    
    #Set the Notes field as inputstring
    @NotesField.delete(1.0,'end')
    @NotesField.insert 'end', inputstring
    
    #Set the dropdown boxes to the appropriate setting
    unless main_dropdown==nil
      @StatusBox.set(main_dropdown)
      unless @StatusCode == "Repair Complete" then @ReasonBox.configure :state=>'disabled'; @SLABox.configure :state=>'disabled' else @ReasonBox.configure :state=>'readonly'; @SLABox.configure :state=>'readonly' end; unless @StatusCode == "Beyond Economical Repair" || @StatusCode == "BER Request Email" then @BERBox.configure :state=>'disabled' else  @BERBox.configure :state=>'readonly'; @BERBox.configure :state=>'readonly' end
    end
    
    unless optional1==nil
      @ReasonBox.set(optional1)
    end
    
    unless optional2==nil
      @SLABox.set(optional2)
    end
    
  end #End updatenotes
    
  def radioSwitch(option)
    #Trigger events based on which radiobutton was just pushed
    case option
    
    when 0
    
      @NotesField.configure :state=>'normal', :background=>"SystemWindow"
      @StatusBox.configure :state=>'readonly', :background=>"SystemWindow"
      if @StatusCode.value == "Repair Complete" then @ReasonBox.configure :state=>'readonly', :background=>"SystemWindow" else @ReasonBox.configure :state=>'disabled', :background=>'SystemDisabledText' end
      if @StatusCode.value == "Repair Complete" then @SLABox.configure :state=>'readonly', :background=>"SystemWindow" else @SLABox.configure :state=>'disabled', :background=>'SystemDisabledText' end
      if @StatusCode.value == "Beyond Economical Repair" || @StatusCode.value == "BER Request Email" then @BERBox.configure :state=>'readonly', :background=>"SystemWindow" else @BERBox.configure :state=>'disabled', :background=>'SystemDisabledText' end
      @TypeBox.configure :state=>'disabled', :background=>'SystemDisabledText'
      @DetailBox.configure :state=>'disabled', :background=>'SystemDisabledText'
      
    when 1
    
      @NotesField.configure :state=>'disabled', :background=>'SystemInactiveCaptionText'
      @StatusBox.configure :state=>'disabled', :background=>'SystemDisabledText'
      @ReasonBox.configure :state=>'disabled', :background=>'SystemDisabledText'
      @SLABox.configure :state=>'disabled', :background=>'SystemDisabledText'
      @BERBox.configure :state=>'disabled', :background=>'SystemDisabledText'
      @TypeBox.configure :state=>'readonly', :background=>"SystemWindow"
      @DetailBox.configure :state=>'readonly', :background=>"SystemWindow"

    when 2,3
    
      @NotesField.configure :state=>'disabled', :background=>'SystemInactiveCaptionText'
      @StatusBox.configure :state=>'disabled', :background=>'SystemDisabledText'
      @ReasonBox.configure :state=>'disabled', :background=>'SystemDisabledText'
      @SLABox.configure :state=>'disabled', :background=>'SystemDisabledText'
      @BERBox.configure :state=>'disabled', :background=>'SystemDisabledText'
      @TypeBox.configure :state=>'disabled', :background=>'SystemDisabledText'
      @DetailBox.configure :state=>'disabled', :background=>'SystemDisabledText'

    else 
      return false
    end
    
  end #End radioSwitch
    
  def getlink(keyname)

    begin #Bring me your keyname value!

      linkaddress = Win32::Registry::HKEY_CURRENT_USER.open("SOFTWARE\\ReDeTrackRuby")[keyname] #This'll cause an error if nothing's there

    rescue #There's nothing there!
    
      return false #Report our failure to the commander
      
    end #End registry errorhandler
    
    if keyname == "password" then linkaddress = decrypt(linkaddress) end #Passwords are secret, shhh.
    
    return linkaddress #Success!

  end #end getlink

  def setlink(keyname, linkaddress)
    #keyname: The name of the registry key to write to
    #linkaddress: The value to write to that key

    #Create the registry path and dump their link into the value
    Win32::Registry::HKEY_CURRENT_USER.create "SOFTWARE\\ReDeTrackRuby"
    Win32::Registry::HKEY_CURRENT_USER.open("SOFTWARE\\ReDeTrackRuby",Win32::Registry::KEY_ALL_ACCESS).write(keyname,Win32::Registry::REG_SZ,linkaddress)

    return true
    
  end #end setlink


  def createArray(inputvalue)
    #inputvalue: a string broken by carriage returns to be formatted into an array

    outputvalue = inputvalue.gsub(/\t/,'').split(/\n/).reject{ |el| el==''}

    return outputvalue

  end #End createArray
    
  def message_box(inputstring="Default", title="Title") 
    #inputstring: Message to display
    #title: Title of messagebox
    Tk.messageBox(
    'type'    => "ok",  
    'icon'    => "info",
    'title'   => title,
    'message' => "#{inputstring}"
    )
  end #End message_box

  ###################################################################################################
  ###################################################################################################
  def userinputbox(request)
    #request: Text message to display to the user
    setStatus("#{request}")

    @UserInputbox = TkToplevel.new(@root, :title=>"#{request}").focus
    
    @UserInputField = TkEntry.new(@UserInputbox,
      :width=>80,
      :borderwidth=>1,
      :font=>TkFont.new('ariel 10')
    ).pack("side" => "left")
    @UserInputField.bind("Any-Key-Return"){userenter}
    @UserInputField.focus

    @UserCancelButton = TkButton.new(@UserInputbox,
      :text=>"Cancel",
    ).pack("side"=>"bottom")
    @UserCancelButton.command proc{@UserInputbox.destroy; setStatus("Pressed cancel")}
    
    @UserOKButton = TkButton.new(@UserInputbox,
      :text=>"OK"
      ).pack("side"=>"bottom")
    @UserOKButton.command proc{userenter}  
  end #End userinputbox

  def userenter
    #This is called specifically for the username entry
    if @UserInputField.get == '' then setStatus "cancelled" ; return false end
    @root.configure :title=>"#{$title} - #{@UserInputField.get}"
    setlink('username',@UserInputField.get)
    @UserInputbox.destroy
    setStatus("Pressed ok")
  end #End userenter
  ###################################################################################################
  ###################################################################################################


  ###################################################################################################
  ###################################################################################################
  def passwordinputbox(request)
    #request: Text message to display to the user
    setStatus("#{request}")

    @passwordInputbox = TkToplevel.new(@root, :title=>"#{request}").focus
    
    @passwordInputField = TkEntry.new(@passwordInputbox,
      :width=>80,
      :borderwidth=>1,
      :font=>TkFont.new('ariel 10')
    ).pack("side" => "left")
    @passwordInputField.configure(:show=>'*')
    @passwordInputField.bind("Any-Key-Return"){passwordenter}
    @passwordInputField.focus
    
    @passwordCancelButton = TkButton.new(@passwordInputbox,
      :text=>"Cancel",
    ).pack("side"=>"bottom")
    @passwordCancelButton.command proc{@passwordInputbox.destroy; setStatus("Pressed cancel")}
    
    @passwordOKButton = TkButton.new(@passwordInputbox,
      :text=>"OK"
      ).pack("side"=>"bottom")
    @passwordOKButton.command proc{passwordenter}

  end #End passwordinputbox
  ###################################################################################################
  ###################################################################################################


  def passwordenter
    if @passwordInputField.get == '' then setStatus "cancelled" ; return false end
    setlink('password',encrypt(@passwordInputField.get))
    @passwordInputbox.destroy
    setStatus("Pressed ok")
  end #End passwordenter

  def setStatus(inputtext="Idle")
    #inputtext: The message to display on the statusbar and write to the logfile
    @CurrentStatus.configure('text'=>inputtext)
    puts inputtext
    Tk.update
  end #End setStatus
    
  def updateListBoxFromFile
    #Get a file from the user and use it to update the listbox
    ftypes = [["Text files", '*txt']]
    filename = Tk.getOpenFile('filetypes'=>ftypes)
    if filename.length < 1 then return false end
    @ListBox.delete(0,'end')
    getdata(filename).each{|i| @ListBox.insert 'end', i}
    @ListBox.configure(:background => "white")
    @ListBoxTotal.configure :text=>"Total: " + @ListBox.size.to_s
    
    puts "#{@root['background']}"
    
  end #End updateListBoxFromFile

  def getdata(filename="list.txt")
    #filename: String file name from which to extract an array
    begin
      data = File.read(filename).upcase.strip.gsub(" ","").gsub(/\t/,"")
    rescue
      data = 'Nothing found'
    end
    dataArray = data.split("\n").reject{|el| el==''}
    
    return dataArray
  end #End getdata

  def progressbarSwitch(reset=false) #This is currently not used to progress the bar, only reset it. 
    #reset: Boolean which will reset the progressbar to zero and stop it if set to true
    #@started ? (puts "stop progbar"; @ProgressBar.stop; @started = false) : (puts "start progbar"; @ProgressBar.start; @started = true)
    reset ? (puts "reset progbar"; @ProgBarPosition.value = 0; @ProgressBar.stop; @started = false) : (puts "not reset progbar")
  end #End progressbarSwitch

  def updateProgBar(inputinteger)
    #inputinteger: Integer between 0 and 100 which will set the progressbar's position
    @ProgBarPosition.value = (inputinteger.to_i)
    puts "Progressbar value = #{@ProgBarPosition.value}"
    Tk.update #Without this line no visible change will occur until the script rejoins mainloop
  rescue
    puts "Error in updateProgBar with #{inputinteger}"
  end

  def createlogin(switch) #Triggered to collect the user's username or password
    if switch == 1
      userinputbox("Enter your RDT username")
    else
      passwordinputbox("Enter your RDT password")
    end
  end #End createLogin

  def encrypt(make_it_weird) #Handy for passwords that you need to store somewhere accessible
    #make_it_weird: The string to be encrypted
    if make_it_weird == nil then return false end
    blowfish = Crypt::Blowfish.new("12") #12 is the encryption key, needed for the decrypt process
    b = blowfish.encrypt_string(make_it_weird)
    return b
  end #End encrypt

  def decrypt(wtf_is_this)
    #wtf_is_this: The string to be decrypted
    if wtf_is_this == nil then return false end
    blowfish = Crypt::Blowfish.new("12")
    a = blowfish.decrypt_string(wtf_is_this)
    return a
  end #End decrypt

  def putspassword #Just in case I need to recover a password
    password = getlink("password")
    p password
  end #End putspassword

  def beginmainscript(inputconsole='EngineersConsole', optionselected)
    #inputconsole: The specific page name that RDT use for the required task
    #optionselected: The Integer denoting the requested task

    timer #Start recording time for benchmarking
    
    progressbarSwitch(true) #reset the progressbar

    @ErrorFlag = 0
    
    writeOptionsIntoReg  #Record the current settings to be used on next program start

    result = validateUserSettings(optionselected) #Check they haven't forgotten an important setting
    if result != false then setStatus("Validated User Settings, Validating Input Data...") else setStatus("Error Validating User Settings"); return false end

    #Colour everything in the list back to white so we can keep track in the GUI
    @ListBox.size.times do |index|
      @ListBox.itemconfigure(index, :background => "white")
    end
    Tk.update #Update the GUI
    timer #Log the time taken for settings validation

    if optionselected == 1 #There are 2 report tools, make sure we're aiming for the right one
      if @TypeCode.value.include?("Workshop") || @TypeCode.value.include?("PO ") || @TypeCode.value.include?("History") || @TypeCode.value.include?("INC")
        inputconsole = 'Workshop Reports'
      end
    end
    
    if inputconsole == 'EngineersConsole' && @Supervisor.value == '1'
      puts "Supervisor Console selected rather than Engineer Console"
      inputconsole = 'Supervisor Console'
    end
    
    #Determine whether CNTX inputs or other are required
    puts "Option passed to script: #{optionselected}"
     case optionselected
     when 0, 2, 3
      puts "Option button: #{optionselected}, looking for CNTX numbers."
      cntxSwitch = 1
    when 1
      if @TypeCode.value.include?("CNTX")
        puts "Data should be CNTX"
        cntxSwitch = 1
      elsif @TypeCode.value.include?("Serial")
        puts "Data should be serial"
        cntxSwitch = 0
      elsif @TypeCode.value.include?("PO")
        puts "Data should be PO"
        cntxSwitch = 0
      elsif @TypeCode.value.include?("INC")
        puts "Data should be INC"
        cntxSwitch = 0
      else
        setStatus("Invalid choice: Reports - #{@TypeCode.value}")
        return false
      end
     end #end case optionselected
    
    #Get the list of user input data to use
    jobsToProcess = gatherUserInput(cntxSwitch)
    if jobsToProcess != false then setStatus("Validated input data, Starting Firefox...") else setStatus("error validating input data"); @@driver.close rescue nil; return false end
    #Uppercase the array
    jobsToProcess.map!(&:upcase)
    
    #Remove duplicates
    if jobsToProcess.uniq! != nil 
      puts "Removed duplicate numbers"      
      #Rewrite the list into the listbox if duplicates were removed
      @ListBox.delete(0,'end')
      jobsToProcess.each{|i| @ListBox.insert 'end', i}
      @ListBoxTotal.configure :text=>"Total: " + @ListBox.size.to_s
    end
    
    #Set up the handled error reporter
    @ErrorList = []
    
    timer #Log the time taken to validate the input
    puts "loading browser"
    
    #Navigate to the main menu and make sure the link we need is there
    result = startBrowserAndGotoLink(inputconsole)
    if result == true then timer ; puts "Executing script #{optionselected}" else @@driver.close rescue nil; return false end
    
    #The engineer console and unallocation tools both need the correct location
    if @LocationSwitch.text == "Location: Ashington"
      location = "Ashington"
    else
      location = "MK"
    end
    
    case optionselected
    when 0
      result = engineerConsoleScript(@linkaddress,jobsToProcess,location,@StatusCode.value,@ReasonCode.value,@SLACode.value,@BERCode.value,@NotesField.get(1.0, 'end').chomp)
      if result == true then setStatus "Process complete"; Tk.update; @ProgBarPosition.value = 100; @@driver.close else @@driver.close rescue nil; @ProgBarPosition.value = 0; return false end
    when 1
      result = reportingScript(@linkaddress,jobsToProcess,@TypeCode.value,@DetailCode.value)
      if result == true then setStatus "Report complete: ReportOutput.txt"; Tk.update; @ProgBarPosition.value = 100; @@driver.close else @@driver.close rescue nil; @ProgBarPosition.value = 0; return false end
    when 2
      result = unallocateScript(@linkaddress,jobsToProcess,location)
      if result == true then setStatus "Process complete"; Tk.update; @ProgBarPosition.value = 100; @@driver.close else @@driver.close rescue nil; @ProgBarPosition.value = 0; return false end
    when 3
      result = printLabelsScript(@linkaddress,jobsToProcess)
      if result == true then setStatus "Labels placed in RubyDownloads folder"; Tk.update; @ProgBarPosition.value = 100; @@driver.close else @@driver.close rescue nil; @ProgBarPosition.value = 0; return false end
    else
      setStatus "Invalid option"
      return false
    end #End case optionselected
    
    Tk.update #Update GUI with progressbar position
    
    timer #Flag time for benchmark
    
    if @ErrorFlag == 1 then #If we made it this far with an error, then Ignore Errors is ticked
      setStatus "Completed with error(s): #{@CurrentError}"
      message_box("Completed with the following errors:\n#{@ErrorList.join("\n")}","Error") if @ErrorList.size > 1
    end
    
    #Only quit on finish if there were no errors (and the quit on finish box is ticked, of course)
    if "#{@QuitOnFinish.value}#{result}#{@ErrorFlag}" == "1true0" then #for some reason this comparison only works as a string
      puts "User selected quit on finish. Script finished, quitting."
      exit
    end
    
  end #End beginMainScript
  ###################################################################################################
  ###################################################################################################

  def writeOptionsIntoReg #Keep track of the current settings for next time
      [@StatusBox,@ReasonBox,@SLABox,@BERBox,@TypeBox,@DetailBox].each do |field|
        regDefault(1,field.text.gsub(" ",""),field.value)
      end
      regDefault(1,"Notes",@NotesField.get(1.0,'end').chomp)
      regDefault(1,"RadioOption",@OptionButtonState.value.to_i)
  end #End writeOptionsIntoReg
      
  def setOptionsFromReg

    [@StatusBox,@ReasonBox,@SLABox,@BERBox,@TypeBox,@DetailBox].each do |field|
      val = regDefault(0,field.text.gsub(" ",""))
      if val != false
        field.set val
      end
    end #End loop
    val = regDefault(0,"Notes")
    if val != false
      @NotesField.delete(1.0,'end')
      @NotesField.insert 'end', val
    end
  end #End setOptionsFromReg

  ###################################################################################################
  ###################################################################################################

  def validateUserSettings(optionselected)
    #optionselected: Integer denoting the current radiobutton value

    #@StatusCode = TkVariable.new ('Status Code')
    #@ReasonCode = TkVariable.new ('Reason Code')
    #@SLACode = TkVariable.new ('SLA Code')
    #@BERCode = TkVariable.new ('BER Code')
    #@TypeCode = TkVariable.new ('Report Type')
    #@DetailCode = TkVariable.new ('Report Detail')

    case optionselected
    when 0
      if @StatusCode.value == 'Status Code'
        message_box("Invalid choice in dropdown box", "Error") 
        return false
      end
      if @StatusCode.value == 'Repair Complete'
        if @ReasonCode.value == 'Reason Code' || @SLACode.value == 'SLA Code'
          message_box("Invalid choice in dropdown box", "Error") 
          return false
        end
      end
      
      if @StatusCode.value == "Beyond Economical Repair" || @StatusCode.value == "BER Request Email"
        if @BERCode.value == 'BER Code'
          message_box("Invalid BER Code", "Error") 
          return false
        end
      end
    when 1
      if @TypeCode.value == 'Report Type' || @DetailCode.value == 'Report Detail'
        message_box("Invalid choice in dropdown box", "Error") 
        return false
      end      
    else
      #Eh, what could go wrong?
    end

    return true
    
  end #End validateUserSettings
  ###################################################################################################
  ###################################################################################################

end
