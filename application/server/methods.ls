Meteor.methods do
    insertUser:-> Accounts.createUser it 
    
    getAllUsers:-> Meteor.users.find!

    getAllProjects:->
        arr =[]
        get-prj =~> arr.push {description:it?name, title:it?_id}
        map get-prj, Project.find!fetch!
        arr   
     
    amIrefundSeller:(o)->
        state = \not-supporting
        if !o.uId => return \not-user
        if (Project.findOne(_id:o.pId)?offers||[]).length > 0
            for offer in Project.findOne(_id:o.pId)?offers||[]
                if offer?refundSellerId == o.uId 
                    if offer?currentState == 1 => state := \transact-sent
                    if offer?currentState == 2 => state := \deposited
        state
