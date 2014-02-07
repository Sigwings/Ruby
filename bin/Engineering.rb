require_relative 'RDT'
require_relative 'MechReporter'
#require_relative 'Unallocate'

class Engineering < RDT

  attr_accessor :gui, :errors#, :unallocate

  def initialize( gui )
    self.gui = gui
    self.errors = []
#    self.unallocate = Unallocate.new
    super()
  end

  def ext_all_rma( array )
    errors.clear
    array.each { |args| rma_external( *args ) }
#    puts 'Finished Sequence, Closing Firefox'
#    driver.quit
  end

  def close_job( args={jobs: 'CNTX', status:'Repair Complete', notes:'NFF'} )
    
  end
  
  def rma_external( cntx, rma )
  
     result = update_job(
      cntx, 
      { 
        status: 'On Hold - External Repair',
        notes: 'Sent to External Repair on RMA #' + rma 
      }
    )
    
    ( errors << [ cntx, rma ] ) unless result
  end
  
  def update_job( cntx, args )
    cntx = MechReporter.cntxify cntx.upcase
    args = { supervisor: false, status: nil, reason: nil, sla: nil, ber: nil, part: nil, qty: nil, notes: nil }.merge( args )
  
    start( true, false, true ) if driver.nil?
    
    #Login and Open Engineers/Supervisor Console
#    puts 'Logging in to Engineers Screen'
    login( args[:supervisor] ? 'SupervisorConsole' : 'EngineersConsole' ) unless driver.url.include?( args[:supervisor] ? 'pid=842' : 'pid=565' )
    
    driver.table(:class => 'jobstable').wait_until_present(2) rescue puts 'No jobs found in jobs table, attempting to continue.'

    unless driver.table(:id => 'jobstable').td(:text => cntx).exists?
      # Free up the job
 #     unallocate.unallocate( cntx )
      # Allocate
      driver.button(:id, 'getJob').when_present.click

      puts 'Waiting for Allocation Screen'
      driver.table(:class => 'unallocatedjobs').wait_until_present
      
      begin #Trap jobs that don't show up in the unallocated list
        puts 'Clicking the link for ' + cntx + ' in unallocated list'
        driver.table(:class => 'unallocatedjobs').td(:text, cntx).parent.button(:index,0).click
      rescue
        puts 'Unable to locate ' + cntx + ' in unallocated jobs list'
        return false
      end
      
      puts 'Bypassing confirm message'
      driver.alert.ok
      driver.alert.close
 
      puts 'Waiting for the job to appear in the jobs table'
      driver.table(:class => 'jobstable').td(:text => cntx).wait_until_present
 
    end
    
    puts 'Clicking the link for ' + cntx
    driver.table(:id => 'jobstable').td(:text => cntx).parent.links.first.fire_event('onclick')

    #Start work
    if driver.div(:class => 'currentjob').button(:value => 'Start Work').present?
      puts 'Clicking on Start Work'
      driver.div(:class => 'currentjob').button(:value => 'Start Work').click 
    end

    #Set Status
#    puts 'Setting Status to ' + args[:status]
    driver.select_list(:id => 'status').when_present.select(args[:status])
    
    #Set Notes Text
#    puts 'Setting Job Text to ' + args[:notes]
		driver.text_field(:id,'tnotes').when_present.set(args[:notes])
    
#		return true  #Don't deactivate this line until you're sure you've got it right!
		
		driver.button(:id, 'submit').click
		case args[:status]
    when 'Returned at Customers Request' , 'Beyond Economical Repair', 'Repair Complete'
			driver.alert.ok
			driver.alert.close
			puts 'Submit and bypass any complete message.'
    else
      driver.alert.close
		end

    true
    
  rescue
    puts %Q|Fatal error occurred:\n#{$!}\n\nDebugging Information:\n#{$@.first}|,'Error' #Logfile output
    return false
    
  end
  
end #End Engineering

