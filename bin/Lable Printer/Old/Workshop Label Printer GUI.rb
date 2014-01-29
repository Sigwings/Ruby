require 'tk'

class Lable_Gui

  def gui_puts(str)
   
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


  def initialize
#    fred = 'Goodbye, Cruel World!'
    b = proc {bexit}
#    p = proc {gui_puts fred}
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
      text 'Show It'
			command proc {go_go_go}
     # command go
      width(23)
      height(2)
      grid('row' => 0, 'column' => 0, 'columnspan' => 2, 'sticky'=>'nsew')
    end
    
    @butm=TkButton.new(top) do
      text 'Open Report'
#      state 'disabled'
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

end # End Class Lable_Gui

Lable_Gui.new

Tk.mainloop

=begin

  def dataEntryAsList
    if (@TextField.get(1.0, 'end').chomp.strip == "") then return false end
    #Pull the textbox into the listbox
    @ListBox.delete(0,'end')
    createArray(@TextField.get(1.0, 'end')).each{|i| @ListBox.insert 'end', i}
    @ListBox.configure(:background => "white")
    @ListBoxTotal.configure :text=>"Total: " + @ListBox.size.to_s
    File.open("list.txt","w") {|listfile| listfile.write(@TextField.get(1.0, 'end')) }
  end #End dataEntryAsList

=end