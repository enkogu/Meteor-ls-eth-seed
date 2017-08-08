@config = {
    emails: {
        verificationLink:{
            subject:-> 'Email succesfully verified'
            text:-> 'Email succesfully verified'
        }

        survey1:{
            text :(projName,cfpName,link)-> 
                "Hello. This is ..."
            subject :(projName,cfpName)-> 
                "The shipping date of the project “#{projName}” ..."
        }

        survey2:{
            text :(projName,cfpName,link)-> 
                "Hello. This is ..."
            subject :(projName,cfpName)-> 
                "The shipping date of the project “#{projName}” ..."
        }
    }
}