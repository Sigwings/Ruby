require 'win32ole'
require 'dl'

module WinBoxes

  # button constants
  VBOKONLY = 0
  VBOKCANCEL = 1
  VBABORTRETRYIGNORE = 2
  VBYESNO = 4

  # style constants
  VBCRITICAL = 16 #Displays Critical Message icon.
  VBQUESTION = 32 #Displays Warning Query icon.
  VBEXCLAMATION = 48 #Displays Warning Message icon.
  VBINFORMATION = 64 #Displays Information Message icon.
  VBSYSTEMMODAL = 4096 #Makes messagebox system modal

  # return code constants
  VBOK = 1
  VBCANCEL = 2
  VBABORT = 3
  VBRETRY = 4
  VBIGNORE = 5
  VBYES = 6
  VBNO = 7
  
  def inputbox(message, title = '', default = '')
    sc = WIN32OLE.new('ScriptControl')
    sc.language = 'VBScript'
    sc.eval(%Q|Inputbox("#{message}", "#{title}", "#{default}")|)
  end

  def popup(message,msgtitle="FYI",delay=1)
    WIN32OLE.new('WScript.Shell').popup(message, delay, msgtitle)
  end

  def msgbox(txt, title='Message', buttons=VBOKONLY)
    user32 = DL.dlopen('user32')
    msgbox = DL::CFunc.new(user32['MessageBoxA'], DL::TYPE_LONG, 'MessageBox')
    r, _ = msgbox.call([0, txt, title, buttons].pack('L!ppL!').unpack('L!*'))
    r
  end

  def errbox( txt )
    puts txt
    msgbox txt, 'Error', VBCRITICAL + VBSYSTEMMODAL
  end

end