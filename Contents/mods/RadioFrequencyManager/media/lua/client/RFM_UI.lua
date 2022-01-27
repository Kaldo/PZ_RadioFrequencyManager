require "ISUI/ISPanel"
require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISResizeWidget"
require "ISUI/ISMouseDrag"
require "ISUI/ISRadioButtons"
require "ISUI/ISTextEntryBox"

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small);
local mysplit = function(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end


RadioFrequencyManagerUI = ISCollapsableWindow:derive("RadioFrequencyManagerUI")

function RadioFrequencyManagerUI:new(parent)
    local mD = self:loadModData();

    local panelWidth = mD.panelSettings.width;
    local panelHeight = mD.panelSettings.height;
    local startingX = mD.panelSettings.x;
    local startingY = mD.panelSettings.y;

    local o = {}
    o = ISCollapsableWindow:new(startingX, startingY, panelWidth, panelHeight);
    setmetatable(o, self);
    self.__index = self;
    o.title = "Radio Frequency Manager";
    o.x = startingX;
    o.y = startingY;
    o.width = panelWidth;
    o.height = panelHeight;
    o.resizable = true;
    o.drawFrame = true;
    o.borderColor = {r=0.4, g=0.4, b=0.4, a=1};
    o.backgroundColor.a = 0.9;
    o.moveWithMouse = true;

    o.prnt = parent;
    o.storedChannels = mD.storedChannels;
    o.renderedChannels = {};

    o:initialise();
    o:addToUIManager();

    o:setInfo("test text");

    return o;
end

function RadioFrequencyManagerUI:initialise()
    ISCollapsableWindow.initialise(self);
    self:create();
end

function RadioFrequencyManagerUI:prerender()
    ISCollapsableWindow.prerender(self);
end

function RadioFrequencyManagerUI:render()
    ISCollapsableWindow.render(self);
end

function RadioFrequencyManagerUI:create()
    -- "Toolbar" buttons - Import/Export
    self.copyButton = ISButton:new(15, 25, 25, 25, "Copy from radio", self, self.onCopy);
    self.copyButton:initialise();
    self.copyButton:instantiate();
    self.copyButton.borderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.5};
    self:addChild(self.copyButton);

    self.customButton = ISButton:new(self.copyButton:getRight() + 10, 25, 25, 25, "Custom", self, self.onCustomAdd);
    self.customButton:initialise();
    self.customButton:instantiate();
    self.customButton.borderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.5};
    self:addChild(self.customButton);

    -- Render rows
    self:renderStoredChannels();
end

function RadioFrequencyManagerUI:renderStoredChannels()
    -- clear rendered channels
    for _, rc in ipairs(self.renderedChannels) do
        rc.statusBtn:removeFromUIManager();
        rc.contentBtn:removeFromUIManager();
        rc.deleteBtn:removeFromUIManager();
        rc.prnt:removeChild(rc.statusBtn);
        rc.prnt:removeChild(rc.contentBtn);
        rc.prnt:removeChild(rc.deleteBtn);
    end
    for i, _ in ipairs(self.renderedChannels) do
        self.renderedChannels[i] = nil;
    end
    self.renderedChannels = {};

    table.sort(self.storedChannels, function(a, b) return a.Freq < b.Freq end);

    -- insert stored channels
    local idx = 0;
    for _, channel in ipairs(self.storedChannels) do
        table.insert(self.renderedChannels, self.createChannelRow(self, channel, idx));
        idx  = idx + 1;
    end

    -- save changes
    self:saveModData();
end

