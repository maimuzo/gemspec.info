module Spec::SeleniumRc
  module Example
    class SeleniumRcExampleGroup < Spec::Rails::Example::RailsExampleGroup
      before(:all) do
        create_server
        create_proxy
      end
      after(:all) do
        stop_selenium
        stop_server
        begin
          Timeout.timeout(3) { Process.waitall }
        rescue Timeout::Error
          force_stop_server
          Timeout.timeout(1) { Process.waitall }
        end
      end

      private
      def create_server
        @server_pid = Process.fork do
          config = CONFIG[:app]
          host, port, env = config[:binding], config[:port], config[:environment]
          server = File.join(RAILS_ROOT, *%w[ script server ])
          exec server, *%W[-b #{host} -p #{port} -e #{env}]
        end
        catch(:server_connected) {
          5.times do
          throw :server_connected if server_connectable?
          sleep 1
          end
        raise "can't connect to rails server"
        }
      end
      def create_proxy
        rc_config = CONFIG[:seleniumrc]
        host, port, browser, timeout = rc_config[:host], rc_config[:port], rc_config[:browsers].first, rc_config[:timeout]
        app_url = "http://#{CONFIG[:app][:host]}:#{CONFIG[:app][:port]}"
        @@selenium = Selenium::SeleniumDriver.new(host, port, browser, app_url, timeout)
        @@selenium.start
        @@selenium.set_context("test_new")
      end

      def stop_selenium
        @@selenium.stop if @@selenium rescue nil
      end
      def stop_server
        Process.kill :INT, @server_pid if @server_pid rescue nil
      end
      def force_stop_server
        Process.kill :KILL, @server_pid if @server_pid rescue nil
        Process.kill :TERM, @server_pid if @server_pid rescue nil
      end

      private
      def server_connectable?
        host = CONFIG[:app][:host]
        TCPSocket.open(CONFIG[:app][:host], CONFIG[:app][:port]) {
          return true
        }
      rescue Errno::ECONNREFUSED
        return false
      end

      class << self
        alias senario_body it
        def senario(user_name, description, &block)
          user_creation = lambda { User.new(user_name, class_variable_get(:@@selenium)) }
          senario_body("%s %s" % [user_name, description]) do
            user = user_creation.call
            (class << self; self end).module_eval do
              define_method(:he){user}
              define_method(:she){user}
              define_method(:ve){user}
              define_method(:it){user.last_return_value}
            end
            instance_eval(&block)
          end
        end
      end
    end

  end
end
