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
