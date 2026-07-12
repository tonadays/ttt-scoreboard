TTSB = TTSB or {} -- terrortown scoreboard

TTSB.Version = "1.0.0"
TTSB.Ranks = {}

-- TTSB.Ranks["rank OR steamid"] = { name = "displayname", color = RankColor, namecolor = (optional), admin = are they admin? (true/false) }
-- TTSB.Ranks["superadmin"] = { name = "S. Admin", color = Color(255, 0, 0), namecolor = Color(0, 255, 0), admin = true }
-- TTSB.Ranks["admin"] = { name = "Admin", color = Color(150, 100, 100), admin = true }
-- TTSB.Ranks["donator"] = { name = "Donator", color = Color(100, 200, 100), admin = false }

TTSB.Ranks["dev"] = {
    name = " ",
    color = Color(158, 144, 233),
    namecolor = Color(158, 144, 233),
    admin = true,
    icon = "wrench"
}

TTSB.Ranks["superadmin"] = {
    name = " ",
    color = Color(255, 100, 100),
    admin = true,
    icon = "shield"
}

TTSB.Ranks["admin"] = {
    name = " ",
    color = Color(255, 100, 100),
    admin = true,
    icon = "shield"
}

TTSB.Ranks["mod"] = {
    name = " ",
    color = Color(255, 167, 89),
    admin = true,
    icon = "shield"
}

-- original TTT-EasyScoreboard developer
-- it would be nice if you left this in :)
TTSB.Ranks["STEAM_0:1:45852799"] = { namecolor = "rainbow", icon = "bug", admin = false }

-- label enable on the top? what should it say?
TTSB.CreateRankLabel = { enabled = true, text = "Rank" }

-- what to show when the player doesnt have an entry
TTSB.DefaultLabel = " "

-- sadly there is no way to shift the background bar over as TTT draws it manually :c
TTSB.HideBackground = false

-- Width of the rank columns
TTSB.ColumnWidth = 50

-- the number of columns (not pixels!!!!!!!) to shift to the left
TTSB.ShiftLeft = 0

-- shift tags, search marker, etc how much? (IN PIXELS)
TTSB.ShiftOthers = 200

-- Show icon as well as rank text? (if possible)
TTSB.ShowIconsWithRanks = true

-- Fix the icon next to the rank? (Horizontal align)
TTSB.FixedIcon = false

-- Should the icon shift to the left to accomodate the label?
TTSB.ShiftIconsWithLabels = false

-- if ^ is false, where should the icons go (like TTSB.ShiftLeft)?
TTSB.ShiftIconsLeft = 0

-- How far left should we shift the icon RELATIVE to the rank text?
TTSB.ShiftRankIcon = 6

-- should we color the names?
TTSB.UseNameColors = true

-- if there is no name color set, should we use the rank color?
TTSB.DefaultNameColorToRankColor = false

-- should names get dynamic (changing) color?
TTSB.AllowNamesToHaveDynamicColor = true

TTSB.DynamicColors = {}

TTSB.DynamicColors.rainbow = function(ply)
    local frequency, time = .5, RealTime()
    local red = math.sin(frequency * time) * 127 + 128
    local green = math.sin(frequency * time + 2) * 127 + 128
    local blue = math.sin(frequency * time + 4) * 127 + 128
    return Color(red, green, blue)
end

--- Utility method for sanitized player targeting by name
local function TargetNick(ply)
    return ply:Nick():gsub(";", ""):gsub('"', "")
end

--- Utility method for sanitized player targeting
---@param ply Player
local function Target(ply)
    local id = ply:SteamID()
    if (id == "BOT" or id == "STEAM_ID_LAN") then
        return TargetNick(ply)
    else
        return "$" .. id
    end
end

