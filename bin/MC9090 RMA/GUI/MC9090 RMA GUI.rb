class MC9090RMA_Gui

  attr_accessor :engineering

  def initialize

    @lbllength = 70
  
    root = TkRoot.new(
      title: 'Waitrose MC9090/MC9091 GUI',
      background: 'SystemWindow'
    )
    
    top = TkFrame.new(root).pack(fill: 'both', expand: true)
    
    @butl = TkButton.new(top,
      text: 'Start',
      width: 17,
      height: 2,
      command: proc {go_go_go}   
    ).grid row: 0, column: 0, columnspan:  2
    
    @butm=TkButton.new(top,
      text: '',
      state: 'disabled',
      width: 22,
      height: 2,
      command: proc {go_go_go}
    ).grid row: 0, column: 2, columnspan: 2, sticky: 'ew'

    @butr=TkButton.new(top,
      text: 'Close', 
      width: 17,
      height: 2,
      command: proc{ engineering.driver.close unless engineering.nil? rescue nil ;exit}
    ).grid row: 0, column: 4, columnspan: 2

    @lbl = TkLabel.new(top,
      width: 54,
      height: 1
    ).grid row: 1, column: 0, columnspan: 6, sticky: 'ew'

    @textbox = TkText.new(top,
      width: 25,
      height: 15,
      borderwidth: 1
    ).grid row: 2, column: 2, columnspan: 2, sticky: 'nsew'

#    @textbox.insert 'end', 'CNTX0001112081  7095629'
    
    bar = TkScrollbar.new(top).grid row: 2, column: 4, sticky: 'nsw'

    @textbox.yscrollcommand(proc { |*args| bar.set(*args)})
    bar.command(proc { |*args| @textbox.yview(*args)}) 

    @lbl1 = TkLabel.new(top,
      width: 54,
      height: 1
    ).grid row: 3, column: 0, columnspan: 6, sticky: 'ew'

    @lbl2 = TkLabel.new(top,
      text: 'Waiting for User Input...',
      borderwidth: 1,
      width: 54,
      height: 2,
      relief: 'sunken' 
    ).grid row: 4, column: 0, columnspan: 6, sticky: 'ew'
    
  end # End initialize

  def run #Make it go!
    Tk.mainloop
  end #End run

end # End Class MC9090RMA_Gui