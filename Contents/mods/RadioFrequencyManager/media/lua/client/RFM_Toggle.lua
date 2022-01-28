require "ISUI/ISPanel" -- Or require "ISUI/ISPanelJoypad"
require "ISUI/ISButton"

-- local RadioFrequencyManagerUI = RadioFrequencyManagerUI;

-- local KaldoRFM_UI = KaldoRFM_UI;

RfmToggleButton = ISPanel:derive("RfmToggleButton");

function RfmToggleButton:createToggleButton()
    print("RFM - Create new toggle button")

    local startingX = 10;
    local startingY = 400;

    local toggleButton = ISPanel:new(startingX, startingY, 50, 50);
    toggleButton.moveWithMouse = true;

    toggleButton.mybutton = ISButton:new(10, 10, 30, 30, "RFM", self, self.onClick);
    toggleButton:addChild(toggleButton.mybutton);

    toggleButton:addToUIManager();
end

-- function RfmToggleButton:onMainButtonClicked(button, x, y)
    -- if self.instance == nil then
    --     print("RFM - window not initialized - create new window");
    --     self.instance = RadioFrequencyManagerUI:new(button);
    -- else
    --     print("RFM - window exists - handle toggling");
    --     self.instance:close();
    --     self.instance = nil;
    --     -- instance = nil
    -- end
-- end

function RfmToggleButton:onClick()
    KaldoRFM_UI.toggle()
end

function RfmToggleButton:onGameStart()
    RfmToggleButton:createToggleButton()
end

-- Events.OnSave.Add(RfmToggleButton.onSave);
Events.OnGameStart.Add(RfmToggleButton.onGameStart);
