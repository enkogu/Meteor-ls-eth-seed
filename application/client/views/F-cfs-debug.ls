Router.route \cfsdebug path:\/cfs-debug

template \cfsdebug -> template-manager usr:Meteor.user!, template:cfsdebug-panel!, type:\admin

cfsdebug-panel=-> d \.section-form.info-form,
    d \.section-title, 'CFS debug panel'
    d \ui.segment.page-card.info-card d \ui.grid,
        d \left.aligned.three.column.row,
            d \six.wide.right.aligned.column \Project
            d \six.wide.center.aligned.column, div class:'ui search prj',
                input class:'prompt input-prj input-project' type:\text name:\projectId placeholder:'Search projects...', value:state.get(\current-project-id)
            d \four.wide.left.aligned.column.amount-input-label 

        d \left.aligned.three.column.row,
            d \six.wide.right.aligned.column \Email
            d \six.wide.center.aligned.column input class:'input-project usr-email' type:\email name:\email placeholder:'Email...', value:\test@gmail.com
            d \four.wide.left.aligned.column.refund-price-label 

        d \center.aligned.one.column.row d \.column,           
            button class:'btn btn-large buy-refund', 'Buy a refund'

if state.get(\current-project-id) 
    d \ui.grid d \center.aligned.one.column.row d \.column,
        cfs-project-item-card Project.findOne _id:state.get(\current-project-id)


Template.cfsdebug.events do
    'click .buy-refund':->
        if !Project.findOne(_id:$(\.input-prj).val!) => alert 'No projects with this id'; event.prevent-default!
        else if !Project.findOne(_id:$(\.input-prj).val!)?offers?length => alert 'No ofers for this project'; event.prevent-default!
        Meteor.call \getAllProjects, (err,res)-> $(\.ui.search.prj).search source:res
        current-project-id = $(\.input-prj).val!
        current-project =  Project.findOne _id:$(\.input-prj).val!

        user-buyer = Meteor.users.findOne emails:$elemMatch:address: $(\.usr-email).val!
        offers = sort-by((.offerPriceUsd), current-project?offers)

        if !user-buyer => Meteor.call \insertUser {email:$(\.usr-email).val!, password:\pass}, (err,user-buyer-id)->
            Meteor.users.update {_id:user-buyer-id}, $set:{isRefundBuyer:true}, (err,res)->
                offers.0.matchedRefunds.push  {offerPriceUsd:offers.0.offerPriceUsd, buyerId:user-buyer-id}
                Project.update {_id:current-project?_id}, $set:offers:offers, ->
                    Meteor.call \getAllProjects, (err,res)-> $(\.ui.search.prj).search source:res

        else Meteor.users.update {_id:user-buyer._id}, $set:{isRefundBuyer:true}, (err,res)->
            if and-list map (-> it.buyerId!=user-buyer._id), offers.0.matchedRefunds
                offers.0.matchedRefunds.push  {offerPriceUsd:offers.0.offerPriceUsd, buyerId:user-buyer?_id}
                Project.update {_id:current-project?_id}, $set:offers:offers, ->
                    Meteor.call \getAllProjects, (err,res)-> $(\.ui.search.prj).search source:res
            else alert 'This user have offer already'; event.prevent-default!
        
        Meteor.call \getAllProjects, (err,res)-> $(\.ui.search.prj).search source:res

    'click .result':->
        state.set \current-project-id, $(\.input-prj).val!
        if Project.findOne(_id:$(\.input-prj).val!) 
            state.set \current-project-id $(\.input-prj).val!

        console.log \event.target.value $(\.input-prj).val!

Template.cfsdebug.created =->
    Meteor.call \getAllProjects, (err,res)->
        $(\.ui.search.prj).search source:res

@cfs-project-item-card =-> d \ui.segment d \ui.grid.statistics, 
    d \left.aligned.one.column.row d \.column h2 it?name

    info-item 'Lowest refund price' lowest-refund it
    info-item \Sellers              sellers-count it
    info-item \Buyers               buyers-count(it)||\0
    info-item \Collateral           collateral-total(it)||\0
    info-item 'Refund sellers'      ((it?offers||[])?length)||\0
    info-item 'Total funds ($)'     (collateral-total it)||\0
    info-item 'Days left'           days-left(it?endDate)||\0
     
current-price=->
    percents = minimum map (.offerPriceUsd), it?offers||[]
    usd      = it?selectedTierUsd*percents/100
    if usd => "$#{usd} (#{percents}%)" else \---
