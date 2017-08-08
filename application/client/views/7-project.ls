Router.route \project path:\/platforms/:id/projects/:project_id

template \project -> template-manager do
    test:->  
        loaded = true
        objects = [Project.findOne(_id:address-last!), Project.findOne(_id:address-last!)?contractAddress, state.get(\user-state),  state.get(\mark), state.get(\mark4), state.get(\mark5), state.get(\mark6)]
        console.log \objects: objects
        for obj in objects
            if typeof obj is \undefined => loaded := false
        return loaded
        
    template: project-card Project.findOne _id:address-last!
    type:\load

@project-card =-> d \ui.grid d \.aligned.two.column.row.project-card,
    d \ten.wide.column, 
        d \ui.segment.white-card d \ui.grid, 
            d \left.aligned.one.column.row d \.column h2 it?name, small it?link
            d \left.aligned.three.column.row,
                d \eight.wide.right.aligned.column 'Amount to put into collateral'
                d \two.wide.center.aligned.column.inp-small input type:\number min:(maximum [11*(it?selectedTierUsd), 500]), step:(it?selectedTierUsd||50), class:'amount-input input-project input-small' placeholder:\Amount,  disabled:(state.get(\user-state)==\deposited ||state.get(\user-state)==\transact-sent ), value:amount-val(it, it?selectedTierUsd)||spinner!
                d \one.wide.left.aligned.column.inp-sign \$
                d \five.wide.left.aligned.column.amount-input-label get-amount it

            d \left.aligned.three.column.row,
                d \eight.wide.right.aligned.column 'Your refund price'
                d \two.wide.center.aligned.column.inp-small input type:\number step:\1 min:\1 max:\100 class:'refund-price input-project input-small' placeholder:\Price, value:(if state.get(\user-state)==\deposited => refund-price-val(it)), disabled:(state.get(\user-state)==\transact-sent)
                d \one.wide.left.aligned.column.inp-sign \%
                d \five.wide.left.aligned.column.refund-price-label get-usd it

            d \center.aligned.one.column.row.proj-actions d \.column, switch state.get \user-state
                | \not-user       => h4('Become a refund seller!', br!, 'Please sign up')
                | \not-supporting => button class:'btn btn-large support-project' disabled:!state.get(\usd-to-eth), 'Support the project now!'
                | \transact-sent  => h4 'Transaction sent' 
                | \deposited      => button class:'btn btn-large update-price' disabled:true, 'Update refund price'

        d \ui.segment.white-card d \ui.grid, 
            d \left.aligned.one.column.row d \.column h2 'Price distribution'
            d \left.aligned.one.column.row d \.column bars-grid it

    d \six.wide.column,      
        d \ui.segment.white-card, 
            h2 class:\.stat-header, \Statistics
            d \.height10
            stat-item 'Pledge price'        it?selectedTierUsd||\0
            stat-item 'Lowest refund price' lowest-refund it
            stat-item \Sellers              sellers-count it
            stat-item \Buyers               buyers-count(it)||\0
            stat-item \Collateral           collateral-total(it)||\0
              
        d \ui.segment.white-card d \ui.grid, 
            d \left.aligned.one.column.row   d \.column h2 'Project state'
            d \center.aligned.one.column.row d \.column d \state.label project-state-convert +it?currentState
            d \left.aligned.one.column.row   d \.column project-state-text +it?currentState
            d \left.aligned.two.column.row,
                d \seven.wide.left.aligned.column. 'Crowdfunding ends at'
                d \nine.wide.center.aligned.column format-date(it?endDate)||\---
                state.set \mark4 \done

@stat-item=-> d \.stat-item,
    d \.first  &0
    d \.second &1

