require 'rest-client'
require 'json'
require 'logger'

#### Configure ####
zone_dir = "<directory with zone>"
#### Configure ####


# Grab some details from somewhere:
email = ENV['CLOUDFLARE_EMAIL']
key = ENV['CLOUDFLARE_KEY']

# Set up the connection:

$LOG = Logger.new('import.log')


$LOG.debug"Beginning Import"
# Import Zones from directory
Dir.chdir(zone_dir)
zones_from_folder = Dir.glob("*")
puts zones_from_folder
zones_from_folder.each do |z|
  $error = false
  zone = z.chomp('.zone')
  puts "Creating #{zone}"
  $LOG.debug("Creating Zone: #{zone}")

  payload =  {name: zone}
  zone_add_url = 'https://api.cloudflare.com/client/v4/zones'
  begin
    response = RestClient.post zone_add_url, payload.to_json, {content_type: :json, accept: :json,x_auth_email: email,x_auth_key: key}
  rescue RestClient::ExceptionWithResponse => err
    $LOG.error err.response  # Log the Failed Results of the Zone Creation
    $error = true
    next
  end
  $LOG.debug(response) # Log the Success Results of the Zone Creation

  zone_id = JSON.parse(response)['result']['id']   # Save the Zone ID


  # Import the Zones
  $LOG.debug("Importing DNS Records for: #{zone}")
  full_file_path = zone_dir + '/' + z # Create full path to zone file
  file = File.open(full_file_path) # Import Zone file as an object

  dns_import_url = "https://api.cloudflare.com/client/v4/zones/#{zone_id}/dns_records/import" # Set the URL for the DNS Import


  begin
    request = RestClient::Request.new(  # Setup the request
        :method => :post,
        :url => dns_import_url,
        :headers => {
        :x_auth_email => email,
        :x_auth_key => key},
        :payload => {
            :multipart => true,
            :file => File.new(file, 'rb')  # Reference the zone file to upload
        })
    response = request.execute
  rescue RestClient::ExceptionWithResponse => err
    $LOG.error err.response
    next
  end
  $LOG.debug(response)
  $LOG.debug("Finished :: #{zone}")

end