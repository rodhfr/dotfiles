-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- copy everything with ctrl c
vim.keymap.set("n", "<C-c>", ":%y+<CR>", { noremap = true, silent = true })
-- select everything with ctrl a
vim.keymap.set("n", "<C-a>", "gg:sleep 100m<CR>vG$", { noremap = true, silent = true })

-- Visual mode: wrap selection in print() on next line with "fp"
vim.keymap.set("v", "fp", function()
  -- pega posições da seleção visual
  local start_pos = vim.fn.getpos("v") -- início da seleção
  local end_pos = vim.fn.getpos(".") -- cursor atual (fim da seleção)

  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  -- pega as linhas do buffer entre início e fim
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- ajusta colunas na primeira e última linha
  if #lines == 1 then
    lines[1] = lines[1]:sub(start_col, end_col)
  else
    lines[1] = lines[1]:sub(start_col)
    lines[#lines] = lines[#lines]:sub(1, end_col)
  end

  -- junta todas as linhas em uma só
  local text = table.concat(lines, " ")

  -- insere a linha print(...) abaixo da seleção
  vim.api.nvim_put({ "print(" .. text .. ")" }, "l", true, true)

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "m", true)
end, { noremap = true, silent = true })

-- Visual mode: wrap selection in print() on next line with "fp"
vim.keymap.set("v", "ft", function()
  -- pega posições da seleção visual
  local start_pos = vim.fn.getpos("v") -- início da seleção
  local end_pos = vim.fn.getpos(".") -- cursor atual (fim da seleção)

  local start_line, start_col = start_pos[2], start_pos[3]
  local end_line, end_col = end_pos[2], end_pos[3]

  -- pega as linhas do buffer entre início e fim
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)

  -- ajusta colunas na primeira e última linha
  if #lines == 1 then
    lines[1] = lines[1]:sub(start_col, end_col)
  else
    lines[1] = lines[1]:sub(start_col)
    lines[#lines] = lines[#lines]:sub(1, end_col)
  end

  -- junta todas as linhas em uma só
  local text = table.concat(lines, " ")

  -- insere a linha print(...) abaixo da seleção
  vim.api.nvim_put({ 'print("\\n' .. text .. ': " )' }, "l", true, true)

  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "m", true)
end, { noremap = true, silent = true })

-- Saves and exit
vim.keymap.set("n", "<leader>w", "<cmd>wq<CR>", { noremap = true, silent = true, desc = "Save and quit" })
-- force exit
vim.keymap.set("n", "<leader>q", "<cmd>q!<CR>", { noremap = true, silent = true, desc = "Quit without saving" })

local term_win = nil
local term_buf = nil

vim.keymap.set("n", "<leader>r", function()
  -- TOGGLE OFF
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)

    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
      vim.api.nvim_buf_delete(term_buf, { force = true })
    end

    term_win = nil
    term_buf = nil
    return
  end

  -- TOGGLE ON
  vim.cmd("w")

  local file = vim.fn.expand("%:p")
  if file == "" then
    print("No file to run")
    return
  end

  -- create split
  vim.cmd("botright 12split")
  term_win = vim.api.nvim_get_current_win()

  -- create terminal buffer
  term_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(term_win, term_buf)

  -- start python as a terminal job (NO shell, NO globbing)
  vim.fn.jobstart({ "python", file }, {
    term = true,
    stdout_buffered = false,
    stderr_buffered = false,
  })
end, { noremap = true, silent = true, desc = "Run Python file" })

-- vim.opt.spell = true
vim.opt.spelllang = "pt_br,en_us"

-- Função para inserir Markdown com título da URL do clipboard
local function insert_markdown_link_from_clipboard()
  -- Pegar URL do clipboard (+ é o clipboard do sistema)
  local url = vim.fn.getreg("+")

  if not url:match("^https?://") then
    print("Clipboard não contém uma URL válida!")
    return
  end

  -- Pega o HTML da página e extrai o título usando curl + grep
  local handle =
    io.popen("curl -s " .. vim.fn.shellescape(url) .. ' | grep -oP "(?<=<title>).*?(?=</title>)" | head -n 1')
  local title = handle:read("*a")
  handle:close()

  title = title:gsub("\n", "") -- Remove quebras de linha

  if title == "" then
    title = url -- fallback se não tiver título
  end

  -- Insere no buffer como Markdown no cursor atual
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local new_line = line:sub(1, col) .. string.format("[%s](%s)", title, url) .. line:sub(col + 1)
  vim.api.nvim_set_current_line(new_line)
end

-- Cria um comando :MdClip ou um atalho <leader>m
vim.api.nvim_create_user_command("MdClip", insert_markdown_link_from_clipboard, {})
vim.api.nvim_set_keymap("n", "<leader>m", ":MdClip<CR>", { noremap = true, silent = true })
