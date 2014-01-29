class LabelGui

  # Build the GUI
  def initialize

	@lbllength = 50
    $rad = TkVariable.new(1)
    $cb = TkVariable.new(false)
    $dp = TkVariable.new(false)

#    @text = TkVariable.new
 
		root = TkRoot.new(
			title: $title,
      background: 'SystemWindow'
    )
   
		top = TkFrame.new(root).pack('fill'=>'both', 'expand'=>true)
    
    @butl=TkButton.new(top,
      text: 'Print',
      width: 23,
      height: 2,
      command: proc {go_go_go}
		).grid row: 0, column: 0, columnspan: 2, sticky: 'nsew'
    
    @butm=TkButton.new(top,
      text: 'Open Report',
#      state: 'disabled',
      width: 23,
      height: 2,
      command: proc {open_log $logfile}
		).grid row: 0, column: 2, columnspan: 2, sticky: 'nsew'

    @butr=TkButton.new(top,
      text: 'Close', 
      width: 23,
      height: 2,
      command: proc{ exit }
		).grid row: 0, column: 4, columnspan: 2, sticky: 'nsew'

		@radl = TkRadiobutton.new(top,
      text: 'Centrex Label',
			variable: $rad,
			value: 1
#      height(2)
		).grid row: 1, column: 0, columnspan: 2, sticky: 'nsew'

   @radm = TkRadiobutton.new(top,
      text: 'Stock Label',
			variable: $rad,
			value: 2
#      height(2)
		).grid row: 1, column: 2, columnspan: 2, sticky: 'nsew'

   @radr = TkRadiobutton.new(top,
      text: 'Repair Label',
			variable: $rad,
			value: 3
#      height(2)
		).grid row: 1, column: 4, columnspan: 2, sticky: 'nsew'

		@return_only = TkCheckButton.new(top,
			text: 'Return Lables Only',
      variable: $cb
#      height(2)
		).grid row: 2, column: 0, columnspan: 2, sticky: 'nsew'

		@default_printer = TkCheckButton.new(top,
			text: 'Print to Default Printer',
      variable: $dp
#      height(2)
		).grid row: 2, column: 4, columnspan: 2, sticky: 'nsew'

    @textbox = TkText.new(top,
      width: 18,
      height: 10,
      borderwidth: 1
		).grid row: 3, column: 2, columnspan: 2, sticky: 'nsew'

#    @textbox.insert 'end', "OR0001359592\nOR0001311282"

    bar = TkScrollbar.new(top).grid row: 3, column: 3, sticky: 'nse'

    @textbox.yscrollcommand(proc { |*args| bar.set(*args)})
    bar.command(proc { |*args| @textbox.yview(*args)}) 

    @lbl = TkLabel.new(top,
      text: '',
      height: 1
		).grid row: 4, column: 0, columnspan: 6, sticky: 'ew'

    @lbl2 = TkLabel.new(top,
      text: 'Waiting for User Input...',
      borderwidth: 1,
      height: 2,
      relief: 'sunken' 
		).grid row: 5, column: 0, columnspan: 6, sticky: 'ew'
 
    top.pack('fill'=>'both', 'side' =>'top')
  end
  
   # Display the GUI
  def run
    Tk.mainloop
  end
end