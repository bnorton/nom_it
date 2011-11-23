# @account_sid = 'AC291d295de593450dbbbf113e640ead23'
# @auth_token = # your authtoken here
# 
# # set up a client to talk to the Twilio REST API
# @client = Twilio::REST::Client.new(@account_sid, @auth_token)
# 
# 
# @account = @client.account
# @message = @account.sms.messages.create({:from => '+14155992671', :to => '+17143005444', :body => 'testing a message', :status_callback => 'http://justnom.it/sms/complete'})
# puts @message