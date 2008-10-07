# test
# script/runner 'Rubygem.find(12).create_general_point(:point => 3)'
class GeneralPoint < ActiveRecord::Base
  belongs_to :rubygem
end
