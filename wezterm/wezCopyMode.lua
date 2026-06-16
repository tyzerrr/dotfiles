local wezterm = require('wezterm')
local act = wezterm.action
return {
    key_tables = {
        copy_mode = {
            --move like vim motion, so fancy.
            -- normal mode.
            { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
            { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
            { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
            { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
            { key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
            { key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
            { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
            { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
            { key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
            { key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
            { key = "y", mods = "NONE", action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }) },
            -- visual mode.
            { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
            { key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
            { key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
            -- match navigation (after a search)
            { key = "n", mods = "NONE", action = act.CopyMode("NextMatch") },
            { key = "N", mods = "NONE", action = act.CopyMode("PriorMatch") },
            -- exit copy mode
            {
                key = "Enter",
                mods = "NONE",
                action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
            },
            { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
        },
        search_mode = {
            -- confirm the pattern and drop into copy_mode at the match,
            -- so v/hjkl/y all work afterwards
            { key = "Enter", mods = "NONE", action = act.CopyMode("AcceptPattern") },
            { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
            { key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
            { key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
            { key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
            { key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
        },
    }
}