function RadioFrequencyManagerUI.createChannelRow(parent, channel, index)
    local freqHeight = 25;
    local deleteWidth = freqHeight;
    local freqOffsetX = 10;
    local freqOffsetY = parent.copyButton:getBottom() + 15 + (index * freqHeight);
    local freqWidth = parent.width - (2 * freqOffsetX) - (2 * deleteWidth);

    local STATE_TABLE = {
        [1] = "media/ui/RadioCircleGreen.png", 
        [2] = "media/ui/RadioCircleYellow.png", 
        [3] = "media/ui/RadioCircleRed.png",
        [4] = "media/ui/RadioCircleGray.png"
    };

    local status = ISButton:new(freqOffsetX, freqOffsetY, deleteWidth, freqHeight, "", parent, RadioFrequencyManagerUI.onStatusClicked);
    status:initialise();
    status:instantiate();
    status.backgroundColor.a = 0;
    status.backgroundColorMouseOver.a = 0;
    status:setImage(getTexture(STATE_TABLE[channel.State]));
    status.borderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.5};
    parent:addChild(status);

    local contentText = (channel.Freq / 1000) .. " - " .. channel.Name;
    local content = ISButton:new(status:getRight(), status:getBottom() - freqHeight,
        freqWidth, freqHeight, contentText, parent, RadioFrequencyManagerUI.onTuneIn);
    content:initialise();
    content:instantiate();
    content.borderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.5};
    parent:addChild(content);

    local delete = ISButton:new(content:getRight(), content:getBottom() - freqHeight, deleteWidth, freqHeight, "X", parent,
        RadioFrequencyManagerUI.onChannelDelete);
    delete:initialise();
    delete:instantiate();
    delete.borderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.5};
    parent:addChild(delete);

    local r = {};
    r.MyID = channel.MyID;
    r.Freq = channel.Freq;
    r.Name = channel.Name;
    r.statusBtn = status;
    r.contentBtn = content;
    r.deleteBtn = delete;
    r.prnt = parent;
    r.statusBtn.prnt = r;
    r.contentBtn.prnt = r;
    r.deleteBtn.prnt = r;
    return r;
end

function RadioFrequencyManagerUI:close()
	ISCollapsableWindow.close(self)

    self:saveModData();

    if self.prnt then
        self.prnt.instance = nil;
    end
    self:setVisible(false);
    self:removeFromUIManager();
    -- if self:getIsVisible() then
    --     -- self:setVisible(false);
    --     self.parent.instance = nil; -- If you use parent
    --     self:setVisible(false);
    --     self:removeFromUIManager();
    -- else
    --     -- self:renderCategoryButtons();
    --     self:setVisible(true);
    -- end
end

function RadioFrequencyManagerUI:onStatusClicked(button, x, y)
    for _, channel in ipairs(self.storedChannels) do
        if channel.MyID == button.prnt.MyID then
            channel.State = channel.State + 1;
            if channel.State > 4 then
                channel.State = channel.State - 4;
            end
            break;
        end
    end
    self:renderStoredChannels();
end

function RadioFrequencyManagerUI:onTuneIn(button, x, y)
    local channelElement = self:getRadioChannelElement();
    if (channelElement == nil) then
        return;
    end
    local rwmChannelSubpanel = channelElement.subpanel;

    -- Check if the channel preset already exists and tune to it instead of creating a new preset
    for idx, _ in ipairs(rwmChannelSubpanel.comboBox.options) do
        local f = rwmChannelSubpanel.presets:get(idx - 1):getFrequency();
        if f == button.prnt.Freq then
            rwmChannelSubpanel.comboBox.selected = idx;
            ISTimedActionQueue.add(ISRadioAction:new("SetChannel", rwmChannelSubpanel.player, rwmChannelSubpanel.device, f));
            return;
        end
    end


    -- Create new preset
    local frequency = button.prnt.Freq;
    local freq = button.prnt.Freq / 1000;
    local name = button.prnt.Name;

    rwmChannelSubpanel:doAddPresetButton();
    rwmChannelSubpanel.editPresetPanel.setValues(rwmChannelSubpanel.editPresetPanel, name, freq, freq, freq, 1, 0);
    rwmChannelSubpanel.editPresetPanel.doSaveButton(rwmChannelSubpanel.editPresetPanel);

    -- Tune to it
    if rwmChannelSubpanel:doWalkTo() then
        ISTimedActionQueue.add(ISRadioAction:new("SetChannel", rwmChannelSubpanel.player, rwmChannelSubpanel.device, frequency));
    end
end

function RadioFrequencyManagerUI:onChannelDelete(button, x, y)
    local idxToDelete = 0;
    for key, channel in ipairs(self.storedChannels) do
        if channel.MyID == button.prnt.MyID then
            idxToDelete = key;
            break;
        end
    end
    table.remove(self.storedChannels, idxToDelete);

    self:renderStoredChannels();
end

function RadioFrequencyManagerUI:getNewChannelId()
    local newID = 0;
    for _, channel in ipairs(self.storedChannels) do
        if (channel.MyID >= newID) then
            newID = channel.MyID + 1;
        end
    end
    return newID;
end

function RadioFrequencyManagerUI:onCopy()
    local channelElement = self:getRadioChannelElement();
    if (channelElement == nil) then
        return;
    end
    
    -- Get selected preset to copy
    local rwmChannelSubpanel = channelElement.subpanel; -- buttons are here: .editPresetButton, tuneInButton, deletePresetButton, openRfmButton, ...
    local p = rwmChannelSubpanel.presets:get(rwmChannelSubpanel.comboBox.selected - 1);
    if not p then
        print("Could not load selected channel");
        return;
    end

    -- Save channel to manager
    local newID = self:getNewChannelId();
    table.insert(self.storedChannels, { MyID = newID, Freq = p:getFrequency(), Name = p:getName(), State = 1 });
    self:renderStoredChannels();
