-- Detect operating system
local os = vim.loop.os_uname().sysname
if os == "Windows" then
	os = "Windows"
else
	os = vim.loop.os_uname().version
end

-- Set hidden option
vim.opt.hidden = true

-- TermWrapper function
local function TermWrapper(command)
	local split_term_style = vim.g.split_term_style or "vertical"

	local buffercmd
	if split_term_style == "vertical" then
		buffercmd = "vnew"
	elseif split_term_style == "horizontal" then
		buffercmd = "new"
	else
		vim.api.nvim_err_writeln(
			"ERROR! g:split_term_style is not a valid value (must be 'horizontal' or 'vertical' but is currently set to '"
				.. split_term_style
				.. "')"
		)
		error("ERROR! g:split_term_style is not a valid value (must be 'horizontal' or 'vertical')")
	end

	vim.cmd(buffercmd)
	if vim.g.split_term_resize_cmd then
		vim.cmd(vim.g.split_term_resize_cmd)
	end

	vim.api.nvim_create_autocmd("BufEnter", {
		buffer = 0,
		callback = function()
			vim.cmd("startinsert")
		end,
	})
end

-- CompileAndRun command
vim.api.nvim_create_user_command("CompileAndRun", function()
	TermWrapper(string.format("g++ -std=c++11 %s && ./a.out", vim.fn.expand("%")))
end, {})

-- CompileAndRunWithFile command
vim.api.nvim_create_user_command("CompileAndRunWithFile", function(opts)
	TermWrapper(string.format("g++ -std=c++11 %s && ./a.out < %s", vim.fn.expand("%"), opts.fargs[1]))
end, { nargs = 1, complete = "file" })

-- Mappings for C++ files
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
	pattern = { "*.cpp" },
	callback = function()
		if os == "Darwin" then
			print("Darwin os vi ")
			vim.keymap.set(
				"n",
				"<leader>fn",
				":!g++ -std=c++11 -o %:r % && open -a Terminal './a.out'<CR>",
				{ buffer = true }
			)
			vim.keymap.set("n", "<leader>fw", "<CMD>CompileAndRun<CR>", { buffer = true })
			vim.keymap.set("n", "<leader>fb", "<cmd>!g++ -std=c++11 -o %:r % && ./%:r<CR>", { buffer = true })
			vim.keymap.set("n", "<leader>fr", "<cmd>!./%:r.out<CR>", { buffer = true })
		end

		vim.keymap.set("n", "<leader>fb", "<cmd>!g++ -std=c++11 % && ./a.out<CR>", { buffer = true })
		vim.keymap.set("n", "<leader>fr", "<cmd>!./a.out<CR>", { buffer = true })
		vim.keymap.set("n", "<leader>fw", "<cmd>CompileAndRun<CR>", { buffer = true })
	end,
})
-- Options
vim.g.split_term_style = "horizontal"
vim.g.split_term_resize_cmd = "resize 10"
