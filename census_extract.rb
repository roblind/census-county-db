#!/usr/bin/ruby

#= US Census County Statistics Extract for Database
#
# Author: Rob Lind
# Language: Ruby --ver 1.8.7
#
# This application will extract data from US Census site for each county in the US and produce INSERTs for database table.
#  For each record in the input file US_FIPS_Codes a page hit will be made to US Census site to get that county's statistics.
#  An output file will be created for the range selected at prompt.
#
# Note: this run does not function perfectly but unable to identify why some census pages are not retrieved successfully. I fixed the problems by 
#  extracting the FIPS NOT in the database after full table load (using NOT EXISTS query) and reran those FIPS codes correctly then loading that additional small set.
#  Here is that existential query: select fipscd from fips_st_cnty a where not exists (select fipscd from countystats b where a.fipscd = b.fipscd);
#
#== Directories/Files Required
#* Dir: ../data
#* File: ../data/US_FIPS_Codes.csv [source: www.schooldata.com/pdfs/US_FIPS_Codes.xls]
#
#== To Run
#* Run the program with ruby
#* At prompt enter range xxx-yyy - suggest blocks of approx 500 in order to limit load file sizes
#* Take care not to overlap range values from one run to next or you will end up with duplicate sets of data
#
# See README in Githup repo for full app details - mysql ddl files are noted as well.

require 'open-uri'
require 'net/http'

#class will read page source from Census website given the 5-digit FIPS
class Getpage
  attr_accessor  :response, :respsize
  def initialize(fipscd)
    statecd = fipscd[0,2]
    link = "quickfacts.census.gov"
    sublink = "/qfd/states/#{statecd}/#{fipscd}.html"
    @response = Net::HTTP.get_response(link, sublink) 
    #puts response.code
    @respsize = response.body.size
    @arr = response.body.split('<tr').grep(/shaded/)
  end

  def arr
   @arr
 end
 
end

#test class will read page source from file instead of from Census website
class GetpageTest
  attr_accessor  :response, :jean
  def initialize
    fin = File.join('..','data','page.txt')
	infin = File.open(fin)
	in2fin = infin.read
	puts in2fin.class
	puts in2fin.length
     @arr = in2fin.split('<tr').grep(/shaded/)
  end

  def arr
   @arr
  end
 
end

# simple prompt method
def promptit(*args)
  print args
  gets.chomp
end

# input page range and edit any problems with entry raising argument error thus exiting as necessary
iters = promptit "Enter range xxx-yyy to get this run: "
raise ArgumentError, "You must enter iterations argument" if iters.nil? || iters == ''
raise ArgumentError, "#{iters} is a bogus iterations argument" if iters !~ /^\d{1,4}-\d{1,4}$/
pr = iters.split('-')
fr = pr[0].to_i
to = pr[1].to_i
raise ArgumentError, "#{iters} from is greater than to in range." if fr > to
puts

filein1 = File.join('..','data','US_FIPS_Codes.csv')

startdttm = Time.now.strftime("%Y-%m-%d %H:%M:%S")  # applied in column extract_dttm
puts "Starting at: #{startdttm}"

filenm = 'census-stats-' << iters << '.txt' 
fileout1 = File.join('..','data',filenm)
o = File.open(fileout1,"w+")

# build array and sort for FIPS code input
fipsSet = File.readlines(filein1)
fipsSet.sort! 

puts fipsSet.length.to_s + " records processed"

# build INSERT statenment with columns from table 
insertstr = "INSERT INTO countystats (fipscd, popu_2010, popu_pct_chg_10yr, popu_2000, popu_pct_under5, popu_pct_under18, popu_pct_over65, popu_pct_female, popu_pct_white, popu_pct_black, popu_pct_indig, " 
insertstr += "popu_pct_asian, popu_pct_island, popu_pct_multiracial, popu_pct_hispanic, popu_pct_white_nonhisp, popu_pct_samehome_1yrplus, popu_pct_foreign_born, popu_pct_hsgrad_over25, popu_pct_bachdeg_over25, "
insertstr += "nbr_of_vets, mean_minutes_to_work, housing_units, homeower_pct, housing_units_pct_multiunit, median_val_ownocc, nbr_of_households, persons_per_household, per_cap_inc_past12mths, median_household_inc, "
insertstr += "popu_pct_below_poverty, priv_nonfarm_estabs, priv_nonfarm_employment, priv_nonfarm_employment_pct_chg_9yr, nonemployer_estabs, "
insertstr += "total_firms, black_owned_firms_pct, asian_owned_firms_pct, hispanic_owned_firms_pct, women_owned_firms_pct, "
insertstr += "manufacturer_shipments, wholesale_sales, retail_sales, retail_sales_per_cap, accomo_food_sales, building_permits, fed_spending, area_sq_mi, persons_per_sq_mi  "
insertstr += ") VALUES "
o.puts insertstr
cnt = 0

