@project-item-card =-> a class:'ui project card' href:"/platforms/#{it?crowdfundingPlatformId}/projects/#{it?_id}",
    d \.content,
        d \.header.proj-name, 
            it?name
            d \.meta project-state-convert it?currentState                   
        d \.project-card-table,
            stat-item \Buyers         buyers-count(it)||\0
            stat-item 'Days left'     days-left(it?endDate)||\0
            stat-item 'Pledge price'  it?selectedTierUsd||\0
            stat-item \Collateral     (collateral-total(it))||\0

@collateral-total =->
    fold1 (+), map (?refundSellerAmountUsd), it?offers||[]

@days-left =-> 
    end-date = new Date Date.parse it
    now-date = new Date!get-time!
    diff = end-date - now-date
    if diff <= 0 => return 0
    out = ceiling diff/(1000*3600*24)    
