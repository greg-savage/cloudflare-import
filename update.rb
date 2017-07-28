require 'rest-client'
require 'json'
require 'logger'
# Grab some details from local environment variable:
email = ENV['CLOUDFLARE_EMAIL']
key = ENV['CLOUDFLARE_KEY']
$LOG = Logger.new('update.log')
zone_ignore = ["automotivegpssolutions.com","automotivegpssolutions.net","autorentalgps.co","autorentalgps.com","autorentalgps.net","contractorgps.co","contractorgps.me","contractorgps.net","contractorsgps.co","contractorsgps.net","gogreengps.co","gogreengps.com","gogreengps.net","infotracegps.net"]
zone_list_url = 'https://api.cloudflare.com/client/v4/zones'
zone_update_url_base = 'https://api.cloudflare.com/client/v4/zones/'
zones_complete = 0

# Start loop of collecting zone ID from zone_file
  begin
    request = RestClient::Request.new(  # Setup the request
        :method => :get,
        :url => zone_list_url,
        :headers => {
        :x_auth_email => email,
        :x_auth_key => key,
        :content_type => 'json',
        :params => {:per_page => '500'}})
        
    response = request.execute
    
  rescue RestClient::ExceptionWithResponse => err
    $LOG.error err.response  # Log the Failed Results of the Zone Creation
    $error = true
    # next
  end
  #$LOG.debug(response) # Log the Success Results of the Zone Creation

  zones = JSON.parse(response)['result']   # Save the Zone ID
  
  zones.each do |z|
    # puts "Name: #{z['name']}, ZoneID:#{z['id']}" unless zone_ignore.include?(z['name'])
    # puts z['name'] if z['name'] == 'wedgegps.net'
    zone_update_url = zone_update_url_base + z['id']
    payload =  {:plan => {:id => '94f3b7b768b0458b56d2cac4fe5ec0f9'}}.to_json
    unless zone_ignore.include?(z['name'])
        puts zone_update_url
        puts z['name']
        begin
            response = RestClient.patch zone_update_url, {'plan' => {'id' => '94f3b7b768b0458b56d2cac4fe5ec0f9'}}.to_json, {content_type: :json, accept: :json, x_auth_email: email, x_auth_key: key} 
        rescue RestClient::ExceptionWithResponse => err
            $LOG.error err.response  # Log the Failed Results of the Zone Creation
            $error = true
        # next
        end
        zones_complete += 1
        $LOG.debug(z['name'])
        # $LOG.debug(response) # Log the Success Results of the Zone Creation
    end    
  end 
puts zones_complete