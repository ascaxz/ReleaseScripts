math.randomseed(tick());
local modules, controlfunc;
for i,v in next, getgc(true) do
    if type(v) == "table" then
        if rawget(v, "Version") and rawget(v, "Kitty") then
            local mt = getrawmetatable(v);
            modules = select(2, pcall(getupvalue, mt.__index, 1)); --gets the ts module (haha totally not stolen from kiriot :p)
        elseif rawget(v, "Control") and type(rawget(v, "Control")) == "function" then
            controlfunc = rawget(v, "Control"); --control function used for walkspeed mult
        end
    end
    if modules and controlfunc then break; end
end
if not modules or (modules and not rawget(modules, "Network")) then
    print("Failed To Get TS Module"); -- :(
    return;
end
if not controlfunc then
    print("Failed To Get Control Function"); -- :(
    return;
end
local toggles = {
    aimbot = false,
    silentaim = false,
    teamcheck = false,
    vischeck = false,
    bodypart = "Head",
    hitchance = 1,
    fov = 0,
    norecoil = false,
    nospread = false,
    alwaysauto = false,
    fastfirerate = false,
    fly = false,
    flyspeed = 100,
};
local oldmult = 1.8;
local ok = false;
local chartable = getupvalue(modules.Characters.GetCharacter, 1);
local players = game:GetService("Players");
local runservice = game:GetService("RunService");
local uis = game:GetService("UserInputService");
local camera = workspace.CurrentCamera;
local localplayer = players.LocalPlayer;
local mouse = localplayer:GetMouse();
local isholding = false;
local chamsholder = Instance.new("Folder", game:GetService("CoreGui"));




local function getclosesttocursor()
    local max, close = math.huge;
    for player, character in next, chartable do
        if player ~= localplayer and (toggles.teamcheck and not modules.Teams:ArePlayersFriendly(player, localplayer) or not toggles.teamcheck) and chartable[localplayer] then
            local chosenpart = (character and character:FindFirstChild("Hitbox") and character.Hitbox:FindFirstChild(toggles.bodypart));
            if chosenpart then --if part exist
                local pos, onscreen = camera:WorldToScreenPoint(chosenpart.Position);
                if onscreen then --if on screen (not to be confused with behind walls or not)
                    local dist = Vector2.new(pos.X - mouse.X, pos.Y - mouse.Y).Magnitude;
                    if dist <= max and dist <= toggles.fov then
                        local part = camera:GetPartsObscuringTarget({chosenpart.Position}, {workspace.Characters, workspace.NonGeometry});
                        if (toggles.vischeck and #part == 0 or not toggles.vischeck) then --gay but works
                            max = dist;
                            close = player;
                        end
                    end
                end
            end
        end
    end
    return close;
end

do-- hooks
    local oldinit = modules.Projectiles.InitProjectile; --thanks coasts for method
    local oldfire = modules.Network.Fire;
    local oldlookvector = modules.Input.Reticle.LookVector;
    local oldwait = modules.Timer.Wait;
    local stopchanging = false; --ugly
    local originalfuncs = {}; -- PLEASE DONT BULLY ME FOR THIS
    modules.Projectiles.InitProjectile = function(self, ...)
        local args = {...};
        if args[4] == localplayer and toggles.silentaim and math.random(1, 100) <= toggles.hitchance then
            local char = chartable[getclosesttocursor()];
            local chosenpart = (char and char:FindFirstChild("Hitbox") and char.Hitbox:FindFirstChild(toggles.bodypart));
            if chosenpart then
                args[2] = chosenpart.Position - args[3];
                return oldinit(self, unpack(args));
            end
        end
        return oldinit(self, ...);
    end
    modules.Network.Fire = function(self, ...)
        local args = {...};
        if args[1] == "Item_Paintball" and args[2] == "Shoot" then
            if not stopchanging then
                originalfuncs[8], originalfuncs[9], originalfuncs[10] = getupvalue(2, 8), getupvalue(2, 9), getupvalue(2, 10);
                stopchanging = true;
            end
            setupvalue(2, 8, function(...) if toggles.norecoil then return; end return originalfuncs[8](...); end);
            setupvalue(2, 9, function(...) if toggles.norecoil then return; end return originalfuncs[9](...); end);
            setupvalue(2, 10, function(...) if toggles.norecoil then return; end return originalfuncs[10](...); end);
            -- PLEASE FORGIVE ME I ONLY DID IT BECAUSE HOOKFUNCTION GAY :pleading_face:
        end
        return oldfire(self, ...);
    end
    modules.Input.Reticle.LookVector = function(...)
        return (toggles.nospread and camera.CFrame.LookVector or oldlookvector(...));
    end
    modules.Timer.Wait = function(self, time)
        local Upvals = getupvalues(2);
        if toggles.fastfirerate then
            if type(Upvals[1]) == "table" and rawget(Upvals[1], "Equipped") and typeof(Upvals[7]) == "Instance" and Upvals[7]:IsA("IntValue") then
                return oldwait(self, 0);
            end
        end
        return oldwait(self, time);
    end
end
uis.InputBegan:Connect(function(key, gp)
    ok = gp;
    if not gp and key.UserInputType.Name == "MouseButton2" then
        isholding = true;
    end
end)
uis.InputEnded:Connect(function(key, gp)
    if not gp and key.UserInputType.Name == "MouseButton2" then
        isholding = false;
    end
end)
runservice.RenderStepped:Connect(function()
    math.randomseed(tick());
    if toggles.aimbot then
        if isholding and math.random(1, 100) <= toggles.hitchance then
            local char = chartable[getclosesttocursor()];
            local chosenpart = (char and char:FindFirstChild("Hitbox") and char.Hitbox:FindFirstChild(toggles.bodypart));
            if chosenpart then
                local pos, onscreen = camera:WorldToScreenPoint(chosenpart.Position);
                if onscreen then
                    mousemoverel(pos.X - mouse.X, pos.Y - mouse.Y);
                end
            end
        end
    end
end)
runservice.Stepped:Connect(function()
    local flyvector = Vector3.new();
    if uis:IsKeyDown("W") then
        flyvector = flyvector + camera.CFrame.LookVector;
    elseif uis:IsKeyDown("S") then
        flyvector = flyvector - camera.CFrame.LookVector;
    elseif uis:IsKeyDown("A") then
        flyvector = flyvector - camera.CFrame.RightVector;
    elseif uis:IsKeyDown("D") then
        flyvector = flyvector + camera.CFrame.RightVector;
    elseif uis:IsKeyDown("Space") then
        flyvector = flyvector + camera.CFrame.UpVector;
    elseif uis:IsKeyDown("LeftControl") then
        flyvector = flyvector - camera.CFrame.UpVector;
    end

    if toggles.fly and chartable[localplayer] and not ok then
        if flyvector.Unit.X == flyvector.Unit.X then
            chartable[localplayer]:WaitForChild("Root").Velocity = flyvector.Unit * toggles.flyspeed;
        end
        --chartable[localplayer]:WaitForChild("Root").Anchored = toggles.fly and flyvector == Vector3.new();
    end
end)
local library = loadstring(game:HttpGet("https://pastebin.com/raw/edJT9EGX"))();

local aimbot = library:CreateWindow("Aimbot");
local weapons = library:CreateWindow("Weapons");
local movement = library:CreateWindow("Movement");

aimbot:AddToggle({
    text = "Aimbot",
    state = false,
    callback = function(bool)
        toggles.aimbot = bool;
    end
});
aimbot:AddToggle({
    text = "Silent Aim",
    state = false,
    callback = function(bool)
        toggles.silentaim = bool;
    end
});
aimbot:AddList({
    text = "Aim Bone",
    values = {"Head", "Chest"},
    open = false,
    callback = function(part)
        toggles.bodypart = part;
    end
});
aimbot:AddSlider({
    text = "Hit Chance",
    min = 1,
    max = 100,
    callback = function(hc)
        toggles.hitchance = hc;
    end
});
aimbot:AddSlider({
    text = "FOV",
    min = 0,
    max = 800,
    callback = function(fov)
        toggles.fov = fov;
    end
});
aimbot:AddToggle({
    text = "Team Check",
    state = false,
    callback = function(bool)
        toggles.teamcheck = bool;
    end
});
aimbot:AddToggle({
    text = "Visible Check",
    state = false,
    callback = function(bool)
        toggles.vischeck = bool;
    end
});
weapons:AddToggle({
    text = "No Recoil",
    state = false,
    callback = function(bool)
        toggles.norecoil = bool;
    end
});
weapons:AddToggle({
    text = "No Spread",
    state = false,
    callback = function(bool)
        toggles.nospread = bool;
    end
});
weapons:AddToggle({
    text = "Fast Firerate",
    state = false,
    callback = function(bool)
        toggles.fastfirerate = bool;
    end
});
movement:AddSlider({
    text = "Sprint Multiplier",
    min = 0,
    max = 10,
    callback = function(value)
        setconstant(controlfunc, table.find(getconstants(controlfunc), oldmult), value);
        oldmult = value;
    end
});
movement:AddToggle({
    text = "Fly",
    state = false,
    callback = function(bool)
        toggles.fly = bool;
    end
});
movement:AddSlider({
    text = "Fly Speed",
    min = 100,
    max = 200,
    callback = function(speed)
        toggles.flyspeed = speed;
    end
});
library:Init();
