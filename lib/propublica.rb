class ProPublica
  require 'net/http'
  require 'json'


  attr_accessor :api_key

  def initialize(api_key)
    @api_key = api_key
  end

  def about
    puts "Hello! This is a Ruby wrapper for the ProPublica API.\n" +
         " Please get started by entering your API KEY in a new ProPublica instance creation (e.g., client = ProPublica.new(YOUR_KEY_HERE))\n" +
         "Good luck, citizen!"
  end

  def config(api_key)
    @api_key = api_key
  end

  def get_response_from_API(url)
    if @api_key != nil && @api_key.length > 10 # TODO: Add validation.
      uri = URI.parse(url)

      request = Net::HTTP::Get.new(uri)
      request["X-Api-Key"] = @api_key
      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end
			response
    else
      raise "Please configure your API key."
    end
  end

  def get_senate_members(congress_number)
    # Returns an array of senate member hash objects.
    url = "https://api.propublica.org/congress/v1/#{congress_number}/senate/members.json"

		response = self.get_response_from_API(url)
    raw_senate_members_data = JSON.parse(response.body)
    return deep_symbolize_keys(raw_senate_members_data)
  end

  def get_house_members(congress_number)
    # Returns an array of house member hash objects.
    url = "https://api.propublica.org/congress/v1/#{congress_number}/house/members.json"

    response = self.get_response_from_API(url) 
    raw_house_members_data = JSON.parse(response.body)
    return deep_symbolize_keys(raw_house_members_data)
  end

  def get_member(congressional_id)
    url = "https://api.propublica.org/congress/v1/members/#{congressional_id}.json"

    response = self.get_response_from_API(url)
    raw_member_data = JSON.parse(response.body)
    return raw_member_data["results"].first # NOTE: This is idiosyncratic per endpoint structure.
  end

  def get_recent_votes(chamber, offset=nil)
    url = "https://api.propublica.org/congress/v1/#{chamber}/votes/recent.json#{!offset.nil? ? '?offset=' + offset : ''}"

    response = self.get_response_from_API(url)
    vote_data = JSON.parse(response.body)
    deep_symbolize_keys vote_data
	end

  private

  def deep_symbolize_keys(hash)
    return hash.reduce({}) do |memo, (k, v)|
      memo.tap { |m| m[k.to_sym] = deep_symbolize_keys(v) }
    end if hash.is_a? Hash
    
    return hash.reduce([]) do |memo, v| 
      memo << deep_symbolize_keys(v); memo
    end if hash.is_a? Array
    
  	hash
	end
end
