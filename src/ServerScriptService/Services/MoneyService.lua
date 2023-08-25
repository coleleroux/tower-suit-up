local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)
local Timer = require(ReplicatedStorage.Packages.Timer)

local MoneyService = Knit.CreateService {
    Name = "MoneyService",
    -- Define some properties:
    _timer = Timer.new(2),
    _StartingMoney = 0,
    MoneyChanged = Signal.new(),
}

MoneyService.MoneyPerPlayer = {}



function MoneyService:AddMoney(player: Player, amount: number)
    local money = self:GetMoney(player)
    amount = if type(amount)=="number" then amount else 0
    money += amount
    self.MoneyPerPlayer[player] = money
    if amount ~= 0 then
        self.MoneyChanged:Fire(amount)
    end

    return self.money
end

function MoneyService:GetMoney(player: Player)
    local money = self.MoneyPerPlayer[player]
    return if money ~= nil then money else self._StartingMoney
end

function MoneyService:KnitInit()
    self._timer.Tick:Connect(function()
        for index, player in pairs(Players:GetPlayers()) do
            self:AddMoney(player, math.random(1,10))
        end
    end)
    self._timer:Start()
end

function MoneyService:KnitStart()
    Players.PlayerRemoving:Connect(function(player)
        -- table.remove(self.MoneyPerPlayer, table.find(self.MoneyPerPlayer, player))
        self.MoneyPerPlayer[player] = nil
    end)
end



return MoneyService