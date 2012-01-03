class UserMailer < ActionMailer::Base
  default :from => "team@justnom.it"
  
  def welcome_email(user)
    begin
      @user = user
      @name = @user.name.presence || @user.screen_name.presence || @user.email.presence
      @id = user.id
      @url  = "https://justnom.it/project"
      mail(:to => user.email, :subject => "Nom Project Signup")
    rescue Exception
      puts "EMAIL to #{@user.inspect} failed"
    end
  end
end
