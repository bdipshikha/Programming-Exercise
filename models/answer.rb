require_relative '../exercises/connection'

class Answer < ActiveRecord::Base
	belongs_to :problem
	has_many :comments
end