class ApiController < ApplicationController
	protect_from_forgery with: :null_session
	before_action :authenticate_user!, :except => :add_checkin

	def add_checkin
		# check for missing params
		@school = get_school
		if @school.nil?
			render json: {error: "School Not Found"}, status: 404
		else
			# see if the user exists
			if User.where(:id => params['user_id']).exists?
				# create the Reason model
				checkin = Checkin.new
				checkin.school = @school
				checkin.name = params['name']
				checkin.user = User.find(params['user_id'])
				if params['user_type'] == "student"
					checkin.is_student = true
					checkin.badge_id = params['badge_id']
				else
					checkin.is_student = false
					checkin.child_name = params['student_name']
				end
				if params['custom_reason'] == "true"
					checkin.custom_reason = true
					checkin.reason_text = params['custom_reason_text']
				else
					checkin.custom_reason = false
					checkin.reason = Reason.find(params['reason_id'])
				end
				if checkin.save
					render json: {success: true}
				else
					render json: {error: checkin.errors.messages}, status: 400
				end
			else
				render json: {error: "Counselor Not Found"}, status: 404
			end
		end
	end

	def add_reason
		authenticate_user!
		@school = get_school
		if @school.nil? || current_user.school != @school
			render json: {error: "School Not Found"}, status: 404
		else
			reason = Reason.new
			reason.school = @school
			reason.text = params['text']
			if reason.save
				render json: {success: true}
			else
				render json: {error: reason.errors.messages}, status: 400
			end
		end
	end

	def update_reason
		authenticate_user!
		@reason = Reason.find(params[:id])

		if @reason.update_attributes(reason_params)
	        render text: "",status: 204
	    else
	      	render json: @reason.errors, status: :unprocessable_entity
		end
	end

	def delete_reason
		authenticate_user!
		@reason = Reason.find(params[:id])
		if @reason.destroy
			render json: {success: true}
		else
			render json:{error: "Could not delete record"}, status: 400
		end
	end

	def add_user
		authenticate_user!
		@school = get_school
		if @school != current_user.school
			render json: {error: "Not Authorized"}, status: 400
		elsif current_user.is_admin # can add
			u = User.new
			u.email = params['email']
			u.name = params['name']
			u.honorific = params['honorific']
			if params['is_admin'] == "true"
				u.is_admin = true
			else
				u.is_admin = false
			end
			u.school = @school
			# set random password
			password = (0...8).map { (65 + rand(26)).chr }.join
			u.password = password
			ap password
			if u.save
				UserMailer.welcome_email(u.honorific, u.name, u.email, password).deliver
				render json: {success: true}
			else
				render json: {error: u.errors.messages}, status: 400
			end
		else
			render json: {error: "Not Authorized"}, status: 400
		end
	end

	def update_user
		authenticate_user!
		@user = User.find(params[:id])

		if @user.update_attributes(user_params)
	        render text: "",status: 204
	    else
	      	render json: @reason.errors, status: :unprocessable_entity
		end
	end

	def delete_user
		authenticate_user!
		@user = User.find(params[:id])
		if @user != current_user && @user.school == current_user.school
			if @user.destroy
				render json: {success: true}
			else
				render json:{error: "Could not delete record"}, status: 400
			end
		else
			render json: {error: "You can't delete yourself!"}, status: 400
		end
	end

	private

	def reason_params
	    params.require(:reason).permit(:text)
	end

	def user_params
	    params.require(:user).permit(:honorific, :name, :is_admin, :email)
	end

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