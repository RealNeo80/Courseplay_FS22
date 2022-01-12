--[[
This file is part of Courseplay (https://github.com/Courseplay/courseplay)
Copyright (C) 2019-2022 Peter Vaiko

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]

--- Controller for bale loaders. Not much to do here as long as we do not unload the bales,
--- loading them is pretty straightforward and automatic, once they are in range.

---@class BaleLoaderController : ImplementController
BaleLoaderController = CpObject(ImplementController)

function BaleLoaderController:init(vehicle)
    self.baleLoader = AIUtil.getImplementWithSpecialization(vehicle, BaleLoader)
    ImplementController.init(self, vehicle, self.baleLoader)

    if self.baleLoader then
        -- Bale loaders have no AI markers (as they are not AIImplements according to Giants) so add a function here
        -- to get the markers
        self:registerOverwrittenFunction(self.baleLoader,"getAIMarkers",
            function(object)
                return ImplementUtil.getAIMarkersFromGrabberNode(object, object.spec_baleLoader)
            end)
    
        --- Registers event listeners for folding/unfolding of the bale loader.
        local function unfoldLoader(loader,superFunc,...)
            if superFunc ~= nil then superFunc(loader,...) end
            loader:doStateChange(BaleLoader.CHANGE_MOVE_TO_WORK)
        end
        local function foldLoader(loader,superFunc,...)
            if superFunc ~= nil then superFunc(loader,...) end
            local spec = loader.spec_baleLoader
            if not spec.grabberIsMoving and spec.grabberMoveState == nil and spec.isInWorkPosition then
                loader:doStateChange(BaleLoader.CHANGE_MOVE_TO_TRANSPORT);
            end
        end
        self:registerOverwrittenFunction(BaleLoader,"onAIImplementStart",unfoldLoader)
        self:registerAIEvents(BaleLoader,"onAIImplementStart")
        self:registerOverwrittenFunction(BaleLoader,"onAIImplementEnd",foldLoader)
        self:registerAIEvents(BaleLoader,"onAIImplementStart")
    end
    self:debug('Bale loader controller initialized')
end

function BaleLoaderController:isGrabbingBale()
    return self.baleLoader.spec_baleLoader.grabberMoveState
end
