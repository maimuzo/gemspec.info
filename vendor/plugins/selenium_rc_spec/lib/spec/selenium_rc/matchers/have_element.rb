module Spec::SeleniumRc
  module Matchers
    class HaveElement
      def initialize(xpath)
        @xpath = xpath
      end

      def matches?(user)
        @user = user
        user.have_element(@xpath)
      end

      def failure_message
        "The user #{@user} was expected to have #{@xpath}, but not"
      end
      def negative_failure_message
        "The user #{@user} was not expected to have #{@xpath}, but has"
      end

      def to_s
        "have an element #{@xpath}"
      end
    end

    def have_element(xpath)
      HaveElement.new(xpath)
    end
  end
end