---@class TTSB.RightClickOption
---@field name? string
---@field icon? string
---@field admin? boolean if present, a player's TTSB rank must be specified as an admin rank
---@field allowedGroups? table<string, boolean> if present, a player's ULX group must be set to true in this table
---@field command? string if present, the player's permission will be checked with against this string using ULib.ucl.query()
---@field prompt? boolean if present, prompts the user for confirmation when clicking this option
---@field condition? fun(ply: Player): boolean if present, the option is only available when this function returns true
---@field func fun(ply: Player)

---@class TTSB.RightClickGroup
---@field admin? boolean if present, a player's TTSB rank must be specified as an admin rank
---@field allowedGroups? table<string, boolean> if present, a player's ULX group must be set to true in this table
---@field options TTSB.RightClickOption[]

---@type { enabled: boolean, groups: TTSB.RightClickGroup[] }
TTSB.RightClickFunction = {
    enabled = true,
    groups = {
        {
            options = {
                {
                    name = "Show Profile",
                    func = function(ply)
                        ply:ShowProfile()
                    end,
                    icon = "icon16/vcard.png"
                },
                {
                    admin = true,
                    name = "Print Friends",
                    icon = "icon16/group.png",
                    command = "ulx friends",
                    func = function(ply)
                        RunConsoleCommand("ulx", "friends", Target(ply))
                    end
                },
                {
                    name = "Copy SteamID",
                    icon = "icon16/tag.png",
                    func = function(ply)
                        SetClipboardText(ply:SteamID())
                        chat.AddText(
                            color_white, ply:Nick() .. "'s SteamID (",
                            Color(200, 200, 200), ply:SteamID(),
                            color_white, ") copied to clipboard!"
                        )
                    end,
                },
                {
                    name = "Copy SteamID64",
                    icon = "icon16/tag.png",
                    func = function(ply)
                        SetClipboardText(ply:SteamID64())
                        chat.AddText(
                            color_white, ply:Nick() .. "'s SteamID64 (",
                            Color(200, 200, 200), ply:SteamID64(),
                            color_white, ") copied to clipboard!"
                        )
                    end,
                },
            }
        },
        {
            admin = true,
            options = {
                {
                    name = "Force Spec",
                    icon = "icon16/status_away.png",
                    command = "ulx fspec",
                    func = function(ply)
                        RunConsoleCommand("ulx", "fspec", Target(ply))
                    end,
                },
                {
                    name = "Unspec",
                    icon = "icon16/status_online.png",
                    command = "ulx unspec",
                    func = function(ply)
                        RunConsoleCommand("ulx", "unspec", Target(ply))
                    end,
                },
            }
        },
        {
            admin = true,
            options = {
                -- These are commented out for now because I want them to prompt the admin to set a reason
                -- {
                --     name = "Kick",
                --     icon = "icon16/disconnect.png",
                --     command = "ulx kick",
                --     prompt = true,
                --     func = function(ply)
                --         RunConsoleCommand("ulx", "kick", Target(ply))
                --     end,
                -- },
                -- {
                --     name = "Ban",
                --     icon = "icon16/delete.png"
                --     command = "ulx ban",
                --     prompt = true,
                --     func = function(ply)
                --         RunConsoleCommand("ulx", "ban", Target(ply))
                --     end,
                -- },
                {
                    name = "Slay",
                    icon = "icon16/bomb.png",
                    command = "ulx slay",
                    prompt = true,
                    condition = function(ply)
                        return ply:Alive()
                    end,
                    func = function(ply)
                        RunConsoleCommand("ulx", "slay", Target(ply))
                    end,
                },
                {
                    name = "Respawn",
                    icon = "icon16/group_add.png",
                    command = "ulx respawn",
                    prompt = true,
                    condition = function(ply)
                        return not ply:Alive()
                    end,
                    func = function(ply)
                        RunConsoleCommand("ulx", "respawn", Target(ply))
                    end,
                },
                -- {
                --     name = "Respawn TP",
                --     icon = "icon16/group_link.png",
                --     command = "ulx respawntp",
                --     prompt = true,
                --     func = function(ply)
                --         RunConsoleCommand("ulx", "respawntp", Target(ply))
                --     end,
                -- },
            }
        },
        {
            admin = true,
            options = {
                {
                    name = "Mute",
                    icon = "icon16/keyboard_delete.png",
                    command = "ulx mute",
                    condition = function(ply)
                        return not ply:GetNWBool("ulx_muted")
                    end,
                    func = function(ply)
                        RunConsoleCommand("ulx", "mute", Target(ply))
                    end,
                },
                {
                    name = "Un-Mute",
                    icon = "icon16/keyboard_add.png",
                    command = "ulx unmute",
                    condition = function(ply)
                        return ply:GetNWBool("ulx_muted")
                    end,
                    func = function(ply)
                        RunConsoleCommand("ulx", "unmute", Target(ply))
                    end,
                },
                {
                    name = "Gag",
                    icon = "icon16/sound_mute.png",
                    command = "ulx gag",
                    condition = function(ply)
                        return not ply:GetNWBool("ulx_gagged")
                    end,
                    func = function(ply)
                        RunConsoleCommand("ulx", "gag", Target(ply))
                    end,
                },
                {
                    name = "Un-Gag",
                    icon = "icon16/sound.png",
                    command = "ulx ungag",
                    condition = function(ply)
                        return ply:GetNWBool("ulx_gagged")
                    end,
                    func = function(ply)
                        RunConsoleCommand("ulx", "ungag", Target(ply))
                    end,
                },
            }
        },
        {
            admin = true,
            options = {
                {
                    name = "Goto",
                    icon = "icon16/arrow_right.png",
                    command = "ulx goto",
                    prompt = true,
                    func = function(ply)
                        RunConsoleCommand("ulx", "goto", Target(ply))
                    end,
                },
                {
                    name = "Bring",
                    icon = "icon16/arrow_left.png",
                    command = "ulx bring",
                    prompt = true,
                    func = function(ply)
                        RunConsoleCommand("ulx", "bring", Target(ply))
                    end,
                },
            }
        },
        -- {
        --     admin = true,
        --     options = {}
        -- },
    }
}

