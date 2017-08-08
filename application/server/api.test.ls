describe 'API positive tests, no auth yet' (api)->
    before -> 
        global.place = \http://localhost:3000/api/v1/
        global.uId   = ''
   
    after ->
        HTTP.get place+\test/remove-user/ + uId, (err,res)->
            console.log \remove-user res
        HTTP.get place+\test/remove-project/ + pId, (err,res)->
            console.log \remove-project res
        
    it '1. Create new user (users)' (done)->
        HTTP.post place+\users, data:{email:"#{Math.random!}@test.com" pass:\123123}, (err,res)->
            assert.equal err, null
            assert.not-equal res.content.length, 0
            global.uId = res.content
            done!

    it '37. Validate user (users/:id/validation:?sig)' (done)-> ...
    it '38. Reset password (users/:email/reset_password_request)' (done)-> ...
    it '39. Set new password (users/:id/password:?sig:?new_val)' (done)-> ...
