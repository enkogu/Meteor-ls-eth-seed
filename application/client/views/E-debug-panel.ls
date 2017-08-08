Router.route \debug path:\/debug

template \debug -> template-manager usr:Meteor.user!, template:debug-panel!, type:\admin

debug-panel=-> d \.margin40 d \ui.grid,
    d \two.column.row,
        d \eight.wide.column,

            d \ui.segment d \ui.grid.f, 
                d \left.aligned.one.column.row d \.column h2 'Create user', small it?link
                d \left.aligned.three.column.row,
                    d \six.wide.right.aligned.column \Email
                    d \six.wide.center.aligned.column, div class:'ui search prj',
                        input placeholder:\Email name:\email type:\text value:\john-doe@gmail.com class:\input-project
                    d \four.wide.left.aligned.column.amount-input-label 

                d \left.aligned.three.column.row,
                    d \six.wide.right.aligned.column \Password
                    d \six.wide.center.aligned.column input placeholder:\Password name:\password type:\password value:\password class:\input-project
                    d \four.wide.left.aligned.column.refund-price-label 

                d \four.column.centered.row,
                    d \.column
                    d \.column,
                        form-checkbox \isCrowdfundingPlatform 'CF platform'
                        form-checkbox \isRefundBuyer          'Refund buyer'
                        form-checkbox \isRefundSeller         'Refund seller'
                    d \.column,
                        form-checkbox \isAdmin                'Admin'
                        form-checkbox \isProjectCreator       'Project creator'
                        form-checkbox \isAcceptedByAdmin      'Accepted'
                    d \.column  

                d \center.aligned.one.column.row d \.column,
                    button class:'btn btn-large user-creating', 'Create user'


            d \ui.segment d \ui.grid.f, 
                d \left.aligned.one.column.row d \.column h2 'Create crowdfunding platform'
                stndrt-input \Title input class:'input-project' placeholder:\Title name:\title type:\text value:\Kickstarter
                search-input \User 'ui search usr' input class:'prompt input-prj input-project' type:\text name:\userId placeholder:'Search users...'          
                d \center.aligned.one.column.row d \.column,
                    button class:'btn btn-large cf-creating', 'Create CF platform'


        d \eight.wide.column.create-proj d \ui.segment d \ui.grid.f, 
            d \left.aligned.one.column.row d \.column h2 'Create project'


            d \.height34px
            stndrt-input \Title       input class:'input-project' placeholder:\Title name:\name type:\text value:\Zupaproj
            stndrt-input \Link        input class:'input-project' placeholder:\Link name:\link type:\text value:\http://kickstarter.com/zupaproj
            stndrt-input 'Tier usd'   input class:'prompt input-project' type:\Text name:\selectedTierUsd placeholder:'Selected tier usd', value:100
            stndrt-input \Email       input class:'input-project' placeholder:'Project creator email' name:\projectCreatorEmail type:\text value:\Vitalik@Buterin.eth
            stndrt-input 'Start date' input class:'prompt input-project' type:\text name:'Start date' placeholder:'Starts at...', value:todayMDY!
            stndrt-input 'End date'   input class:'prompt input-project' type:\text name:'End date' placeholder:'Ends at...', value:todayMDY!

            search-input \User 'ui search usr' input class:'prompt input-prj input-project' type:\text name:\userId placeholder:'Search users...'
            search-input \CFP  'ui search cfp' input class:'prompt input-prj input-project' type:\text name:\crowdfundingPlatformId placeholder:'Search crowdfunding platforms...'                

            d \.height34px
            
            d \center.aligned.one.column.row d \.column,
                button class:'btn btn-large proj-creating', 'Create project'

    d \two.column.row,
        d \eight.wide.column d \ui.segment.page-card d \ui.grid,
            d \left.aligned.one.column.row d \.column h2 'Send email'
            d \left.aligned.three.column.row,
                d \six.wide.right.aligned.column \Project
                d \six.wide.center.aligned.column, div class:'ui search prj',
                    input class:'prompt input-prj input-project proj survey' type:\text name:\projectId placeholder:'Search projects...', value:state.get(\current-project-id)
                d \four.wide.left.aligned.column.amount-input-label 

            d \left.aligned.three.column.row,
                d \six.wide.right.aligned.column \User
                d \six.wide.center.aligned.column,
                    d \ui.search.usr input class:'prompt input-prj input-project usr survey' type:\text name:\userId placeholder:'Search users...'
                d \four.wide.left.aligned.column.refund-price-label 

            d \left.aligned.four.column.row, 
                d \four.wide.column
                
                d \four.wide.column button class:'btn btn-large create-survey1', 'Send survey1'
                d \four.wide.column button class:'btn btn-large create-survey2', 'Send survey2'



@search-input=-> d \left.aligned.three.column.row,
    d \six.wide.right.aligned.column &0
    d \six.wide.center.aligned.column div class:&1, &2

@stndrt-input=-> d \left.aligned.three.column.row,
    d \six.wide.right.aligned.column &0
    d \six.wide.center.aligned.column &1
  

