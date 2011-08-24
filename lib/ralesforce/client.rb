require 'rest_client'
require 'json'
require 'libxml'
require 'savon'
require 'uri'

module Ralesforce

  class Client
  
    @@host = "http://login.salesforce.com"
    @@partner_path = "/services/Soap/u/"
    @@oauth_path = "/services/oauth2/token"
    @@rest_path = "/services/data/"
    @@version = "22.0"
    @@filename = File.expand_path("~/.ralesforce/.logininfo")
    @@access_token
  
    def initialize
      # read the login info and store in class or instance vars
      read_login_info
    end
      
    def login
      #Savon::configure do |config|
        #config.log = false
      #end
      username, password = get_username_and_password
      puts "Logging in"      
      client = Savon::Client.new do
        wsdl.document = File.expand_path("../partner.wsdl", __FILE__)
        wsdl.endpoint = "#{@@host}#{@@partner_path}#{@@version}"
      end
      response = client.request :login do
        soap.body = { :username => username, :password => password }
      end
      result = response.to_hash[:login_response][:result]
      @@access_token = result[:session_id]
      server_url = result[:server_url]   
      puts "Successfully logged in as #{username}"
      uri = URI.parse(server_url)
      @@host = "#{uri.scheme}://#{uri.host}:#{uri.port}"
      store_login_info
    end

    def get_username_and_password
      print "Enter username: "
      STDOUT.flush
      username = STDIN.gets
      print "Enter password: "
      STDOUT.flush
      system "stty -echo"
      password = STDIN.gets
      system "stty echo"
      username.strip!
      password.strip!
      return username, password
    end
  
    def set_env(params)
      @@host = params["host"] ? params["host"] : @@host
      @@access_token = params["access_token"] ? params["access_token"] : @@access_token
      @@version = params["api_version"] ? params["api_version"] : @@version
      puts "the access token #{@@access_token}"
      store_login_info
    end
  
    def store_login_info
      puts "Storing login info to #{@@filename}..."
      logininfo = { "host" => @@host, "access_token" => @@access_token, "api_version" => @@version }
      File.open(@@filename, "w") { |f| f.write(logininfo.to_json) }
    end
  
    def read_login_info
      if File.exists?(@@filename)
        s = IO.read(@@filename)
        login_info = JSON s
        @@access_token = login_info["access_token"]
        @@host = login_info["host"] ? login_info["host"] : @@host
        @@version = login_info["api_version"] ? login_info["api_version"] : @@version
      else
        puts "No login info exists."
      end
    end
  
    def query(query="", outfile)
      if query.size == 0
        raise "Query must be specified"
      end
    
      if !access_token_valid?
        login
      end
    
      begin
        url = "#{@@host}#{@@rest_path}v#{@@version}/query"
        response = RestClient.get url, :params => {:q => query}, :Authorization => "OAuth #{@@access_token}", :accept => :json, "X-PrettyPrint" => 1
        if outfile
          File.open(outfile, "w") { |f| f.write(response) }
          puts "Wrote query response to #{outfile}"
        else
          puts "Query response:"
          puts response
        end
      rescue => e
        puts e
        puts e.response
        raise "An error occurred while querying"
      end      
    end
  
    def access_token_valid?
      if !@@access_token
        return false
      end
      begin
        url = "#{@@host}#{@@rest_path}v#{@@version}"
        puts "Checking access token with request to #{url}"
        response = RestClient.get url, :Authorization => "OAuth #{@@access_token}", "X-PrettyPrint" => true, :accept => :json
        #puts response
        puts "Current access token is valid."
        return true
      rescue => e
        puts e
        puts "Current access token is invalid."
        return false
      end
    end
  
    def logout
      if File.exists?(@@filename)
        File.delete(@@filename)
        puts "Logged out."
      else
        puts "Not currently logged in."
      end
    end
  
  end # class
  
end # module