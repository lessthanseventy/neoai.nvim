local ui = require("neoai.ui")
local chat = require("neoai.chat")
local inject = require("neoai.inject")
local ChatHistory = require("neoai.chat.history")

local M = {}

local function setup_colors()
	local hl_group_name = "NeoAIInput"
	local color = { guifg = "#61afef"}
	vim.api.nvim_command(
		"highlight "
			.. hl_group_name
			.. " guifg="
			.. color.guifg
	)
end

M.setup = function()
	setup_colors()
end

---Toggles opening and closing split
---@param value boolean|nil The value to flip
---@return boolean true if opened and false if closed
M.toggle = function(value)
	local open = value or (value == nil and not ui.is_open())
	if open then
		-- Open
		ui.create_ui()
        return true
	else
		-- Close
		ui.destroy_ui()
        return false
	end
end

M.toggle_with_args = function (args)
    local opened = M.toggle(nil)

    if opened and args ~= "" then
        ui.send_prompt(args)
    end
end

M.inject = function (args)
    chat.chat_history = ChatHistory:new()

    local line = vim.api.nvim_win_get_cursor(0)[1]
    vim.api.nvim_create_augroup("NeoAIInjectGroup", {})
    chat.on_prompt_send(args, function (txt, _)
        inject.append_to_buffer(txt, line)
    end, false, function (output)
        inject.current_line = nil
        vim.api.nvim_out_write("Done generating AI response\n")
        vim.api.nvim_del_augroup_by_name("NeoAIInjectGroup")
    end)
end

return M