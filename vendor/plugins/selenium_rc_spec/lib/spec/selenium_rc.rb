require 'spec/rails'
require 'selenium'

module Spec
  module SeleniumRc
    VERSION = "$Revision$"
  end
end

require 'spec/selenium_rc/config'
require 'spec/selenium_rc/example'
require 'spec/selenium_rc/matchers'

Spec::Example::ExampleGroupFactory.register(:selenium, Spec::SeleniumRc::Example::SeleniumRcExampleGroup)

module Spec
  module Extensions
    module Main
      alias story describe
    end
  end
end
