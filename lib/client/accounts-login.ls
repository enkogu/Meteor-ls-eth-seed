# Accounts.onLogin ->
	
# 		# event
# 		Router.go \/notAccepted
# 		state.set \not-accepted true
		# Accounts.logout!
	
Accounts.onLogout ->
	Router.go \/

Accounts.onEmailVerificationLink (token, done)->
	Accounts.verifyEmail token, (err,res)->
		if err => return Router.go \notVerified
		Router.go \verified
		done Meteor.call \sendEmail to:Meteor.user!emails.0.address, from:\@mail.com subject:config.emails.verificationLink.subject!, text:config.emails.verificationLink.text!


