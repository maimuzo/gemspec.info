require "openid/consumer/discovery"
require 'openid/fetchers'

OpenID::fetcher_use_env_http_proxy

#
# examine OpenID provider's end point
# 
# kick:
# script/runner 'Endpoint.new(true).find("fromnorth.blogspot.com")'
# script/runner 'Endpoint.new(true).find("fromnorth.blogspot.com").each {|e| TrastedOpenidProvider.create(:endpoint_url => e)}'
#
class Endpoint
  include OpenIdAuthentication
  
  def initialize(verbose = false)
    # flag of varbose
    @verbose = verbose
  end
  
  def find(identity_url)
    puts "Running discovery on #{identity_url}" if @verbose
    begin
      normalized_identifier, services = OpenID.discover(identity_url)
    rescue OpenID::DiscoveryFailure => why
      puts "Discovery failed: #{why.message}"
    else
      if services.empty?
        puts " No OpenID services found"
      else
        endpoint_urls = []
        services.each do |service|
          endpoint_urls << service.server_url
          puts "OpenID provider's end point : " + service.server_url if @verbose
        end
        return endpoint_urls
      end
    end
  end
end