hook.Run("TTSB_AddRightClickFunction", TTSB.RightClickFunction.groups)

local function IsKarmaEnabled()
    return GetConVar("ttt_karma"):GetBool()
end

for id, rank in pairs(TTSB.Ranks) do
    if rank.icon then
        rank.iconmat = Material(("icon16/%s.png"):format(rank.icon))
    end
    rank.dynamic_col = isstring(rank.color)
    rank.dynamic_namecol = isstring(rank.namecolor)
end

local function RealUserGroup(ply)
    if ply.EV_GetRank then return ply:EV_GetRank() end
    return ply:GetUserGroup()
end

function TTSB.GetRank(ply)
    return TTSB.Ranks[ply:SteamID()] or TTSB.Ranks[RealUserGroup(ply)]
end

function TTSB.Dynamic(rank, ply)
    return (TTSB.DynamicColors[rank.color] or TTSB.DynamicColors.rainbow)(ply)
end

function TTSB.HandleShift(sb)
    if TTSB.ShiftLeft < 1 then return end

    local function ShiftLeft(parent)
        local k = TTSB.HideBackground and 6 or 5
        local p = parent.cols[k]

        if not p then return end

        local shift = TTSB.HideBackground and 1 or 0
        local karma = IsKarmaEnabled() and 0 or 1
        local left = (5 - karma) - TTSB.ShiftLeft
        local posx, posy = p:GetPos()
        local mod = (50 * ((left + shift) - #parent.cols))

        p:SetPos(posx + mod, posy)
    end

    if sb.ply_groups then -- sb_main
        local OldPerformLayout = sb.PerformLayout
        sb.PerformLayout = function(s)
            OldPerformLayout(s)
            ShiftLeft(s)
        end
    else -- sb_row
        local OldLayoutColumns = sb.LayoutColumns
        sb.LayoutColumns = function(s)
            OldLayoutColumns(s)
            ShiftLeft(s)
            TTSB.HandleTags(s)
        end
    end
end

function TTSB.HandleTags(sb)
    if TTSB.ShiftOthers <= 0 then return end

    -- copy some from base
    local cx = sb:GetWide() - 90
    for k, v in ipairs(sb.cols) do
        cx = cx - v.Width
    end

    sb.tag:SizeToContents()
    sb.tag:SetPos((cx - sb.tag:GetWide() / 2) - TTSB.ShiftOthers, (SB_ROW_HEIGHT - sb.tag:GetTall()) / 2)

    sb.sresult:SizeToContents()
    sb.sresult:SetPos((cx - 8) - TTSB.ShiftOthers, (SB_ROW_HEIGHT - 16) / 2)
end

function TTSB.AddSpacer(w)
    TTSB.Scoreboard:AddColumn("", function() return "" end, w or 0)
end

function TTSB.AddRankLabel(sb)
    TTSB.Scoreboard = sb
    local heading = TTSB.CreateRankLabel.enabled and TTSB.CreateRankLabel.text or ""

    local function AttachDynamicColor(label, ply)
        label.HasRainbow = true
        label.Think = function(s)
            if not IsValid(ply) then return end
            local rank = TTSB.GetRank(ply)
            if not rank then
                s:SetTextColor(color_white)
                return
            end

            if not rank.dynamic_col then
                s:SetTextColor(rank.color)
            else
                s:SetTextColor(TTSB.Dynamic(rank, ply))
            end
        end
        sb.nick.Think = function(s)
            if not IsValid(ply) then return end
            local rank = TTSB.GetRank(ply)
            if not rank then
                s:SetTextColor(color_white)
                return
            end

            if not rank.dynamic_col then
                s:SetTextColor(rank.color)
            else
                if TTSB.AllowNamesToHaveDynamicColor then
                    s:SetTextColor(TTSB.Dynamic(rank, ply))
                end
            end
        end
    end

    if TTSB.HideBackground and IsKarmaEnabled() then -- ttt pls
        TTSB.AddSpacer()
    end

    sb:AddColumn(heading, function(ply, label)
        local rank = TTSB.GetRank(ply)
        label:SetName("TTSB")

        local ov_name = hook.Run("TTSB_GetPlayerRankName", ply)
        if ov_name and not rank then return ov_name end

        if not rank and not ov_name then return TTSB.DefaultLabel end

        if rank.offset then
            local px, py = label:GetPos()
            label:SetPos(px - rank.offset, py)
        end

        if rank.icon and not rank.iconmat:IsError() and not TTSB.FixedIcon then
            label.Paint = function(s, w, h)
                DisableClipping(true)
                surface.SetDrawColor(color_white)
                surface.SetMaterial(rank.iconmat)

                local posx = -(rank.iconmat:Width() / 2)

                if rank.name and TTSB.ShowIconsWithRanks then
                    if TTSB.ShiftIconsWithLabels then
                        posx = -(s:GetTextSize()) - TTSB.ShiftRankIcon
                    else
                        posx = -TTSB.ShiftIconsLeft * TTSB.ColumnWidth - TTSB.ShiftRankIcon
                    end
                end

                surface.DrawTexturedRect(posx, -1, rank.iconmat:Width(), rank.iconmat:Height())
                DisableClipping(false)
            end

            if not rank.name then return " " end
        end

        if not rank.dynamic_col then
            label.Think = function(s)
                if not IsValid(ply) then return end
                local rank = TTSB.GetRank(ply)
                if not rank then return end

                if not rank.dynamic_col then
                    s:SetTextColor(rank.color)
                else
                    s:SetTextColor(TTSB.Dynamic(rank, ply))
                end
            end
        elseif not label.AttachedDynamicColors then
            AttachDynamicColor(label, ply)
        end

        if ov_name then return ov_name end
        return rank.name or ""
    end, TTSB.ColumnWidth)

    if TTSB.FixedIcon then
        sb:AddColumn("", function(ply, label)
            local rank = TTSB.GetRank(ply)
            label:SetName("TTSB-icon")
            if not rank then return "" end

            if rank.icon and not rank.iconmat:IsError() then
                label.Paint = function(s, w, h)
                    DisableClipping(true)
                    surface.SetDrawColor(color_white)
                    surface.SetMaterial(rank.iconmat)

                    local posx = (rank.iconmat:Width() / 2) + TTSB.ColumnWidth / 4

                    surface.DrawTexturedRect(posx, -1, rank.iconmat:Width(), rank.iconmat:Height())
                    DisableClipping(false)
                end
            end

            return " "
        end, TTSB.ColumnWidth)
    end

    TTSB.HandleShift(sb)

    hook.Run("TTSB_AddColumns", sb)
end

hook.Add("TTTScoreboardColumns", "TTSB_Columns", TTSB.AddRankLabel)

function TTSB.AddNameColor(ply)
    if not TTSB.UseNameColors then return end
    local rank = TTSB.GetRank(ply)
    if not rank then return color_white end

    local color = rank.namecolor
    if not color and TTSB.DefaultNameColorToRankColor then color = rank.color end
    if rank.dynamic_namecol then
        if TTSB.AllowNamesToHaveDynamicColor then color = TTSB.Dynamic(rank, ply) end
        return IsColor(color) and color or color_white
    elseif color and IsColor(color) then
        return color
    end
end

hook.Add("TTTScoreboardColorForPlayer", "TTSB_NameColors", TTSB.AddNameColor)

---@class DMenu
---@field Player Player not normal, added by ttt in terrortown/gamemode/vgui/sb_row.lua

---@class ULib
---@field ucl ULib.ucl

---@class ULib.ucl
---@field query fun(ply: Player, access?: string, hide?: boolean): boolean

---@type ULib
local ULib = ULib

---@param menu DMenu
function TTSB.AddMenu(menu)
    local RCF = TTSB.RightClickFunction
    if not RCF.enabled then return nil end

    local ply = LocalPlayer()
    local playerRank = TTSB.GetRank(ply)
    local playerGroup = ply:GetUserGroup()
    local targetPly = menu.Player

    for _, group in ipairs(TTSB.RightClickFunction.groups) do
        -- permission checks
        if (group.admin) then
            if not playerRank then continue end
            if not playerRank.admin then continue end
        end
        if (group.allowedGroups) then
            if not group.allowedGroups[playerGroup] then continue end
        end
        -- loop options
        local empty = true
        for _, option in ipairs(group.options) do
            -- permission checks
            if (option.admin) then
                if not playerRank then continue end
                if not playerRank.admin then continue end
            end
            if (option.allowedGroups) then
                if not option.allowedGroups[playerGroup] then continue end
            end
            if (option.command) then
                if not ULib.ucl.query(ply, option.command) then continue end
            end
            if (option.condition) then
                if not option.condition(targetPly) then continue end
            end
            -- add option
            local menuOption = menu:AddOption(option.name or "", function()
                if not IsValid(ply) then return end
                if not IsValid(targetPly) then return end
                if (option.prompt) then
                    local label = option.name or option.command or "?"
                    Derma_Query(
                        "Perform this action '" .. label .. "' on " .. ply:Nick() .. "?",
                        "Confirmation Prompt",
                        "Yes", function() option.func(targetPly) end,
                        "No", function() end
                    )
                else
                    option.func(targetPly)
                end
            end)
            if (option.icon) then
                menuOption:SetIcon(option.icon)
            end
            empty = false
        end
        if not empty then
            menu:AddSpacer()
        end
    end

    hook.Add("Think", "TTSB_CheckInput", function()
        if not input.IsKeyDown(KEY_TAB) then
            hook.Remove("Think", "TTSB_CheckInput")
            menu:Remove()
        end
    end)
end

hook.Add("TTTScoreboardMenu", "TTSB_Menu", TTSB.AddMenu)

concommand.Add("ttsb_refreshscoreboard", function() gamemode.Call("ScoreboardCreate") end)