form-checkbox =-> D 'checkbox-inline',
    input type:\checkbox name:&0
    label &1

Template.debug.created =-> 
    Meteor.call \getAllEmails, (err,res)->
        $(\.ui.search.usr).search source:res

        Meteor.call \getAllCFP, (err,res)->
            $(\.ui.search.cfp).search source:res

            Meteor.call \getAllProjects, (err,res)->
                $(\.ui.search.prj).search source:res

Template.debug.events do
    'click .user-creating':->
        obj={}
        map (->obj[$(it).attr(\name)] = handle-val $(it)), $('.f:eq(0)').find(\input)
        console.log \obj: obj
        Meteor.call \insertUser obj, (err,res)->
            Meteor.users.update {_id:res}, $set:obj

    'click .cf-creating':->
        obj={}
        map (->obj[$(it).attr(\name)] = handle-val $(it)), $('.f:eq(1)').find(\input)
        console.log \obj: obj
        CrowdfundingPlatform.insert obj

        id = $('.f:eq(1)').find('input[name="userId"]').val!
        Meteor.users.update {_id:id}, $set:{isCrowdfundingPlatform:true}

    'click .proj-creating':->
        obj={}
        map (->obj[$(it).attr(\name)] = handle-val $(it)), $('.f:eq(2)').find(\input)
        console.log \obj: obj
        deploy-project (err, thash)->
            console.log \deploy-project: \err: err, \thash: thash
            if err => return err:err
            obj.thash = thash
            obj.state = \Initial
            if Project.find(thash:thash).fetch!length == 0
                
                id = $('.f:eq(2)').find('input[name="userId"]').val!
                Meteor.users.update {_id:id}, $set:{isProjectCreator:true}
                return Project.insert obj


    'click .create-survey1':->
        pId = $(\input.proj.survey).val!
        platformId = Project.findOne(_id:pId).crowdfundingPlatformId
        uId = $(\input.usr.survey).val!
        token = get-id!
        array = Meteor.users.findOne(_id:uId)?refundBuyerFields || []
        elem = null
        number = null
        for el, n in array
            if el.projectId==pId
                # elem   = el  
                number = n

        if elem==null 
            newObj = {
                "projectId": pId,
                "voteToken": token,
                "approved":null, 
                "meetExpectations":null,
                "received":null
            }
        else  newObj = elem

        if Meteor.users.findOne(_id:uId)?refundBuyerFields?length>0
            refundBuyerFields = Meteor.users.findOne(_id:uId)?refundBuyerFields 
        else refundBuyerFields = []

        refundBuyerFields.push newObj     

        Meteor.users.update({_id:uId}, $set:{refundBuyerFields:refundBuyerFields})

        link     = "https://peerback.herokuapp.com/platforms/#{platformId}/projects/#{pId}/survey1&sig=#{token}"
        projName = Project.findOne(_id:pId).name
        cfpName  = CrowdfundingPlatform.findOne(_id:platformId)?title
        email    = Meteor.users.findOne(_id:uId).emails.0.address
        obj = {
            to:      email, 
            from:   'peerback@chain.cloud', 
            subject: config.email.survey1.subject(projName,cfpName), 
            text:    config.email.survey1.text(projName,cfpName,link)
        }
        console.log obj
        Meteor.call('sendEmail', obj)
        alert 'Email have been sent'

    'click .create-survey2':->
        pId = $(\input.proj.survey).val!
        platformId = Project.findOne(_id:pId).crowdfundingPlatformId
        uId = $(\input.usr.survey).val!
        token = get-id!
        array = Meteor.users.findOne(_id:uId)?refundBuyerFields || []
        elem = null
        number = null
        for el, n in array
            if el.projectId==pId
                # elem   = el  
                number = n

        if elem==null 
            console.log \elem==null  
            newObj = {
                "projectId": pId,
                "voteToken": token,
                "approved":null, 
                "meetExpectations":null,
                "received":null
            }
        else  newObj = elem

        if Meteor.users.findOne(_id:uId)?refundBuyerFields?length>0
            refundBuyerFields = Meteor.users.findOne(_id:uId)?refundBuyerFields 
        else refundBuyerFields = []
    
        refundBuyerFields.push newObj

        Meteor.users.update({_id:uId}, $set:{refundBuyerFields:refundBuyerFields})
        
        link = "https://peerback.herokuapp.com/platforms/#{platformId}/projects/#{pId}/survey2&sig=#{token}"

        projName = Project.findOne(_id:pId).name
        cfpName  = CrowdfundingPlatform.findOne(_id:platformId)?title
        email    = Meteor.users.findOne(_id:uId).emails.0.address
        obj = {
            to:      email, 
            from:   'peerback@chain.cloud', 
            subject: config.email.survey2.subject(projName,cfpName), 
            text:    config.email.survey2.text(projName,cfpName,link)
        }


        console.log obj
        Meteor.call('sendEmail', obj)
        alert 'Email have been sent'

handle-val =-> 
    if $(it).attr(\type) == \checkbox => return $(it)[0].checked
    if $(it).attr(\type) == \number   => return +$(it).val!
    else return $(it).val!