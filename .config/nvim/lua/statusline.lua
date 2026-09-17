-- lualine's default sections, rendered by mini.statusline.
-- Keep this palette local: the minimal profile does not need a colorscheme.
local M = {}
local C = {
  blue = "#8aadf4", green = "#a6da95", peach = "#f5a97f",
  mauve = "#c6a0f6", red = "#ed8796", yellow = "#eed49f",
  sky = "#91d7e3", teal = "#8bd5ca", text = "#cad3f5",
  base = "#24273a", mantle = "#1e2030", surface0 = "#363a4f",
}
local modes = {
  n = { "NORMAL", "normal" }, i = { "INSERT", "insert" },
  v = { "VISUAL", "visual" }, V = { "V-LINE", "visual" },
  ["\22"] = { "V-BLOCK", "visual" }, s = { "SELECT", "visual" },
  S = { "S-LINE", "visual" }, ["\19"] = { "S-BLOCK", "visual" },
  R = { "REPLACE", "replace" }, c = { "COMMAND", "command" },
  t = { "TERMINAL", "insert" }, ["!"] = { "SHELL", "command" },
  r = { "REPLACE", "replace" }, rm = { "MORE", "replace" },
  ["r?"] = { "CONFIRM", "replace" },
}
local accents = {
  normal = C.blue, insert = C.green, visual = C.mauve,
  replace = C.red, command = C.peach,
}
local function hl(name) return "%#MinLine" .. name .. "#" end
local function escape(text) return (text:gsub("%%", "%%%%")) end
local function group(name, text) return hl(name) .. " " .. text .. " " end

local function highlights()
  local function set(name, fg, bg, bold)
    vim.api.nvim_set_hl(0, "MinLine" .. name, { fg = fg, bg = bg, bold = bold or false })
  end
  set("C", C.text, C.mantle)
  for mode, color in pairs(accents) do
    set(mode .. "A", mode == "normal" and C.mantle or C.base, color, true)
    set(mode .. "B", color, C.surface0)
    set(mode .. "AB", color, C.surface0)
    set(mode .. "AC", color, C.mantle)
    for name, fg in pairs({ Add = C.green, Change = C.yellow, Delete = C.red,
      Error = C.red, Warn = C.yellow, Info = C.sky, Hint = C.teal }) do
      set(mode .. name, fg, C.surface0)
    end
  end
  set("BC", C.surface0, C.mantle)
end

local function filename()
  local name = vim.fn.expand("%:p:~")
  if name == "" then name = "[No Name]" end
  -- Match lualine filename.path=3 and its default shorting_target=40.
  local parts, len = vim.split(name, "/", { plain = true }), #name
  for i = 1, #parts - 1 do
    if len <= vim.o.columns - 40 then break end
    local short = parts[i]:sub(1, parts[i]:sub(1, 1) == "." and 2 or 1)
    len = len - #parts[i] + #short
    parts[i] = short
  end
  name = escape(table.concat(parts, "/"))
  local flags = (vim.bo.modified and "[+]" or "")
    .. ((vim.bo.readonly or not vim.bo.modifiable) and "[-]" or "")
  return name .. (flags ~= "" and " " .. flags or "")
end

