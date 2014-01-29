class Unallocate

  UnallocateLinkBase = 'http://centrex.redetrack.com/redetrack/bin/unassignjob.php?si=222&dep=Centrex+Computing+Services&bc=&seq=1&confirmonly=y&store=y&create_box_row_on_route=y'
  
  attr_accessor :query, :m
  
  def initialize
    
    # Create the query object
    self.query = RDTQuery.new UnallocateLinkBase
    
    # Create the object which links into RDT
    self.m = MechReporter.new.login
    
  end
  
  def unallocate( cntx )
   
    # prepare the uri
    query[ 'bc' ] = MechReporter.cntxify( cntx )
    
    # send the request to the server
    m.agent.get query
 
  end
  
end