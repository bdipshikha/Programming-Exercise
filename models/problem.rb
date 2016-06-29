require_relative '../exercises/connection'

class Problem < ActiveRecord::Base
	has_many :answers
end