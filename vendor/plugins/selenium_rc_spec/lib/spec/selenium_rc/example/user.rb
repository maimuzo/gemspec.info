module Spec::SeleniumRc
  module Example
    class User
      def initialize(name, proxy)
        @name = name
        @selenium = proxy
        @selenium.extend(SeleniumDriverExtension) unless @selenium.kind_of?(SeleniumDriverExtension)
      end
      def selenium; @selenium end

      def method_missing(msg, *args)
        return selenium.__send__(msg, *args) if selenium.respond_to?(msg)
        msg = msg.to_s

        if m = /\Ahas_(\w+)\??\Z/.match(msg) and 
          selenium.respond_to?("get_#{m[1]}") and !selenium.respond_to?("have_#{m[1]}?")
          # has_xxx predicates
          return !!selenium.__send__("get_#{m[1]}", *args)
        elsif m = /\A(\w+)=\Z/.match(msg) and selenium.respond_to?("set_#{m[1]}")
          # setters
          return selenium.__send__("set_#{m[1]}", *args)
        elsif m = /\A(\w+)\??\Z/.match(msg) and selenium.respond_to?("get_#{m[1]}")
          # predicates
          return selenium.__send__("get_#{m[1]}", *args)
        else 
          # 's for the third person present singular
          alt_msg = remove_third_person_present_singular_s(msg)
          if alt_msg 
            if selenium.respond_to?(alt_msg)
              return selenium.__send__(alt_msg, *args)
            elsif selenium.respond_to?("#{alt_msg}e")
              return selenium.__send__("#{alt_msg}e", *args)
            end
          end
        end

        return super
      end

      private
      def remove_third_person_present_singular_s(msg)
        msg.split('_and_').map{|clause|
          words = clause.split(/_/)
          verb = words.first.
            gsub(/has/, 'have').
            gsub(/(\w+?)e?s/, '\1')
          [verb, *words[1..-1]].join('_')
        }.join('_and_')
      rescue
        return nil
      end
    end
  end
end

