local CurrentCamera = workspace.CurrentCamera
local MT = getrawmetatable(game)
local OldNC = MT.__namecall
local OldIDX = MT.__index
setreadonly(MT, false)
local CurrentCamera = workspace.CurrentCamera

MT.__namecall = newcclosure(function(self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    if Method == "FindPartOnRayWithIgnoreList" and Toggles.SilentAim and not checkcaller() then
        local Close = GetClosestToCursor()
        if Close and Close.Character and Close.Character.Humanoid then
            Args[1] = Ray.new(CurrentCamera.CFrame.Position, (Close.Character[not BodyPart and "Head" or BodyPart].Position - CurrentCamera.CFrame.Position).Unit * 1000)
            return OldNC(self, unpack(Args))
        end
        if self.Name == "BeanBoozled" then
            return
        end
    end
    return OldNC(self, ...)
end)
MT.__index = newcclosure(function(self, K)
    if K == "Clips" and Toggles.SilentAim and not checkcaller() then
        return workspace.Map
    end
    return OldIDX(self, K)
end)
setreadonly(MT, true)
