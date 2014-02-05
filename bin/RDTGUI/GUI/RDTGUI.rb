require_relative '../Scripts/defs'

class RDTGUI #Let's give this program some class

	###################################################################################################
	###################################################################################################
	def initialize #Executes automatically when calling the class for the first time
	
		puts "Initialising..."
		@beginning_time = Time.now
	
    #____________________________________________________________________
    #Construct GUI in tk
        
    @root = TkRoot.new(:title=>$title,:background=>"SystemWindow")
    
    #Windows colours:
    #SystemActiveBorder, SystemActiveCaption, SystemAppWorkspace, SystemBackground, SystemButtonFace, SystemButtonHighlight, SystemButtonShadow, SystemButtonText, SystemCaptionText, SystemDisabledText, SystemHighlight, SystemHighlightText, SystemInactiveBorder, SystemInactiveCaption, SystemInactiveCaptionText, SystemMenu, SystemMenuText, SystemScrollbar, SystemWindow, SystemWindowFrame, SystemWindowText
    #:background=>"SystemWindow",

    #Declare Tk variables
    @OptionButtonState = TkVariable.new ('0')
    @StatusCode = TkVariable.new ('Status Code')
    @ReasonCode = TkVariable.new ('Reason Code')
    @SLACode = TkVariable.new ('SLA Code')
    @BERCode = TkVariable.new ('BER Code')
    @TypeCode = TkVariable.new ('Report Type')
    @DetailCode = TkVariable.new ('Report Detail')
    @QuitOnFinish = TkVariable.new(0)
    @IgnoreErrors = TkVariable.new(0)
    @RemoveOldLabels = TkVariable.new(0)
    @Supervisor = TkVariable.new(0)
    @ProgBarPosition = TkVariable.new(0)
    @@Font = TkFont.new('ariel 10')
    
    @Counter, @started = 0, false

    #Build required lists, these are pretty self-explanatory

    @@StatusList = createArray(<<-HEREDOC.gsub(/(^ +)|(\n$)/, ''))
      Repairing
      Testing
      On Soak Test
      ROND Request
      Component Repair
      Uplift Request Email
      BER Request Email
      On Hold - Awaiting Parts
      On Hold - WPIB
      On Hold - Re-assigning
      On Hold-Awaiting Information
      On Hold - External Repair
      Returned at Customers Request
      Beyond Economical Repair
      Repair Complete
      Allocate Only
      Box Uplift
    HEREDOC
    
    @@ReasonList = createArray(<<-HEREDOC.gsub(/(^ +)|(\n$)/, ''))
      CR001 - Fix using Componant / Part Replacement
      CR002 - Fix using a Component / Part Repair
      CR003 - Fix (NPR) by Soft / Firmware Re load only
      CR004 - Fix (NPR) by Minor Adjustment
      CR005 - Fix (NPR) by Formal Calibration
      CR006 - Fix (NPR) by Inspect Clean & Test
      CR007 - Fix (NPR) by Foreign Object Removal
      CR009 - Fix via External Repair
      CR010 - Fix (NPR) Inspect Clean & Test Toner/Ink
      CR011 - Fix (NPR) Resoldering / Rework
      CR012 - Fix by Whole Unit Replacement
      CR013 - Fix by Sub Assembly / Module Replacement
      CR014 - No Fault Found
      CR015 - Unrepaired Quote / Repair not Accepted
      CR016 - Failed ( OOS) - Software Fault
      CR017 - Fix Multiple Issues
      CR018 - Fix Chargeable Repair - Missing Items
    HEREDOC
    
    @@SLAList = createArray(<<-HEREDOC.gsub(/(^ +)|(\n$)/, ''))
      CR019 - Sourcing Difficult Parts
      CR020 - Extended Diagnostic Soak Test
      CR021 - Awaiting Technical Information
      CR022 - Awaiting Information from Customer
      CR023 - Awaiting Full Consignment
      CR024 - Awaiting Test Rig / Consumables etc
      CR025 - Required External Repair
      CR026 - Customer Re-arranging Priority
      CR027 - Awaiting Quotation Approval
      CR028 - Awaiting Secondary Part 
      CR029 - Returned to Manufacturer Under Warranty
    HEREDOC
      
    @@BERList = createArray(<<-HEREDOC.gsub(/(^ +)|(\n$)/, ''))
      CR031 - BER - Parts not available
      CR032 - BER - Damage
      CR033 - BER - Missing
      CR034 - BER - Transit Damage
    HEREDOC
    
    @@TypeList = createArray(<<-HEREDOC.gsub(/(^ +)|(\n$)/, ''))
      Report by CNTX
      Report by Serial
      Workshop Report by CNTX
      Workshop Report by Serial
      PO Report
      PO & Line Report
      History Report by Serial
      History Report by CNTX
      Complete Report by INC
    HEREDOC
    
    @@DetailList = createArray(<<-HEREDOC.gsub(/(^ +)|(\n$)/, ''))
      Single - No Unallocated
      Single - With Unallocated
      Full - No Unallocated
      Full - With Unallocated
    HEREDOC

    @@ConsoleNames = createArray(<<-HEREDOC.gsub(/(^ +)|(\n$)/, ''))
      EngineersConsole
      Reports
      Repair Allocate
      Reports
    HEREDOC

    #Dynamically create the dropdown width based on content
    @@ComboboxWidth = 0
    @TempArray = [@@StatusList, @@ReasonList, @@SLAList, @@TypeList, @@DetailList]
    @TempArray.each do |currentarray|
      if currentarray.max_by(&:length).length > @@ComboboxWidth then @@ComboboxWidth = currentarray.max_by(&:length).length end
    end
    
    @@ComboboxWidth -= 4 #Those weird font sizes! 
    
    puts "Combobox width should be: #{@@ComboboxWidth}"
      
    #____________________________________________________________________
    #Frame outline section

    #Frame for option buttons and tick boxes
    @optionButtonFrame = TkFrame.new(@root,
    :width=>20,
    :height=>10,
    :border=>2,
    :background=>"SystemWindow",
    ).grid :column => 0, :row => 0, :columnspan => 1, :rowspan => 21, :sticky => 'news'
    
    #Frame for dropdown menus
    @dropdownMenuFrame = TkFrame.new(@root,
    :width=>@@ComboboxWidth,
    :height=>6,
    :border=>2,
    :background=>"SystemWindow",
    ).grid :column => 1, :row => 0, :columnspan => 1, :rowspan => 6, :sticky => 'news'

    #Frame for text input
    @textInputFrame = TkFrame.new(@root,
    :width=>30,
    :height=>21,
    :border=>2,
    :background=>"SystemWindow",
    ).grid :column => 2, :row => 0, :columnspan => 2, :rowspan => 21, :sticky => 'news'

    #Frame for scrollbox
    @scrollboxFrame = TkFrame.new(@root,
    :width=>30,
    :height=>21,
    :border=>2,
    :background=>"SystemWindow",
    ).grid :column => 4, :row => 0, :columnspan => 2, :rowspan => 21, :sticky => 'news'

    #Frame for buttons
    @buttonFrame = TkFrame.new(@root,
    :width=>@@ComboboxWidth,
    :height=>6,
    :border=>2,
    :background=>"SystemWindow",
    ).grid :column => 1, :row => 6, :columnspan => 1, :rowspan => 8, :sticky => 'news'

    #Frame for progress bar
    @progressBarFrame = TkFrame.new(@root,
    :width=>140,
    :height=>2,
    :border=>2,
    :background=>"SystemWindow",
    ).grid :column => 0, :row => 21, :columnspan => 6, :rowspan => 2, :sticky => 'news'

    #____________________________________________________________________
    #Populate the frames

    #Radiobuttons
    
    @RadioLabel = TkLabel.new(@optionButtonFrame,
    :text=>"Choose a task:",
    :background=>"SystemWindow",
    :border=>0
    ).grid :column => 0, :row => 0, :sticky => 'news'
    
    @EngineerButton = TkRadioButton.new(@optionButtonFrame,
      :text=>'Engineer Console',
      :variable=>@OptionButtonState,
      :background=>"SystemWindow",
      :value=>0,
      :height=>1,
      :border=>0
    ).grid :column => 0, :row => 1, :sticky => 'nw', :pady=>4
    @EngineerButton.command {puts "Option selected: #{@OptionButtonState.value}"; radioSwitch(0)}
    
    @InvisibleLabel1 = TkLabel.new(@optionButtonFrame,
    :text=>"",
    :background=>"SystemWindow",
    :border=>32
    ).grid :column => 0, :row => 2, :rowspan=>2, :sticky => 'news'
    
    @NotesField = TkText.new(@optionButtonFrame,
      :width=>20,
      :height=>2,
      :background=>"SystemWindow",
      :font=>@@Font
    ).grid :column => 0, :row => 2, :columnspan => 1, :rowspan => 3, :sticky => 'news'
    @NotesField.insert 'end', "Job Notes"
    
    @ReportButton = TkRadioButton.new(@optionButtonFrame,
      :text=>'Reports',
      :variable=>@OptionButtonState,
      :background=>"SystemWindow",
      :value=>1,
      :height=>1,
      :border=>1
    ).grid :column => 0, :row => 5, :sticky => 'nw'
    @ReportButton.command {puts "Option selected: #{@OptionButtonState.value}"; radioSwitch(1)}
    
    @InvisibleLabel2 = TkLabel.new(@optionButtonFrame,
    :text=>"",
    :background=>"SystemWindow",
    :border=>4
    ).grid :column => 0, :row => 6, :rowspan=>1, :sticky => 'news'
    
    @UnallocateButton = TkRadioButton.new(@optionButtonFrame,
      :text=>'Unallocate',
      :variable=>@OptionButtonState,
      :background=>"SystemWindow",
      :value=>2,
      :height=>1,
      :border=>2
    ).grid :column => 0, :row => 7, :sticky => 'nw'
    @UnallocateButton.command {puts "Option selected: #{@OptionButtonState.value}"; radioSwitch(2)}

    @LabelsButton = TkRadioButton.new(@optionButtonFrame,
      :text=>'Save Labels',
      :variable=>@OptionButtonState,
      :background=>"SystemWindow",
      :value=>3,
      :height=>1,
      :border=>2
    ).grid :column => 0, :row => 8, :sticky => 'nw'
    @LabelsButton.command {puts "Option selected: #{@OptionButtonState.value}"; radioSwitch(3)}
    
    
    #Dropdown menus
    
    @ComboBoxLabel = TkLabel.new(@dropdownMenuFrame,
    :text=>"Choose Sub-Options:",
    :background=>"SystemWindow"
    ).grid :column => 1, :row => 0, :sticky => 'news'
  
    @StatusBox = Tk::Tile::Combobox.new(@dropdownMenuFrame,
      :textvariable=>@StatusCode,
      :state=>'readonly',
      :width=>@@ComboboxWidth,
      :values=>@@StatusList,
    ).grid :column => 1, :row => 1, :sticky => 'news'
    @StatusBox.bind("<ComboboxSelected>") { puts "#{@StatusCode}"; unless @StatusCode == "Repair Complete" then @ReasonBox.configure :state=>'disabled'; @SLABox.configure :state=>'disabled' else  @ReasonBox.configure :state=>'readonly'; @SLABox.configure :state=>'readonly' end; unless @StatusCode == "Beyond Economical Repair" || @StatusCode == "BER Request Email" then @BERBox.configure :state=>'disabled' else  @BERBox.configure :state=>'readonly'; @BERBox.configure :state=>'readonly' end}
    
    @ReasonBox = Tk::Tile::Combobox.new(@dropdownMenuFrame,
      :textvariable=>@ReasonCode,
      :state=>'readonly',
      :width=>@@ComboboxWidth,
      :values=>@@ReasonList,
    ).grid :column => 1, :row => 2, :sticky => 'news'
    @ReasonBox.bind("<ComboboxSelected>") { puts "#{@ReasonCode}" }
    
    @SLABox = Tk::Tile::Combobox.new(@dropdownMenuFrame,
      :textvariable=>@SLACode,
      :state=>'readonly',
      :width=>@@ComboboxWidth,
      :values=>@@SLAList
    ).grid :column => 1, :row => 3, :sticky => 'news'
    @SLABox.bind("<ComboboxSelected>") { puts "#{@SLACode}" }
    
    @BERBox = Tk::Tile::Combobox.new(@dropdownMenuFrame,
      :textvariable=>@BERCode,
      :state=>'readonly',
      :width=>@@ComboboxWidth,
      :values=>@@BERList
    ).grid :column => 1, :row => 4, :sticky => 'news'
    @SLABox.bind("<ComboboxSelected>") { puts "#{@BERCode}" }
    
    @ComboBoxLabel = TkLabel.new(@dropdownMenuFrame,
    :text=>"",
    :background=>"SystemWindow"
    ).grid :column => 1, :row => 5, :sticky => 'news'
    
    @TypeBox = Tk::Tile::Combobox.new(@dropdownMenuFrame,
      :textvariable=>@TypeCode,
      :state=>'readonly',
      :width=>@@ComboboxWidth,
      :values=>@@TypeList,
    ).grid :column => 1, :row => 6, :sticky => 'news'
    @TypeBox.bind("<ComboboxSelected>") { puts "#{@TypeCode}" }
    
    @DetailBox = Tk::Tile::Combobox.new(@dropdownMenuFrame,
      :textvariable=>@DetailCode,
      :state=>'readonly',
      :width=>@@ComboboxWidth,
      :values=>@@DetailList
    ).grid :column => 1, :row => 7, :sticky => 'news'
    @DetailBox.bind("<ComboboxSelected>") { puts "#{@DetailCode}" }
    
    
    #Input field
    
    @TextFieldLabel = TkLabel.new(@textInputFrame,
    :text=>"Data Entry:",
    :background=>"SystemWindow"
    ).grid :column => 2, :row => 0, :sticky => 'news'
    
    @@TextField = TkText.new(@textInputFrame,
      :width=>20,
      :height=>17,
      :background=>"SystemWindow",
      :font=>@@Font
    ).grid :column => 2, :row => 1, :columnspan => 1, :rowspan => 17
    
    @@TextScrollbar = Tk::Tile::Scrollbar.new(@textInputFrame) {orient 'vertical'; 
    command proc{|*args| @@TextField.yview(*args)}}.grid :column => 3, :row => 1, :rowspan => 17, :sticky => 'ns'  
    
    @TextField = @@TextField
    
    #Current List
    
    @@ListBoxLabel = TkLabel.new(@scrollboxFrame,
    :text=>"Current List:",
    :background=>"SystemWindow",
    :width=>10,
    :height=>1
    ).grid :column => 4, :row => 0, :columnspan => 2, :sticky => 'news'
    
    @ListBox = TkListbox.new(@scrollboxFrame, 'selectmode' => 'browse') { height 16; width 20; font TkFont.new('ariel 10');
    yscrollcommand proc{|*args| @@ListBoxScrollbar.set(*args)} }.grid :column => 4, :row => 1, :rowspan => 16, :sticky => 'nwes'
    
    @ListBoxTotal = TkLabel.new(@scrollboxFrame,
    :text=>"Total: ",
    :background=>"SystemWindow"
    ).grid :column => 4, :row => 18, :sticky => 'news'
        
    (getdata.each{|i| @ListBox.insert 'end', i})
    @ListBoxTotal.configure :text=>"Total: " + @ListBox.size.to_s
    
    @@ListBoxScrollbar = Tk::Tile::Scrollbar.new(@scrollboxFrame,
    :orient=>'vertical',
    :command=>proc{|*args| @ListBox.yview(*args)}
    ).grid :column => 5, :row => 1, :rowspan => 20, :sticky => 'news'
    
    
    #Button up
    
    @ButtonsLabel = TkLabel.new(@buttonFrame,
    :text=>"Action Buttons:",
    :background=>"SystemWindow",
    :width=>@@ComboboxWidth,
    :height=>1,
    ).grid :column => 1, :row => 7, :sticky => 'news'
    
    @GoButton = TkButton.new(@buttonFrame,
      :text=>"Start selected script",
      :width=>@@ComboboxWidth,
      :background=>'SystemButtonFace',
      :command=>proc {beginmainscript(@@ConsoleNames[@OptionButtonState.value.to_i],@OptionButtonState.value.to_i)}
    ).grid :column => 1, :row => 8, :sticky => 'news'
    
    @UseListButton = TkButton.new(@buttonFrame,
      :text=>"Use 'Data Entry' as List",
      :width=>@@ComboboxWidth,
      :background=>'SystemButtonFace',
      :command=>proc {
      dataEntryAsList
      }
    ).grid :column => 1, :row => 9, :sticky => 'news'
    
    @ImportListButton = TkButton.new(@buttonFrame,
      :width=>@@ComboboxWidth,
      :text=>"Update List From File",
      :background=>'SystemButtonFace',
      :command=>proc{updateListBoxFromFile}
    ).grid :column => 1, :row => 10, :sticky => 'news'
    
    @EditListButton = TkButton.new(@buttonFrame,
      :width=>@@ComboboxWidth,
      :text=>"Edit Current List",
      :background=>'SystemButtonFace',
      :command=>proc{editListInDataEntry}
    ).grid :column => 1, :row => 11, :sticky => 'news'
    
    @QuitButton = TkButton.new(@buttonFrame,
      :width=>@@ComboboxWidth,
      :text=>"Quit",
      :background=>'SystemButtonFace',
      :command=>proc{exit}
    ).grid :column => 1, :row => 12, :sticky => 'news'
    
    
    #Tick tock
    
    @InvisibleLabel3 = TkLabel.new(@optionButtonFrame,
    :text=>"",
    :background=>"SystemWindow",
    :border=>10
    ).grid :column => 0, :row => 15, :rowspan=>1, :sticky => 'news'
    
    @SupervisorButton = TkCheckButton.new(@optionButtonFrame,
      :text=>"Use Supervisor Console",
      :height=>1,
      :border=>1,
      :width=>17,
      :variable=>@Supervisor,
      :background=>"SystemWindow",
      :state=>'normal',
      :justify=>'left'
    ).grid :column => 0, :row => 16, :sticky => 'w'
    @SupervisorButton.command {puts "Supervisor: #{@Supervisor.value}"; regDefault(1,"Supervisor",@Supervisor.value.to_i)}
    
    @RemoveOldLabelsButton = TkCheckButton.new(@optionButtonFrame,
      :text=>"Remove Old Labels",
      :height=>1,
      :border=>1,
      :width=>14,
      :variable=>@RemoveOldLabels,
      :background=>"SystemWindow",
      :state=>'normal',
      :justify=>'left'
    ).grid :column => 0, :row => 17, :sticky => 'w'
    @RemoveOldLabelsButton.command {puts "Remove Old Labels: #{@RemoveOldLabels.value}"; regDefault(1,"RemoveOldLabels",@RemoveOldLabels.value.to_i)}
        
    @QuitOnFinishButton = TkCheckButton.new(@optionButtonFrame,
      :text=>"Quit when complete",
      :height=>1,
      :border=>1,
      :width=>15,
      :variable=>@QuitOnFinish,
      :background=>"SystemWindow",
      :state=>'normal',
      :justify=>'left'
    ).grid :column => 0, :row => 18, :sticky => 'w'
    @QuitOnFinishButton.command {puts "Quit on finish: #{@QuitOnFinish.value}"; regDefault(1,"QuitOnFinish",@QuitOnFinish.value.to_i)}
    
    @IgnoreErrorsButton = TkCheckButton.new(@optionButtonFrame,
      :text=>"Ignore errors",
      :height=>1,
      :border=>1,
      :width=>9,
      :state=>'normal',
      :background=>"SystemWindow",
      :justify=>'left',
      :variable=>@IgnoreErrors
    ).grid :column => 0, :row => 19, :sticky => 'w'
    @IgnoreErrorsButton.command {puts "Ignore errors: #{@IgnoreErrors.value.to_i}"; regDefault(1,"IgnoreErrors",@IgnoreErrors.value.to_i)}

    @LocationSwitch = TkButton.new(@optionButtonFrame,
      :text=>"Location: MK",
      :background=>'SystemButtonFace',
      :command=>proc {if @LocationSwitch.text == "Location: MK" then @LocationSwitch.configure :text=>"Location: Ashington"; regDefault(1,"Location","Ashington") else @LocationSwitch.configure :text=>"Location: MK"; regDefault(1,"Location","MK") end; puts "#{@LocationSwitch.text}"}
    ).grid :column => 0, :row => 20, :sticky => 'news'
    
    val = regDefault(0,"Location")
    unless val == false
      @LocationSwitch.configure :text=>("Location: #{val}")
    else
      @LocationSwitch.configure :text=>"Location: MK"
    end
    
    @IgnoreErrorsButton.select if regDefault(0,"IgnoreErrors") == "1"
    @QuitOnFinishButton.select if regDefault(0,"QuitOnFinish") == "1"
    @RemoveOldLabelsButton.select if regDefault(0,"RemoveOldLabels") == "1"
    @SupervisorButton.select if regDefault(0,"Supervisor") == "1"
    setOptionsFromReg
    
    val = regDefault(0,"RadioOption")
    unless val == false
      @OptionButtonState.value = val.to_i
      puts "optionvalue #{@OptionButtonState.value}"
      radioSwitch(@OptionButtonState.value.to_i)      
    else
      @OptionButtonState.value = 0
      puts "optionvalue #{@OptionButtonState.value}"
      radioSwitch(@OptionButtonState.value.to_i)      
    end
    
    #ProgressBar and Status
    
    @CurrentStatus = TkLabel.new(@progressBarFrame,
    :text=>"Current Status",
    :background=>"SystemWindow",
    :width=>140,
    :height=>1,
    ).grid :column => 0, :row => 21, :columnspan => 6, :sticky => 'news'
    
    @ProgressBar = Tk::Tile::Progressbar.new(@progressBarFrame,
      :orient=>'horizontal',
      :length=>140,
      
      :mode=>'determinate',
      :variable=>@ProgBarPosition
    ).grid(:column => 0, :row => 2, :columnspan => 6, :sticky => 'we')

    
    #top menu1
    
    @file_menu = TkMenu.new(@root,
    :tearoff=>false
    )

    @file_menu.add('command',
            'label' => "Enter RDT Username",
            'command' => proc{createlogin(1)},
            'underline' => 10)
    @file_menu.add('separator')
    @file_menu.add('command',
            'label' => "Enter RDT Password",
            'command' => proc{createlogin(2)},
            'underline' => 10)
    @file_menu.add('separator')
    @file_menu.add('command',
            'label' => "Exit",
            'command' => proc{exit},
            'underline' => 1)

    @menu_bar = TkMenu.new
    @menu_bar.add('cascade',
           'menu'  => @file_menu,
           'label' => "RDT Details",
           'underline' => 0)

    
    #top menu2
    
    @notes_menu = TkMenu.new(@root,
    :tearoff=>false
    )
    
    @notes_menu.add('command',
            'label' => "C&TOK",
            'command' => proc{updatenotes("Cleaned & Tested OK","Repair Complete","CR006 - Fix (NPR) by Inspect Clean & Test","CR021 - Awaiting Technical Information")},
            'underline' => 0)
    @notes_menu.add('separator')
    
    @notes_menu.add('command',
            'label' => "A35 PED EXT",
            'command' => proc{updatenotes("Completed and Passed to External Repair.\nPart will bypass workshop and return to stock. CR009","Repair Complete","CR009 - Fix via External Repair","CR025 - Required External Repair")},
            'underline' => 0)
    @notes_menu.add('separator')
  
    @notes_menu.add('command',
            'label' => "EXT",
            'command' => proc{updatenotes("Passed to External Repair as per process.","On Hold - External Repair")},
            'underline' => 0)
    @notes_menu.add('separator')

    @notes_menu.add('command',
            'label' => "Return to Customer",
            'command' => proc{updatenotes("Returned to Customer as Requested.","Returned at Customers Request")},
            'underline' => 0)
    @notes_menu.add('separator')
    
    @notes_menu.add('command',
            'label' => "Returned from EXT",
            'command' => proc{updatenotes("Returned from External Repair.","Repair Complete","CR009 - Fix via External Repair","CR025 - Required External Repair")},
            'underline' => 2)
    
    @menu_bar.add('cascade',
           'menu'  => @notes_menu,
           'label' => "Notes List",
           'underline' => 0)
    
    @root.menu(@menu_bar)
        
    #Resize you say?

    (0..21).each { |i| TkGrid.rowconfigure( @root, i, :weight => 1, :minsize => 10, :pad => 5) }
    (0..6).each { |i| TkGrid.columnconfigure( @root, i, :weight => 1, :minsize => 10, :pad => 5) }
    TkGrid.columnconfigure(@optionButtonFrame, 0, :pad => 10, :weight => 1)
    
    
    #Personalise title
    
    username = getlink("username")
    if username != false then @root.configure :title=>"#{$title} - #{username}" end
    
    #Don't allow resizing (might change in future)
    Tk.root.resizable(false, false)
    
    #Allocate focus to the Data Entry field
    @TextField.focus
    
    puts "finished initialising"
    timer
    
  end #End initialize
  ###################################################################################################
  ###################################################################################################
  
  
  def run #Make it go!
    Tk.mainloop
  end #End run

end #End class