# iterate the fips set array and build all the insert data values for the range selected at prompt
fipsSet.each do |fs|
  cnt += 1           #
  #break if cnt > 3   #uncomment to test
  
  if cnt < fr
    next
  elsif cnt > to
    break
  end
  
  info = fs.split(",")
  fipscd = "#{info[2]}#{info[3]}".chomp

  f = Getpage.new(fipscd)  #comment to test
  #f = GetpageTest.new     #uncomment to test
  
  if f.respsize > 1000     # check response size to avoid using page results that do not have the full set of stats necessary
	x = f.arr
  else
    puts "#{fipscd} has no information"
	next
  end

  line = "('" << fipscd  << "',"                                              # current run date time 
 
	  aa = x[2].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                     # population 2010
	  line += aa.first.to_s.gsub(/(>|<|,)/, '') << ', '
	  
	  aa = x[3].to_s.scan( /(>-?\d{0,2}\.\d%<)/ )								# population pct change 2000-2010 (may be negative)
	  line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   

	  aa = x[4].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                      # population 2000
	  line += aa.first.to_s.gsub(/(>|<|,)/, '') << ', '
	  
	  aa = x[5].to_s.scan( /(>\d{0,2}\.\d%<)/ )										# population pct under 5 (no negative)
	  if aa.length > 1
		line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

	  aa = x[6].to_s.scan( /(>\d{0,2}\.\d%<)/ )										# population pct under 18 (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

	  aa = x[7].to_s.scan( /(>\d{0,2}\.\d%<)/ )										 # population pct over 65 (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '  
	  else
		line += '0.0, ' 
	  end

	  aa = x[8].to_s.scan( /(>\d{0,2}\.\d%<)/ )										# population pct female (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

	  aa = x[9].to_s.scan( /(>\d{0,2}\.\d%<)/ )										# population pct white (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

	  aa = x[10].to_s.scan( /(>\d{0,2}\.\d%<)/ )									# population pct black (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

	  aa = x[11].to_s.scan( /(>\d{0,2}\.\d%<)/ )									# population pct indig (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

	  aa = x[12].to_s.scan( /(>\d{0,2}\.\d%<)/ )									# population pct asian (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

	  aa = x[13].to_s.scan( /(>\d{0,2}\.\d%<)/ )									# population pct islander (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

	  aa = x[14].to_s.scan( /(>\d{0,2}\.\d%<)/ )									# population pct multirace (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

	  aa = x[15].to_s.scan( /(>\d{0,2}\.\d%<)/ )									# population pct hispanic (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

	  aa = x[16].to_s.scan( /(>\d{0,2}\.\d%<)/ )									# population pct white non-hispanic (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

	  aa = x[17].to_s.scan( /(>\d{0,2}\.\d%<)/ )									# population pct in same home 1yr+ (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

 	  aa = x[18].to_s.scan( /(>\d{0,2}\.\d%<)/ )									# population pct foreign born (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

	  # skip 19 - Language other than English spoken at home, pct age 5+, 2006-2010
	  
 	  aa = x[20].to_s.scan( /(>\d{0,2}\.\d%<)/ )									# population pct highschool grad (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

 	  aa = x[21].to_s.scan( /(>\d{0,2}\.\d%<)/ )									# population pct bachelors degree (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '   
	  else
		line += '0.0, ' 
	  end

	  aa = x[22].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                     	# nbr of vets
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << ', '
	  else
		line += '0, ' 
	  end
	  
	  aa = x[23].to_s.scan( /(>\d{0,2}\.\d<)/ )                               		# mean travel minutes to work
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<)/, '') << ', '
	  else
		line += '0.0, ' 
	  end
	  
	  aa = x[24].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                       	# housing units
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << ', '
	  else
		line += '0, ' 
	  end
	  
	  aa = x[25].to_s.scan( /(>\d{0,2}\.\d%<)/ )                               		# home ownership pct (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '
	  else
		line += '0.0, ' 
	  end
	  
	  aa = x[26].to_s.scan( /(>\d{0,2}\.\d%<)/ )                               		# Percent of housing units in multi-unit structures (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '
	  else
		line += '0.0, ' 
	  end

	  aa = x[27].to_s.scan( /(>\$\d{0,2},?\d{0,3},?\d{3}<)/ )                     # Median value of owner-occupied housing units
	  line += aa.first.to_s.gsub(/(>|<|,|\$)/, '') << ', '
	  
	  aa = x[28].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                       	# households
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << ', '
	  else
		line += '0, ' 
	  end
	  
	  aa = x[29].to_s.scan( /(>\d{0,2}\.\d<)/ )                               		# Persons per household
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<)/, '') << ', '
	  else
		line += '0.0, ' 
	  end

	  aa = x[30].to_s.scan( /(>\$\d{0,2},?\d{0,3},?\d{3}<)/ )                     # Per capita income
	  line += aa.first.to_s.gsub(/(>|<|,|\$)/, '') << ', '
	  
	  aa = x[31].to_s.scan( /(>\$\d{0,2},?\d{0,3},?\d{3}<)/ )                     # Household income
	  line += aa.first.to_s.gsub(/(>|<|,|\$)/, '') << ', '
	  
	  aa = x[32].to_s.scan( /(>\d{0,2}\.\d%<)/ )                               	  # Percent below poverty (no negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '
	  else
		line += '0.0, ' 
	  end

	  aa = x[34].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                       	# private non-farm establishments (single-location companies)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << ', '
	  else
		line += '0, ' 
	  end
	  
	  aa = x[35].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                       	# Private non-farm employment
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << ', '
	  else
		line += '0, ' 
	  end
	  
	  aa = x[36].to_s.scan( /(>-?\d{0,2}\.\d%<)/ )								# Private non-farm employment, percent change 2000-2009  (may be negative)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '
	  else
		line += '0.0, ' 
	  end

	  aa = x[37].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                       	# Non-employer establishments
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << ', '
	  else
		line += '0, ' 
	  end
	  
	  aa = x[38].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                       	# Total number of firms (multi-location companies)
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << ', '
	  else
		line += '0, ' 
	  end
	  
	  aa = x[39].to_s.scan( /(>\d{0,2}\.\d%<)/ )								# Black-owned firms
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '
	  else
		line += '0.0, ' 
	  end
	  
	  # skip x[40] - native american owned firms (very small scale)
	  
	  aa = x[41].to_s.scan( /(>\d{0,2}\.\d%<)/ )								# Asian-owned firms
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '
	  else
		line += '0.0, ' 
	  end

	  # skip x[42] - islander owned firms (very small scale)
	  
	  aa = x[43].to_s.scan( /(>\d{0,2}\.\d%<)/ )								# Hispanic-owned firms
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '
	  else
		line += '0.0, ' 
	  end

	  aa = x[44].to_s.scan( /(>\d{0,2}\.\d%<)/ )								# Women-owned firms
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|%)/, '') << ', '
	  else
		line += '0.0, ' 
	  end

	  aa = x[45].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                       	# Manufacturer shipments
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << '000, '                   #(extract in thousands so make full number)
	  else
		line += '0, ' 
	  end
	  
	  aa = x[46].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                       	# Wholesale sales
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << '000, '                   #(extract in thousands so make full number)
	  else
		line += '0, ' 
	  end
	  
	  aa = x[47].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                       	# Retail sales
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << '000, '                   #(extract in thousands so make full number)
	  else
		line += '0, ' 
	  end

	  aa = x[48].to_s.scan( /(>\$\d{0,2},?\d{0,3},?\d{3}<)/ )                       # Per capita retail sales
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,|\$)/, '') << ', '                   #(extract in thousands so make full number)
	  else
		line += '0, ' 
	  end
	  
	  
	  aa = x[49].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                       	# Accomodation/food service sales
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << '000, '                   #(extract in thousands so make full number)
	  else
		line += '0, ' 
	  end

	  aa = x[50].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{1,3}<)/ )                       	# Building permits
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << ', '                   
	  else
		line += '0, ' 
	  end
	  
	  aa = x[51].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{3}<)/ )                       	# Federal spending
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << ', '                   
	  else
		line += '0, ' 
	  end
	  
	  aa = x[53].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{1,3}\.\d{0,2}<)/ )                 # Area square miles
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') << ', '
	  else
		line += '0.0, ' 
	  end
	  
	  aa = x[54].to_s.scan( /(>\d{0,2},?\d{0,3},?\d{1,3}\.\d{0,2}<)/ )                 # Persons per square mile
	  if aa.length > 1
	    line += aa.first.to_s.gsub(/(>|<|,)/, '') 
	  else
		line += '0.0 ' 
	  end
	  
    line += "),\n"
    o.puts line

    line = ""

   #sleep(2) # uncomment for 2 second delay between fips codes

end

# replace last comma with semicolon for insert block
x = o.pos - 3
o.seek(x, IO::SEEK_SET)
o.putc ";"   

# close output
o.close

# display finish time
puts "Ending at: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}"