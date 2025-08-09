-- Events.lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")

return {
    Remote = {
        
        PartyReceivedInvite = Events.Remote.Party_ReceivedInvite,
        PartyUpdated = Events.Remote.Party_Update,
        PartyAcceptInvite= Events.Remote.Party_AcceptInvite,
        PartyDeclineInvite = Events.Remote.Party_DeclineInvite,
        PartySendInvite = Events.Remote.Party_SendInvite,
        PartyShow = Events.Remote.Party_Show,
    },
    Client = {
    },
    Server = {
    }
}
