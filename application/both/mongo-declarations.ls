Accounts.config forbidClientAccountCreation: false

@CrowdfundingPlatform = new Mongo.Collection \crowdfundingPlatform 
@Project              = new Mongo.Collection \project
@MatchedRefundEntity  = new Mongo.Collection \matchedRefundEntity
@VoteEntity           = new Mongo.Collection \voteEntity