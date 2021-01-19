local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()
local Windows = {} do
    local Menu = {} do
        Menu.__index = Menu
        function Menu:Button(...)
            self.Main.Button(...)
        end
        function Menu:Toggle(...)
            self.Main.Toggle(...)
        end
        function Menu:Slider(...)
            self.Main.Slider(...)
        end
        function Menu:Dropdown(...)
            self.Main.Dropdown(...)
        end
        function Menu:ColorPicker(...)
            self.Main.ColorPicker(...)
        end
        function Menu:Text(...)
            self.Main.TextField(...)
        end
        function Menu:Section(...)
            self.Main.Label(...)
        end
        function Menu:Chipset(...)
            self.Main.ChipSet(...)
        end
        function Menu:Tab(...)
            return setmetatable({
                Main = self.Main.New(...)
            }, Menu)
        end
    end
    function Windows.new(Title)
        return setmetatable({
            Main = Material.Load({
                Title = Title,
                Style = 2,
                Theme = "Dark",
                SizeX = 525,
                SizeY = 620,
            })
        }, Menu)
    end
end
return Windows
