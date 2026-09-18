--[[
    Horizon Suite - Options - Platform Prune
    Runs once, after every options module has registered its categories and
    before the search index and dashboard read them: strips rows and Section
    headers whose `requires` capability the current client lacks (see
    core/Platform.lua). Category option lists that are functions are wrapped so
    the prune applies each time they are built.
]]

local addon = _G.HorizonSuite
if not addon or not addon.OptionCategories or not addon.PruneOptionsForPlatform then return end

for _, category in ipairs(addon.OptionCategories) do
    local options = category.options
    if type(options) == "function" then
        category.options = function(...)
            return addon.PruneOptionsForPlatform(options(...))
        end
    elseif type(options) == "table" then
        category.options = addon.PruneOptionsForPlatform(options)
    end
end
