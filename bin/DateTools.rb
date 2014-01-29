require 'date'

#
# Calculates commonly used Dates, making other code more human-readable
#

module DateTools
  
  #
  # The last Date of the month prior to today's date.
  #
  # @return [Date]
  #
  
  def end_of_last_month
    end_of_this_month << 1
  end

  #
  # The end of month of the given Date
  #
  # @param [Date] date the date to use as a starting point
  # @return [Date]
  #
  
  def end_of_month( date )
    ( start_of_month( date ) >> 1 ) - 1
  end

  #
  # The last Date of the current month
  #
  # @return [Date]
  #
  
  def end_of_this_month
    end_of_month( Date.today )
  end
  
  #
  # The last workday including or prior to the given date, with an optional array of working days (1 is Monday)
  #
  # @param [Date] date the date to use as a starting point
  # @param [Array<Fixnum>] working_days the array of weekdays (1-7) included in a work schedule
  # @return [Date] the first working date found going backwards from the given date (inclusive)
  #

  def last_workday( date, working_days = [1,2,3,4,5] )
    date-=1 until working_days.include?( date.cwday )
    date
  end
  
  #
  # The first Date of the month prior to today's date.
  #
  # @return [Date]
  #
  
  def start_of_last_month
    start_of_this_month << 1
  end
  
  #
  # The start of month of the given Date
  #
  # @param [Date] date the date to use as a starting point
  # @return [Date]
  #

  def start_of_month( date )
    date - date.day + 1
  end
  
  #
  # The first Date of the current month
  #
  # @return [Date]
  #
  
  def start_of_this_month
    start_of_month( Date.today )
  end

  #
  # Convert a string into a Date object
  #
  # @param [String] input the string to extract the Date from
  # @return [Date]
  #

  def string_to_date( input )
    Date.strptime( input.tr( '/', '-' ) ,'%Y-%m-%d' ) rescue nil
  end
  
  #
  # Today's Date
  #
  # @return [Date]
  #
  
  def today
    Date.today
  end

  #
  # Yesterday's Date
  #
  # @return [Date]
  #
  
  def yesterday
    Date.today - 1
  end
  
end