@bars-grid=-> 
    bars = {}
    tier-usd = it?selectedTierUsd
    offers = reverse sort-by (.offerPriceUsd), it?offers||[]
    offers-uniq =  []
    num = 0

    for o in offers 
        uniq = true
        for offuniq in offers-uniq
            if offuniq.offerPriceUsd == o.offerPriceUsd => uniq = false
            
        if uniq => offers-uniq.push o             
        
    offstate = []
    for offer in offers-uniq
        offstate.push get-offer-bar(offer, offers)
    state.set \offers, offstate

    d \ui.grid,
        for offer in offers-uniq
            get-bar-row get-offer-bar(offer, offers)
        state.set \mark \done

@get-offer-bar=(offer,offers)->
    out = {}
    out.price    = offer.offerPriceUsd||\0
    out.priceUsd = +(offer.offerPriceUsd*tier-usd/100).toFixed(2)
    out.sellers  = filter((.offerPriceUsd == offer.offerPriceUsd), offers).length||\0
    out.refundSellerArr = []
    col = 0
    
    for o in offers           
        if o.offerPriceUsd == offer.offerPriceUsd
            col += o.refundSellerAmountUsd
            bought = 0
            for m in o.matchedRefunds
                bought += m.offerPriceUsd
            out.refundSellerArr.push {id:o.refundSellerId, usd:o.refundSellerAmountUsd, bought:bought}
    out.total = col
    out.left = +(100*(bought/col)).toFixed(2)
    out

@get-bar-row =->
    bar-row color:&1||\green, price:&0?price||'...', left:&0?left||\0, sellers:&0?sellers||'...', priceUsd:&0?priceUsd||\0, total:&0?total||\0, refundSellerArr:&0?refundSellerArr||[]

@bar-row =-> d \three.column.row,
    d \three.wide.left.aligned.column, 
        d \ui.grid, 
            d \eight.wide.column.bar-large-column "#{it.price}%" 

            d \eight.wide.column.bar-small-column,
                d \.one.column.row, d \.column "$#{it.priceUsd}"
                d \.one.column.row, d \.column \$ + it?total

    d \thirteen.wide.column.progress d \.progress-bar,
        for el in it?refundSellerArr
            div class:'tooltip progress-el' "data-content":"Add users to your feed",
                span class:\tooltiptext, " $#{el?usd}, #{floor (el?usd- el?bought)/it.priceUsd} left"
                div class:\progress style:"width:#{el?usd/30}px" 
                div class:"bought #{if el?id == Meteor.userId! => \active else ''}" style:"width:#{(el?usd - el?bought)/30}px"
                d \.progress-percent,  +(100*(el?bought/el?usd)).toFixed(1) + \%

@refund-price-val =(proj)-> 
    out = 1
    is-refundSeller =-> if it.refundSellerId == Meteor.userId! => out := it?offerPriceUsd
    map is-refundSeller, proj?offers||[] 
    out
    
@amount-val =(proj,selectedTierUsd)-> 
    out = maximum [11*(selectedTierUsd), 500]
    is-refundSeller =-> if it.refundSellerId == Meteor.userId! => out := it?refundSellerAmountUsd
    map is-refundSeller, proj?offers||[]
    out

@buyers-count =(proj)->
    out = 0
    offers = (proj?offers||[])
    for offer in offers
        out += offer.matchedRefunds.length
    console.log \buyers-total: out
    out

@get-amount =->   
    amount  = amount-val(it, it?selectedTierUsd)/state.get(\usd-to-eth)
    if amount 
        state.set(\mark2, \done)
        amount.toPrecision(4) + ' ETH'
    else amount = D \div, spinner!, ' ETH'
    
@get-usd=-> 
    usd = +refund-price-val(it)*(+it?selectedTierUsd/100)
    if usd => usd.toPrecision(4) + ' USD'

@sellers-count=->
    counter = 0
    get-deployed-offers=-> if it.currentState == 2 => counter += 1
    map get-deployed-offers, (it?offers||[])
    counter

