class PagesController < ApplicationController

	def index
		@schools = School.all
	end

	def checkin
		@school = get_school
		if @school.nil?
			render status: 404
		end
		@counselors = User.where(:school => @school).all
		@reasons = Reason.where(:school => @school).all
	end

	def admin
		@school = get_school
		if @school.nil?
			render status: 404
		else
			authenticate_user!
			@checkins = Checkin.where(:school => @school).order("created_at desc").all
			@users = User.where(:school => @school).all
			@reasons = Reason.where(:school => @school).all
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