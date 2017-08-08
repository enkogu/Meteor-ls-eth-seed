AdminQ =-> Meteor.users.findOne(_id:&0)?isAdmin
UserQ  =-> !!&0
NotAdminQ =-> !Meteor.users.findOne(_id:&0)?isAdmin
NotUserQ  =-> !&0

deny-for-non-admin =-> it.deny do
    insert:NotAdminQ
    update:NotAdminQ
    remove:NotAdminQ

deny-for-non-user =-> it.deny do
    insert:NotUserQ
    update:NotUserQ
    remove:NotUserQ

allow-for-all-users =-> it.allow do
    insert:UserQ
    update:UserQ
    remove:UserQ

allow-for-admin =-> it.allow do
    insert:AdminQ
    update:AdminQ
    remove:AdminQ


map deny-for-non-admin, [ 
    Meteor.users
]

map deny-for-non-user, [ 
    Project
    CrowdfundingPlatform
]

map allow-for-all-users, [ 
    Project
    CrowdfundingPlatform
]

map allow-for-admin, [ 
    Meteor.users
]

Meteor.users.before.insert (uId, doc)->
    if Meteor.users.find!fetch!count == 0 => doc.isAdmin = true
    doc.isAcceptedByAdmin = false
    doc.isRefundSeller    = true
    doc.offers            = []
Meteor.users.before.update (uId, doc, fieldNames, modifier, options) ->
    if doc?isAcceptedByAdmin == true && modifier.$set?isAcceptedByAdmin == false 
        modifier.$set.isAcceptedByAdmin == true

Meteor.users.after.insert (uId,doc)->
    Accounts.sendVerificationEmail doc._id

Project.before.insert (uId, doc)->
    doc.currentState = 1
    doc.projectCreatorId  = uId
    doc.Votes1 = []
    doc.Votes2 = []
    doc.Votes3 = []
    doc.startDate    = new Date Date.parse doc?startDate
    doc.endDate      = new Date Date.parse doc?endDate  

Meteor.publish \allUsers, -> Meteor.users.find!