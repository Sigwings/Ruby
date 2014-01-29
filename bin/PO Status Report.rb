require_relative 'MechReporter'
include DateTools

# This makes later code less confusing
XLUP = -4162

# Grab Excel
excel = WIN32OLE.connect 'excel.application'

# We should be on the target sheet
wb = excel.activeworkbook
status_sheet = wb.activesheet

# Make sure it's the right sheet
#wb.name =~ /open po status|open pr report/i || fail( ArgumentError, 'Unable to find "Open PO status"' )
status_sheet.range('A1').value == 'Purchase Requisition' || fail( ArgumentError, 'Active Sheet A1 is not "Purchase Requisition"' )

# Set up the output sheets
po_sheet = ( wb.sheets(2) rescue wb.sheets.add({'after'=>wb.sheets(wb.sheets.count)}) )
job_sheet = ( wb.sheets(3) rescue wb.sheets.add({'after'=>wb.sheets(wb.sheets.count)}) )
hist_sheet = ( wb.sheets(4) rescue wb.sheets.add({'after'=>wb.sheets(wb.sheets.count)}) )

# Reselect the first sheet in case any were added and stole focus
status_sheet.select unless wb.activesheet == status_sheet

# Name the sheets
po_sheet.name, job_sheet.name, hist_sheet.name = %w(PO Job Hist)

# Gather the PO numbers
po_numbers = status_sheet.range( 'A2:A' + status_sheet.range( 'A' + status_sheet.rows.count.to_s ).end(XLUP).row.to_s ).value.flatten.sort.uniq

# Create the reporter
m = MechReporter.new

# Create a PO report
q = RDTQuery.new('http://centrex.redetrack.com/redetrack/bin/report.php?report_locations_list=T&select_div_last_shown=&report_limit_to_top_locations=N&action=custordtrack&num=PR063183&num_raisedtrack=&status=&pod=A&status_code=&itemtype=&location=&value_location=&tf=current&days=365&befaft=b&dd=16&mon=12&yyyy=2013&fdays=1&fbefaft=a&fdd=16&fmon=12&fyyyy=2013&ardd=16&armon=12&aryyyy=2012').set_dates(today)

# Run the PO Report
po_data = m.run_keyed( q, po_numbers )

# Extract the CNTX numbers
job_refs = po_data.ch( 'Bar Code' ).each_wh.to_a.uniq.sort

# Drop the PO data into the sheet
po_data.parent.dump_to_sheet( po_data.to_a, po_sheet )

# Align the sheet so the columns are wide enough
po_sheet.cells.entireColumn.autoFit

# Create a Job Report
q = RDTQuery.new('http://centrex.redetrack.com/redetrack/bin/centrexticketreport.php?reptype=job&item_type=&barcode=CNTX0001806812&engineer=&serial=&custordref=&includeuaj=Yes&groupbyjob=Yes&berhandle=Y&account=&clientnum=&status=-1&statuscurrent=N&days=365&nolimit=0&range=daterange&befaft=b&dd=16&mon=12&yyyy=2013&depot=Centrex+Computing+Services&action=ticketreport&go=Search').set_dates(today)

# run the Job Report
job_data = m.run_keyed( q, job_refs, 'barcode' )

# Drop the Job data into the sheet
job_data.parent.dump_to_sheet( job_data.to_a, job_sheet )

# Create a Hist Report
q = RDTQuery.new('http://centrex.redetrack.com/redetrack/bin/centrexticketreport.php?reptype=hist&item_type=&barcode=CNTX0001380912&engineer=&serial=&custordref=&groupbyjob=Yes&berhandle=D&account=&clientnum=&status=-1&statuscurrent=N&days=365&nolimit=0&range=daterange&befaft=b&dd=16&mon=12&yyyy=2013&depot=Centrex+Computing+Services&action=ticketreport&go=Search').set_dates(today)

# run the Hist Report
hist_data = m.run_keyed( q, job_refs, 'barcode' )

# Drop the Hist data into the sheet
hist_data.parent.dump_to_sheet( hist_data.to_a, hist_sheet )

# Convert the 'Order Raised' DateTimes into Dates
po_sheet.range( 'E2:E' + po_sheet.range( 'C' + po_sheet.rows.count.to_s ).end(XLUP).row.to_s ).each { |cell| cell.value = cell.text.split.first }

# Do the lookup stuff here?

# Go back to the first sheet
wb.sheets(1).select

# Make everything pretty
[ po_sheet, job_sheet, hist_sheet ].each { |s| hist_data.workbook.make_sheet_pretty( s ) }