require 'hpricot'
module Spec::SeleniumRc
  module Example
    module SeleniumDriverExtension
      def self.extended(driver)
        class << driver
          %w[
              get_string get_string_array 
              get_number get_number_array
              get_boolean get_boolean_array
            ].each do |original_name|
            eval <<-"EOS", binding, __FILE__, __LINE__
              def #{original_name}_with_return_value_recording(*args)
                @last_return_value = #{original_name}_without_return_value_recording(*args)
              end
              alias_method_chain :#{original_name}, :return_value_recording
            EOS
          end

          def last_return_value
            @last_return_value
          end

          def open_and_wait(url, timeout = @timeout)
            open(url)
            wait_for_page_to_load(timeout)
          end
          def wait_for_page_to_load(timeout = @timeout)
            super(timeout)
          end

          def click_and_wait(locator, timeout = @timeout)
            click(locator)
            wait_for_page_to_load(timeout)
          end

          # by http://twitter.com/nazoking/statuses/83616812
          def wait_for_ajax_loaded(timeout = @timeout)
            wait_for_condition(<<-JAVASCRIPT, timeout)
             selenium.page().currentWindow.Ajax.activeRequestCount==0
            JAVASCRIPT
          end

          def have_element?(xpath)
            !get_element(xpath).empty?
          end
          def get_element(xpath)
            html = get_html_source
            @last_return_value = Hpricot(html) / xpath
          end
        end
      end
    end
  end
end