end

function RadioFrequencyManagerUI:onCustomAdd(button)
    local closeCustom = function()
        button.isOpen = false;
        button.backgroundColor = {r = 0, g = 0, b = 0, a = 1};
        self.textEntry:setVisible(false);
        self.textEntryClose:setVisible(false);
    end
    if button.isOpen == true then
        button.isOpen = false;
        button.backgroundColor = {r = 0, g = 0, b = 0, a = 1};
        self.textEntry:setVisible(false);
        self.textEntryClose:setVisible(false);

        -- Input validations
        local newID = self:getNewChannelId();
        local input = self.textEntry:getInternalText();
        if input == nil then return end
        if input:find(",", 1, true) == nil then return end
        local spl = mysplit(input, ",");
        if #spl < 2 then return end
        local freq = tonumber(spl[1]);
        if freq == nil then return end
        freq = freq * 1000;
        local name = spl[2];

        table.insert(self.storedChannels, { MyID = newID, Freq = freq, Name = name, State = 1 });
        self:renderStoredChannels();
    elseif self.TextEntry then
        button.isOpen = true;
        button.backgroundColor = {r = 0, g = 0.4, b = 0, a = 1};
        self.textEntry:setVisible(true);
        self.textEntryClose:setVisible(true);
    else
        button.isOpen = true;
        button.backgroundColor = {r = 0, g = 0.4, b = 0, a = 1};
        local y = button:getBottom() - button.height;

        self.textEntryClose = ISButton:new(button:getRight() + 4, y, button.height, button.height, "X", self, closeCustom);
        self.textEntryClose:initialise();
        self.textEntryClose:instantiate();
        self.textEntryClose.borderColor = {r = 0.7, g = 0.7, b = 0.7, a = 0.5};
        self.textEntryClose.backgroundColor = {r = 0.7, g = 0, b = 0, a = 1};
        self:addChild(self.textEntryClose);

        self.textEntry = ISTextEntryBox:new("100.00, My radio station", self.textEntryClose:getRight() + 4, y, 200, button.height);
        self.textEntry.backgroundColor = {r=0, g=0, b=0, a=1};
        self.textEntry.borderColor = {r=1, g=0, b=0, a=1};
        self.textEntry:initialise();
        self.textEntry:instantiate();
        self:addChild(self.textEntry);
    end
end

function RadioFrequencyManagerUI:getRadioChannelElement()
    local player = getPlayer();
    local playerNum = player:getPlayerNum();
    local radioInstances = ISRadioWindow.instances;
    local radioInstancesIso = ISRadioWindow.instancesIso;

    local radioInstance = nil;
    if radioInstances and radioInstances[playerNum] then
        radioInstance = radioInstances[playerNum];
    end
    if radioInstancesIso and radioInstancesIso[playerNum] then
        radioInstance = radioInstancesIso[playerNum];
    end
    if radioInstance == nil then
        print("radioInstances: Radio window not open or doesnt exist");
        return nil;
    end

    local channelInstance = radioInstance.modules[8];
    if channelInstance.enabled == false then
        print "radio disabled?";
        return nil;
    end

    local channelElement = channelInstance.element;
    return channelElement;
end

function RadioFrequencyManagerUI:loadModData()
    local player = getPlayer();
    if player then
        local modData = player:getModData()
        local reset = false;
        if modData.Kaldo_RFM == nil or reset == true then
            modData.Kaldo_RFM = {
                storedChannels = {},
                panelSettings = { x = 70, y = 400, width = 400, height = 300 };
            }
        end
        return modData.Kaldo_RFM;
    end
    print("ERROR: failed to load player and mod data.");
    return nil;
end

function RadioFrequencyManagerUI:saveModData()
    local player = getPlayer();
    local modData =  player:getModData()
    modData.Kaldo_RFM.storedChannels = self.storedChannels;
    modData.Kaldo_RFM.panelSettings = {
        x = self.x;
        y = self.y;
        width = self.width;
        height = self.height;
    };
    player:transmitModData();
end

-- way too inefficient to do on every run. find a way to only do it on last update
-- function RadioFrequencyManagerUI:onResize()
--     self.width = self:getWidth();
--     self.height = self:getHeight();
--     self:renderStoredChannels();
-- end