@project-deployed =->
    proj = Project.findOne(_id:address-last!)
    web3.eth.getTransactionReceipt proj?thash, (err,res)->
        console.log \getTransactionReceipt: res
        if err || !res?contractAddress => no
        Project.update {_id:address-last!}, $set:{contractAddress:res?contractAddress}, (err,res)-> yes

@lowest-refund=-> 
    min-percent = (minimum map (.offerPriceUsd), it?offers||[])||\0
    (min-percent*it?selectedTierUsd/100).toFixed(2) || \0

#——————————————————————————————————————————————————————————————————————————————— CREATED

Template.project.created =->
    map (->state.set it, undefined), <[ mark mark2 mark3 mark4 mark5 mark6 ]>
    $.ajax url:\https://api.coinmarketcap.com/v1/ticker/ethereum/
        .done -> state.set \usd-to-eth it.0.price_usd
    
    if !Project.find-one(_id:address-last!) => state.set \not-found true

Template.project.rendered =->
    proj = Project.find-one(_id:address-last!)
    Meteor.call \amIrefundSeller, {pId:address-last!, uId:Meteor.userId!}, (err,res)->
        state.set \user-state res

        if state.get(\user-state)!=\deposited 
            $(\.refund-price).val refund-price-val(proj).0||1

        if state.get(\user-state)==\transact-sent
            proj = Project.findOne(_id:address-last!)
            offer-thash = null
            for pr in proj.offers
                if pr.refundSellerId == Meteor.userId! => offer-thash = pr?thash

            web3.eth.contract(config.project-abi).at(proj.contractAddress).getBalance web3.eth.defaultAccount, (err,res)->
                offers = proj.offers
                for offer in offers
                    if offer.refundSellerId == Meteor.userId! 
                        offer.currentState = 2

                Project.update {_id:address-last!}, $set:{offers:offers}, (err,res)->
                    if err => return console.log err
                    state.set \user-state \deposited
                    state.set(\mark5,\done)

        state.set(\mark5,\done)
                
Template.project.onRendered -> 
    Meteor.setTimeout((-> state.set(\mark6,\done)), 1500)

Template.project.events do
    'input .refund-price':-> 
        $(\.update-price).attr \disabled false
        $(\.refund-price-label).html Project.find-one(_id:address-last!)?selectedTierUsd*(+$(\.refund-price).val!)/100 + ' USD'

    'input .amount-input':-> 
        proj = Project.find-one(_id:address-last!)
        $(\.amount-input-label).html (+$(\.amount-input).val!/state.get(\usd-to-eth)).toPrecision(4) + ' ETH'

    'click .support-project':-> 
        valueUsd = +$(\.amount-input).val!
        valueWei = new BigNumber(valueUsd).divided-by(state.get(\usd-to-eth)).times('1000000000000000').ceil!to-fixed! # TODO, DEV: divided by 1000
        proj = Project.find-one(_id:address-last!)
        
        params = config.standart-params
        params.to    = proj.contractAddress
        params.from  = web3.eth.defaultAccount
        params.value = valueWei

        web3.eth.sendTransaction params, (err,thash)->
            if err => return err
            obj = new Object do
                refundSellerId              : Meteor.userId!
                offerPriceUsd               : +$(\.refund-price).val!
                refundSellerEthereumAddress : web3.eth.defaultAccount
                refundSellerAmountWei       : valueWei
                refundSellerAmountUsd       : valueUsd
                matchedRefunds              : []
                currentState                : 1
                thash                       : thash

            Project.update {_id:address-last!}, $push:offers:obj, (err,res)->
                if err => return console.log err
                state.set \user-state \transact-sent

    'click .update-price':->       
        update-offer =-> 
            if it?refundSellerId == Meteor.userId!
                it.offerPriceUsd = +$(\.refund-price).val!
            it
        offers = map update-offer, Project.findOne(_id:address-last!)?offers
        Project.update {_id:address-last!}, $set:offers:offers, (err,res)->

    'keydown .amount-input':-> event.prevent-default!
    'keydown .refund-price':-> event.prevent-default!