local function git_and_diagnostics(mode)
  local parts, base = {}, hl(mode .. "B")
  local summary = vim.b.minigit_summary or {}
  local branch = vim.b.gitsigns_head or summary.head_name
  if branch == "HEAD" and summary.head then branch = summary.head:sub(1, 7) end
  if branch and branch ~= "" then parts[#parts + 1] = " " .. escape(branch) end
  local diff = vim.b.gitsigns_status_dict or vim.b.minidiff_summary or {}
  local counts = {
    { "Add", "+", diff.added or diff.add },
    { "Change", "~", diff.changed or diff.change },
    { "Delete", "-", diff.removed or diff.delete },
  }
  local changes = {}
  for _, item in ipairs(counts) do
    if (item[3] or 0) > 0 then
      changes[#changes + 1] = hl(mode .. item[1]) .. item[2] .. item[3] .. base
    end
  end
  if #changes > 0 then parts[#parts + 1] = table.concat(changes, " ") end
  local diagnostics = {}
  for _, item in ipairs({
    { "Error", "󰅚 ", vim.diagnostic.severity.ERROR },
    { "Warn", "󰀪 ", vim.diagnostic.severity.WARN },
    { "Info", "󰋽 ", vim.diagnostic.severity.INFO },
    { "Hint", "󰌶 ", vim.diagnostic.severity.HINT },
  }) do
    local count = #vim.diagnostic.get(0, { severity = item[3] })
    if count > 0 then
      diagnostics[#diagnostics + 1] = hl(mode .. item[1]) .. item[2] .. count .. base
    end
  end
  if #diagnostics > 0 then parts[#parts + 1] = table.concat(diagnostics, " ") end
  return table.concat(parts, "  ")
end

local function filetype()
  if vim.bo.filetype == "" then return "" end
  local icons = require("nvim-web-devicons")
  local icon, icon_hl = icons.get_icon(vim.fn.expand("%:t"))
  if not icon then icon, icon_hl = icons.get_icon_by_filetype(vim.bo.filetype) end
  icon, icon_hl = icon or "", icon_hl or "DevIconDefault"
  local fg = vim.api.nvim_get_hl(0, { name = icon_hl, link = false }).fg
  local name = "Icon" .. icon_hl
  vim.api.nvim_set_hl(0, "MinLine" .. name, { fg = fg or C.text, bg = C.mantle })
  return hl(name) .. icon .. " " .. hl("C") .. escape(vim.bo.filetype)
end

function M.active()
  local code = vim.api.nvim_get_mode().mode
  local mode = modes[code] or modes[code:sub(1, 1)] or modes.n
  if code:sub(1, 2) == "no" then mode = { "O-PENDING", "normal" } end
  if code:sub(1, 2) == "Rv" then mode = { "V-REPLACE", "replace" } end
  if code == "cv" or code == "ce" then mode = { "EX", "command" } end
  local key = mode[2]
  local b = git_and_diagnostics(key)
  local left = group(key .. "A", mode[1])
  if b ~= "" then
    left = left .. hl(key .. "AB") .. "" .. group(key .. "B", b) .. hl("BC") .. ""
  else
    left = left .. hl(key .. "AC") .. ""
  end
  local encoding = vim.bo.fileencoding
  local formats = { unix = "", dos = "", mac = "" }
  local right = {}
  if encoding ~= "" then right[#right + 1] = escape(encoding) end
  right[#right + 1] = formats[vim.bo.fileformat] or escape(vim.bo.fileformat)
  local ft = filetype()
  if ft ~= "" then right[#right + 1] = ft end
  local row, total = vim.fn.line("."), vim.fn.line("$")
  local progress = row == 1 and "Top" or (row == total and "Bot"
    or string.format("%2d%%%%", math.floor(row / total * 100)))
  local location = string.format("%3d:%-2d", row, vim.fn.charcol("."))
  return left .. group("C", "%<" .. filename()) .. "%="
    .. group("C", table.concat(right, "  "))
    .. hl("BC") .. "" .. group(key .. "B", progress)
    .. hl(key .. "AB") .. "" .. group(key .. "A", location)
end

function M.setup()
  require("mini.git").setup()
  require("mini.diff").setup({
    -- Git data only: do not change the minimal profile's gutter or mappings.
    view = { style = "sign", signs = { add = "", change = "", delete = "" } },
    mappings = { apply = "", reset = "", textobject = "",
      goto_first = "", goto_prev = "", goto_next = "", goto_last = "" },
  })
  require("nvim-web-devicons").setup()
  require("mini.statusline").setup({
    content = { active = M.active, inactive = function()
      return group("C", "%<" .. filename()) .. "%=" .. group("C", "%3l:%-2v")
    end },
    set_vim_settings = false,
  })
  vim.o.laststatus = 3
  vim.o.showmode = false
  highlights()
  local augroup = vim.api.nvim_create_augroup("MinimalStatusline", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", { group = augroup, callback = highlights })
  vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = augroup, callback = function() vim.cmd("redrawstatus") end,
  })
  vim.api.nvim_create_autocmd("User", {
    group = augroup, pattern = { "MiniGitUpdated", "MiniDiffUpdated" },
    callback = function() vim.cmd("redrawstatus") end,
  })
end

return M
