require_relative '../exercises/connection'

class Comment < ActiveRecord::Base
	belongs_to :answer
end