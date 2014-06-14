program gridreg
local dataset `1'
local command `2'
local saveas `3'

shell ./batchgridreg.sh `dataset' "`command'" `saveas'

end
