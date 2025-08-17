vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	pattern = "*.ts",
	callback = function()
		local function compile_and_run_ts()
			-- Compile TypeScript project
			local compile_cmd = "tsc -b"
			local compile_output = vim.fn.system(compile_cmd)

			-- Check if compilation was successful
			if vim.v.shell_error ~= 0 then
				print("TypeScript compilation failed!")
				print(compile_output)
				return
			end

			-- Check if dist/index.js exists
			local index_file = "dist/index.js"
			if vim.fn.filereadable(index_file) ~= 1 then
				print("dist/index.js not found. Make sure your TypeScript configuration is correct.")
				return
			end
			-- Run node dist/index.js
			local run_cmd = "node " .. index_file
			local run_output = vim.fn.system(run_cmd)

			-- Display the output in a smaller split window
			vim.cmd("botright 10split __TS_Output__")
			local buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(run_output, "\n"))
			vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
			vim.api.nvim_buf_set_option(buf, "modifiable", false)
			vim.api.nvim_win_set_option(0, "wrap", true)
			vim.api.nvim_win_set_option(0, "number", false)
			vim.cmd("wincmd p") -- Return focus to the previous window
		end

		-- Set up a keymap to trigger the compile_and_run_ts function
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>tr", "", {
			noremap = true,
			silent = true,
			callback = compile_and_run_ts,
			decs = "compile and run ts files",
		})

		print("TypeScript file detected. Use <leader>tr to compile and run.")
	end,
})
