require 'rubygems'
require 'csv'
require 'json'
require 'net/http'
require 'net/https'
require 'uri'
require 'time'
require 'date'



# Here you can specify which Keen Event Collections should be used for the databed (where to send events) 
# This only applies if you send the data to Keen. There is another option below to output the events to file. 
collection = "purchased_items"
projectID = "518d6e0b38433141b8000003"
key = "adeb825e465fdc90330b4a1aa8ed242782382733707f14493bd672d59b302668fbba025762c264c731621a18ab5ff1f964f35418c9f7a8008613fcd0a3e2d94fe99cf9a7ac7b280625d77103e457e15f77d804ddff244472e1c210964bcd1e11b7aed605063d32f627ff4f58b93859fc"



###########################
# Generate Event Data #
###########################
# Convert a CSV file to JSON

bulk_events=[]

csv_text = File.read('purchases.csv')
csv = CSV.parse(csv_text, :headers => true)

csv.each do |row|
  
 puts row[0]
 # require 'ruby-debug'; debugger;
 # puts Time.parse(row[0])
 puts timestamp = DateTime.strptime(row[0], "%m/%d/%y").to_date.iso8601
    eventhash = {
               :keen => {
                  :timestamp => timestamp,
                  },
               :user => {
                   :name => {
                       :first => row[1],
                       :last => row[2],
                       :full => row[3],
                       }
                   },       
               :item => {
                   :name => row[4],
                   :price => row[5].to_f
                   },
               :payment_method => row[6],
               }
  
  bulk_events << eventhash
  
end

puts bulk_events

######################################## 
# Send all the results to Keen
########################################

bulk_results = {"purchases" => bulk_events}
                           
        # Required info to post events in Keen
        uri = URI.parse("http://api.keen.io/")
        http = Net::HTTP.new(uri.host, uri.port)

        bulk_results_post_request = Net::HTTP::Post.new("/3.0/projects/#{projectID}/events")
        bulk_results_post_request.add_field("Authorization", key) 
        bulk_results_post_request.add_field("Content-Type", "application/json")
        
        # Convert the ruby hash to json format
        bulk_results_post_request.body = bulk_results.to_json
        response = http.request(bulk_results_post_request)
        
        puts response.body