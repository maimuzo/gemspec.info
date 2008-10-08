require "jcode"

# from http://yohasebe.com/2006/03/16/
module JSlice
  # Stringオブジェクトにjsliceメソッドを追加する。
  class String
    # マルチバイト文字のスライスを可能にするjsliceメソッド
    def jslice(a, b = nil)
      # 引数が1個かつRangeまたはFixnumオブジェクトの場合
      if (a.instance_of?(Range) || a.instance_of?(Fixnum)) && b == nil
        return self.split(//)[a].to_s
      # 引数が1個かつStringまたはRegexpの場合
      elsif (a.instance_of?(String) || a.instance_of?(Regexp)) && b == nil
        return slice(a)
      # 引数が2個でどちらもFixnumの場合
      elsif a.instance_of?(Fixnum) && b.instance_of?(Fixnum)
        return split(//)[a, b].to_s
      # 第1引数がRegexpで第2引数がStringの場合
      elsif a.instance_of?(Regexp) && b.instance_of?(Fixnum)
        return slice(a, b)
      # 上の条件に合わないときは例外ArgumentErrorを投げる。
      else
        raise ArgumentError
      end 
    end
  end
end
