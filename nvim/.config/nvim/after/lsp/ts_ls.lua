local is_node_dir = require("utils.lib")
return {
	on_attach = function(client)
		if not is_node_dir() then
			client.stop(true)
		end
	end,
}
