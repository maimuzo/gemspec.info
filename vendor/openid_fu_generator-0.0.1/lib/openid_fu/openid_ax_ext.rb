require 'openid/extensions/ax'

module OpenID
  module AX
    NS_URI = 'http://openid.net/srv/ax/1.0' unless defined?(NS_URI)
    unless OpenID.respond_to?(:supports_ax?)
      def OpenID.supports_ax? (endpoint)
        endpoint.uses_extension(NS_URI) 
      end
    end
  end
end
