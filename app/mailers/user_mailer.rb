class UserMailer < ActionMailer::Base
  default :from => "nom@justnom.it"
  
  def welcome_email(user)
    begin
      @user = user
      @name = @user.name.presence || @user.screen_name.presence || @user.email.presence
      @id = user.id
      @url  = "https://justnom.it/project"
      return unless @name.present? && user.respond_to?(:email)
      mail(:to => user.email, :subject => "Nom: Signup Bot")
    rescue Exception
      puts "EMAIL to #{@user.inspect} failed"
    end
  end

  def password_reset(user)
    begin
      @user = user
      @name = @user.name.presence || @user.screen_name.presence || @user.email.presence
      @password = Util.secure_token
      @user.newpassword = @password
      @user.newpass_time = Time.now.utc + 3.days
      @url = "https://justnom.it/users/#{@user.user_nid}/reset?token=#{@password}"
      @email = user.email
      return unless @email.present?
      mail(:to => user.email, :subject => "Nom: Password Reset Bot")
    rescue Exception
      puts "EMAIL to #{@user.inspect} failed for password reset"
    end
  end

  def deploy_complete
    begin
      mail(:to => 'team@justnom.it', :subject => 'Deploy Complete').deliver
    rescue Exception
    end
  end
  
end
