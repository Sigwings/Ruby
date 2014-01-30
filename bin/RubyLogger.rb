require_relative 'Directory'
require_relative 'RegistryTools'

class RubyLogger

  include Directory
  extend RegistryTools
  
  DEFAULT_FILE = "#{ documents_path }\\Ruby Logs\\#{ File.basename( $0, '.*' ) }.log".freeze
  
  attr_accessor :filename, :orig_std_out
  
  def initialize( filename = DEFAULT_FILE )
  
    self.filename = check_dir_path(filename)
    clear
    
  end

  def sync
  
    self.orig_std_out = STDOUT.clone #Make a record of the default console output to return to it later
    $stdout.reopen( filename, 'w' ) #Create / overwrite logfile
    $stdout.sync = true #Allow interception of console output
    $stderr.reopen( filename ) #Pass errors to logfile

    self
  end
  
  def unsync
  
    $stdout.reopen( orig_std_out )
    $stdout.sync = true 
    $stderr.reopen( orig_std_out ) 
    
    self
  end
  
  def log( msg )
  
    File.open( filename, 'a') { |f| f.puts msg }
    
  end
  alias puts log
  
  def path

    File.dirname( filename )
    
  end
  
  def clear
  
    File.write( filename, '' )
    
  end
  
end