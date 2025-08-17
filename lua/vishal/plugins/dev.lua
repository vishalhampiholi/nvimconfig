return {
	{
		dir = "~/plugins/present.nvim",
		config = function()
			print("present loaded ")
			require("present")
		end,
	},
}
