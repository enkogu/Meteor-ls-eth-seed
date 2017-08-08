@route =-> Router.route(\/api/v1/ + &0, where:\server)

route \auth/admin/users .get (req,res,next)-> # 1.(Admin-only) get a list of all users    
    user = Meteor.users.findOne(access_token:req.query?access_token)
    if !user => return res.end Jstr error:'No user with this access token'
    if !user.isAdmin => return res.end Jstr error:'Access denied'
    if Date.now! - user.access_token_expired > 1800000 => return res.end Jstr error:'Access token expired'
    Meteor.users.update {_id:user._id}, $set:{access_token_expired:Date.now!}, (err,result)->
        res `with-obj` users: map (._id), Meteor.users.find!fetch!

with-obj =(res, obj)->
    res
        ..setHeader \Content-Type \application/json
        ..setHeader \Access-Control-Allow-Origin \*
        ..end Jstr obj

    
