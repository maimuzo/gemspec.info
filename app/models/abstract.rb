class Abstract < ActiveRecord::Base
  @@display_length = 50
  
  def summary
    if message.jlength > @@display_length
      include JSlice
      message.jslice[0..(@@display_length - 3)] + "..."
    end
  end
end
