template \layout -> 
    html lang:\en,
        head do
            meta charset:\UTF-8
            title \Title
        body {},
            header class:'header',
                a href:'#' class:'logo'
                   
                nav class:'nav-dyns nav-primary',
                    ul {},
                        nav-item  \mainTemplate \/              \Main
                        nav-item  \adminUsers   \/admin/users/1 \Users !Meteor.user!?isAdmin
                        nav-item  \platforms    \/platforms     \Platforms
                        nav-item  \allProjects  \/projects      \Projects
                        nav-item  \info         \/info          \Info
                        nav-item  \debug        \/debug         \ADMIN !Meteor.user!?isAdmin
                        nav-item  \cfsdebug     \/cfs-debug     \CFS   !Meteor.user!?isAdmin
                       
                nav class:'nav-dyns nav-secondary',
                if Meteor.userId!
                    nav class:'nav nav-user', d \ui.grid,
                            d \.two.column.row,
                                d \.twelve.wide.column,
                                    d \.user-text-top 'Your logged in as'
                                    strong a class:'user-email-top' href:"/users/#{Meteor.userId!}", Meteor.user!?emails?0?address
                                d \.four.wide.column.user-ava-column img src:\/css/images/avatar.png class:\user-ava width:\39 height:\39

                else a class:'btn btn-blue login' href:'/login', 'Sign in'

                if Meteor.user! && Meteor.user!?isAcceptedByAdmin==false => d \ui.red.item 'Account is not accepted by admin yet'

            div class:'main peer-body', div class:'shell',
                if web3?
                    state.set \defaultAccount web3?eth?defaultAccount
                    SI @lookupTemplate \yield
                else SI @lookupTemplate \noMetamask

            footer class:'footer-dyns',
                div class:'shell',
                    nav class:'nav-dyns nav-footer',
                        ul {},
                            li a href:\#, "Home"
                            li a href:\#, "About Peerback"
                            li a href:\#, "FAQs"
                        ul {},
                            li a href:\#, "My Policy"
                            li a href:\#, "Verify My Policy"
                            li a href:\#, "Make a Payment"
                        ul {},
                            li a href:\#, "Assessor Dashboard"
                            li a href:\#, "Privacy Policy"
                            li a href:\#, "Open A Claim"
                div class:'copyright',
                    div class:'shell',
                        p {}, "2017 Copyright Info"

Template.layout.created =->
    Meteor.subscribe \allUsers

Template.layout.events do
    'click .close':-> $(event.target).parent!remove!

@active-item-q =-> if it is get-route-name! then \current

@nav-item =-> li class:"#{active-item-q &0} #{if &3 => \hidden }",
    a href:"#{&1}", &2
