local Addon = ...
local MixinGlobal = Addon.."BackdropTemplateMixin"

_G[MixinGlobal] = {}
if (BackdropTemplateMixin) then
    _G[MixinGlobal] = CreateFromMixins(BackdropTemplateMixin)
end
