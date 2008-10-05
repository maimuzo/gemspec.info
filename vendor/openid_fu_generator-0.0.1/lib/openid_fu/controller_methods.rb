require 'pp'
require 'openid/yadis/discovery'
require 'openid/extensions/sreg'

module OpenidFu
  module ControllerMethods
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        verify :method => :post, :only => :begin,
          :params => :open_id_claimed_id,
          :redirect_to => {:action => 'new'}
        verify :method => :get, :only => :complete,
          :redirect_to => {:action => 'new'}
        before_filter :prepare_begin_open_id_auth, :only => :begin
        before_filter :prepare_complete_open_id_auth, :only => :complete
        attr_reader :open_id_request
        attr_reader :open_id_response
        attr_reader :open_id_fields
        cattr_accessor :open_id_consumer_options
      end
    end

    module ClassMethods
      # Setup required attributes
      def open_id_consumer(options={})
        self.open_id_consumer_options = options
      end
    end

    protected
    # Initialize or obtain consumer object for OpenID
    def consumer
      @consumer ||= OpenID::Consumer.new(
        session[:open_id_session] ||= {},
        ActiveRecordStore.new)
    end

    def prepare_begin_open_id_auth
      @open_id_request = consumer.begin(params[:open_id_claimed_id])

      # Fetch Request to obtain personal identity
      add_attribute_exchange_fields(@open_id_request)
    end

    def prepare_complete_open_id_auth
      return_to = url_for :only_path => false, :action => 'complete'
      parameters = params.reject{|k,v| request.path_parameters[k]}
      @open_id_response = consumer.complete(parameters, return_to)
      return unless open_id_response.status == OpenID::Consumer::SUCCESS

      #endpoint = open_id_response.endpoint
      #if OpenID.supports_ax?(endpoint)
      #  logger.debug "-----------" + open_id_response.message.inspect
      #  ax = OpenID::AX::FetchResponse.from_success_response(
      #    open_id_response)
      #  @open_id_fields = ax.get_extension_args
      #  logger.debug "***************** ax params ***************"
      #  logger.debug @open_id_fields.inspect
      #  logger.debug "***************** ax params ***************"
      #elsif OpenID.supports_sreg?(endpoint)
        @open_id_fields = open_id_response.extension_response('sreg', true)
        logger.debug "***************** sreg params ***************"
        logger.debug @open_id_fields.inspect
        logger.debug "***************** sreg params ***************"
      #end
    end

  private
    def add_attribute_exchange_fields(oid_req)
      #endpoint = oid_req.endpoint
      #if OpenID.supports_ax?(endpoint)
      #  # required attributes
      #  ax_req = OpenID::AX::FetchRequest.new
      #  (open_id_consumer_options[:required] || []).each do |type|
      #    type_uri = OpenID::AX::AttrTypes.type_uri(type)
      #    if type_uri
      #      ax_attr = OpenID::AX::AttrInfo.new(type_uri)
      #      ax_attr.required = true
      #      logger.debug "*******" + ax_attr.inspect
      #      ax_req.add(ax_attr)
      #    else
      #      logger.warn "OpenID AX doesn't support #{type}"
      #    end
      #  end
      #  oid_req.add_extension(ax_req)
      #elsif OpenID.supports_sreg?(endpoint)
        open_id_consumer_options.keys.inject({}) do |params, key|
          value = open_id_consumer_options[key]
          value = value.collect {|v| v.to_s.strip} * ',' if
            value.respond_to?(:collect)
          oid_req.add_extension_arg('sreg', key.to_s, value.to_s)
        end
      #end
    end
  end
end
