# == Schema Information
#
# Table name: reasons
#
#  id         :integer          not null, primary key
#  school_id  :integer
#  text       :text
#  created_at :datetime
#  updated_at :datetime
#

class Reason < ActiveRecord::Base
	validates :school, :text, presence: true, allow_nil: false, allow_blank: false

	belongs_to :school

	has_many :reason_users
   	has_many :users, through: :reason_users

	def name
		text
	end
end
