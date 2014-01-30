class LabelGui

  attr_accessor :label_type, :selected_printer, :return_labels, :textbox, :msg, :lbllength, :status_label, :log_button, :print_button, :close_button, :logger

  # Build the GUI
  def initialize

    self.logger = RubyLogger.new.sync
    self.lbllength = 50
    self.label_type = TkVariable.new(1)
    self.return_labels = TkVariable.new(false)
    self.selected_printer = TkVariable.new('')

		root = TkRoot.new(
			title: 'Label Printer',
      background: 'SystemWindow'
    )
   
		top = TkFrame.new(root).pack('fill'=>'both', 'expand'=>true)
    
    self.print_button = TkButton.new(top,
      text: 'Print',
      width: 23,
      height: 2,
      command: proc {go_go_go}
		).grid row: 0, column: 0, columnspan: 2, sticky: 'nsew'
    
    self.log_button = TkButton.new(top,
      text: 'Open Report',
      width: 23,
      height: 2,
      command: proc {open_log}
		).grid row: 0, column: 2, columnspan: 2, sticky: 'nsew'

    self.close_button = TkButton.new(top,
      text: 'Close', 
      width: 23,
      height: 2,
      command: proc{ exitprog }
		).grid row: 0, column: 4, columnspan: 2, sticky: 'nsew'

		TkRadiobutton.new(top,
      text: 'Centrex Label',
			variable: label_type,
			value: 1
		).grid row: 1, column: 0, columnspan: 2, sticky: 'nsew'

    TkRadiobutton.new(top,
      text: 'Stock Label',
			variable: label_type,
			value: 2
		).grid row: 1, column: 2, columnspan: 2, sticky: 'nsew'

    TkRadiobutton.new(top,
      text: 'Repair Label',
			variable: label_type,
			value: 3
		).grid row: 1, column: 4, columnspan: 2, sticky: 'nsew'

    TkLabel.new(top,
      text: 'Printer',
      height: 1
		).grid row: 2, column: 4, columnspan: 2, sticky: 'ew'

		TkCheckButton.new(top,
			text: 'Return Labels Only',
      variable: return_labels
		).grid row: 3, column: 0, columnspan: 2, sticky: 'nsew'

    Tk::Tile::TCombobox.new(top,
      textvariable: selected_printer,
      state: 'readonly',
      width: 24,
      values: get_printers # Printer list routine
    ).grid row: 3, column: 4, columnspan: 2, sticky: 'nsw'

    self.textbox = TkText.new(top,
      width: 18,
      height: 10,
      borderwidth: 1
		).grid row: 4, column: 2, columnspan: 2, sticky: 'nsew'

    bar = TkScrollbar.new(top).grid row: 4, column: 3, sticky: 'nse'

    textbox.yscrollcommand(proc { |*args| bar.set(*args)})
    bar.command(proc { |*args| textbox.yview(*args)}) 

    TkLabel.new(top,
      text: '',
      height: 1
		).grid row: 5, column: 0, columnspan: 6, sticky: 'ew'

    self.status_label = TkLabel.new(top,
      text: 'Waiting for User Input...',
      borderwidth: 1,
      height: 2,
      relief: 'sunken' 
		).grid row: 6, column: 0, columnspan: 6, sticky: 'ew'
 
    top.pack('fill'=>'both', 'side' =>'top')
    
  end
  
  # Display the GUI
  def run
  
    label_type.value = ( get_regkey_val( 'LblPtr Type' ) || 1 ).to_i
    selected_printer.value = get_regkey_val( 'LblPtr Printer' ) || get_default_printer
    return_labels.value = ( get_regkey_val( 'LblPtr Return' ) || 0 ).to_i
  
    Tk.mainloop
    
  end
  
end