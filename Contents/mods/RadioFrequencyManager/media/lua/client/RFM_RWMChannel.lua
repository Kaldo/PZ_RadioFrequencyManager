require "RadioCom/RadioWindowModules/RWMChannel"

KaldoRFM = {};

KaldoRFM.RWMChannel_new = RWMChannel.new;
function RWMChannel:new(x, y, width, height)
    local o = KaldoRFM.RWMChannel_new(self, x, y, width, height + 30);
    o.height = o.height + 30;
    return o;
end

KaldoRFM.RWMChannel_createChildren = RWMChannel.createChildren;
function RWMChannel:createChildren()
    KaldoRFM.RWMChannel_createChildren(self);

    local x = self.editPresetButton:getRight() - self.editPresetButton.width;
    local y = self.editPresetButton:getBottom() + 5;

    self.openRfmButton = ISButton:new(x, y, 60, 30, "RFM", self, RWMChannel.openRadioFrequencyManager);
    self.openRfmButton:initialise();
    self.openRfmButton:instantiate();
    -- self.openRfmButton.backgroundColor = {r=0, g=0, b=0, a=0.0};
    -- self.openRfmButton.backgroundColorMouseOver = {r=1.0, g=1.0, b=1.0, a=0.1};
    -- self.openRfmButton.borderColor = {r=1.0, g=1.0, b=1.0, a=0.3};
    self:addChild(self.openRfmButton);

    self.height = self.height + 20;

    self:setPanelMode(false, true);
end

function RWMChannel:openRadioFrequencyManager()
    print(">>>>>>> open RFM")
end