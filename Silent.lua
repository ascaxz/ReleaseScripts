local Players = game.Players
local LocalPlayer = Players.LocalPlayer
local ReplicatedFirst, ReplicatedStorage = game.ReplicatedFirst, game.ReplicatedStorage
local CurrentCamera = workspace.CurrentCamera
function NotObstructing(Destination, Ignore)
    local Origin = CurrentCamera.CFrame.Position
    local CheckRay = Ray.new(Origin, Destination - Origin)
    local Hit = workspace.FindPartOnRayWithIgnoreList(workspace, CheckRay, Ignore)
    return Hit == nil
end
function GetClosestToCursor()
    local Max, Close = math.huge
    for I,V in pairs(Players.GetPlayers(Players)) do
        if V ~= LocalPlayer and V.Character and V.Character.Humanoid then
            if Toggles.WallCheck then
                if Toggles.TeamCheck then
                    if V.Team ~= LocalPlayer.Team then
                        local Body = (not BodyPart and "Head" or BodyPart)
                        local Pos, Vis = CurrentCamera.WorldToScreenPoint(CurrentCamera, V.Character[Body].Position)
                        if Vis and NotObstructing(V.Character[Body].Position, {LocalPlayer.Character, V.Character}) then
                            local MyPos, TheirPos = Vector2.new(Mouse.X, Mouse.Y), Vector2.new(Pos.X, Pos.Y)
                            if (TheirPos - MyPos).Magnitude < Max and (TheirPos - MyPos).Magnitude < Storage.FOV then
                                Max = (TheirPos - MyPos).Magnitude
                                Close = V
                            end
                        end
                    end
                else
                    local Body = (not BodyPart and "Head" or BodyPart)
                    local Pos, Vis = CurrentCamera.WorldToScreenPoint(CurrentCamera, V.Character[Body].Position)
                    if Vis and NotObstructing(V.Character[Body].Position, {LocalPlayer.Character, V.Character}) then
                        local MyPos, TheirPos = Vector2.new(Mouse.X, Mouse.Y), Vector2.new(Pos.X, Pos.Y)
                        if (TheirPos - MyPos).Magnitude < Max and (TheirPos - MyPos).Magnitude < Storage.FOV then
                            Max = (TheirPos - MyPos).Magnitude
                            Close = V
                        end
                    end
                end
            else
                if Toggles.TeamCheck then
                    if V.Team ~= LocalPlayer.Team then
                        local Body = (not BodyPart and "Head" or BodyPart)
                        local Pos, Vis = CurrentCamera.WorldToScreenPoint(CurrentCamera, V.Character[Body].Position)
                        if Vis then
                            local MyPos, TheirPos = Vector2.new(Mouse.X, Mouse.Y), Vector2.new(Pos.X, Pos.Y)
                            if (TheirPos - MyPos).Magnitude < Max and (TheirPos - MyPos).Magnitude < Storage.FOV then
                                Max = (TheirPos - MyPos).Magnitude
                                Close = V
                            end
                        end
                    end
                else
                    local Body = (not BodyPart and "Head" or BodyPart)
                    local Pos, Vis = CurrentCamera.WorldToScreenPoint(CurrentCamera, V.Character[Body].Position)
                    if Vis then
                        local MyPos, TheirPos = Vector2.new(Mouse.X, Mouse.Y), Vector2.new(Pos.X, Pos.Y)
                        if (TheirPos - MyPos).Magnitude < Max and (TheirPos - MyPos).Magnitude < Storage.FOV then
                            Max = (TheirPos - MyPos).Magnitude
                            Close = V
                        end
                    end
                end
            end
        end
    end
    return Close
end
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
