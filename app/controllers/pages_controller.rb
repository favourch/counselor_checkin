class PagesController < ApplicationController

	def index

	end

	def checkin
		@school = get_school
		if @school.nil?
			render status: 404
		end
	end

	def admin
		@school = get_school
		if @school.nil?
			render status: 404
		else
			authenticate_user!
		end
	end

	private

	def get_school
		if !params['school'].nil?
			if School.where(:url => params['school']).exists?
				return School.where(:url => params['school']).first
			else
				return nil
			end
		else
			return nil
		end
	end
end