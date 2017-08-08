T \accessDenied, -> msg \Error 'Access denied'
T \notAccepted,  -> msg 'Account is not accepted by admin yet' 'Please wait until...'
T \notFound,     -> msg \404 'Not found'
T \verified,     -> msg \Success 'Your email have been successfully verified'
T \notVerified,  -> msg \Error 'Token expired'
T \voteAccepted, -> msg 'Thank you', 'Your vote is accepted'

T \success,      -> msg \Done! 'Please wait. Action will be completed in the next few minutes', 
    button class:'ui huge button' onclick:'window.history.back()', 'Go back'

T \noMetamask,  -> msg 'No Metamask' 'This site requires the Metamask plugin for Google Chrome.',
    a class:'ui huge button' href:'https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn', 'Download Metamask'

@loading=-> msg \Loading 'Please, wait...'

@msg =-> div class:'container msg' style:'padding:100px',  
    h1 style:'font-size:50px; display:block; color:white', &0
    p style:'font-size:20px; padding-top:15px;padding-bottom:15px; color:white', &1
    &2||''

Template.voteAccepted.onRendered -> $(\nav).addClass \hidden