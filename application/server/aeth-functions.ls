@solc      = Npm.require \solc
@fs        = Npm.require \fs.realpath
@BigNumber = Npm.require \bignumber.js
@path      = Npm.require \path
@Web3      = Npm.require \web3

@web3      = new Web3 new Web3.providers.HttpProvider config.node
base      = path.resolve(\.).split(\.meteor).0

@deploy-project=(cb)-> # acc pay for the gas
    params = config.standart-params
    params.data = \0x + config.project-bytecode 

    web3.eth.contract(config.project-abi).new(config.account, params, (err,c)-> 
        if err => cb err 
        else cb null, c.transactionHash
    )

@get-contract=(fileName, cName, cb)-> fs.readFile fileName, \utf8, (err, source)->
    if err => return cb err
    contr = solc.compile(source, 1).contracts[cName]
    cb null, JSON.parse(contr.interface), String(contr.bytecode)

@compile-project=-> get-contract base+\application/server/project.sol, \:Project, it

@get-offer-balance=(proj-address, offer, cb)->
    web3.eth.contract(config.project-abi).at(proj-address).getBalance(offer, cb)

@check-that-project-deployed=(thash, cb)->
    web3.eth.getTransactionReceipt thash, (err,res)->
        cb null, res

@update-proj=(pId, cb)->
    thash = Project.findOne(_id:pId).thash
    check-that-project-deployed thash, Meteor.bindEnvironment (err,res)->
        console.log \res.contractAddress: res.contractAddress
        if res.contractAddress
            Project.update {_id:pId}, {$set:{contract-address:res.contractAddress, state:\Deployed}}, (err,res)->
                cb null, res
        

