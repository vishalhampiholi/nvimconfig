vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = "*.c",
	callback = function()
		local function compile_and_run_c()
			local filename = vim.fn.expand("%:t:r") -- Get the filename without extension
			local compile_cmd = string.format("zig cc -o %s %s.c", filename, filename)
			local run_cmd = string.format("./%s", filename)

			-- Compile the C program
			vim.fn.system(compile_cmd)

			-- Check if compilation was successful
			if vim.v.shell_error ~= 0 then
				print("Compilation failed!")
				return
			end

			-- Run the compiled program
			local output = vim.fn.system(run_cmd)

			-- Display the output in a split window
			vim.cmd("botright 10split __C_Output__")
			local buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(output, "\n"))
			vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
			vim.api.nvim_buf_set_option(buf, "modifiable", false)
			vim.api.nvim_win_set_option(0, "wrap", true)
			vim.api.nvim_win_set_option(0, "number", false)
			vim.cmd("wincmd p") -- Return focus to the previous window
		end

		-- Set up a keymap to trigger the compile_and_run_c function
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>cr", "", {
			noremap = true,
			silent = true,
			callback = compile_and_run_c,
		})

		print("C file detected. Use <leader>cr to compile and run.")
	end,
})
