-- a test script by z	
divisors = {
	1.5, 2, 2.6, 3, 4, 5, 5.3, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19, 21, 23, 24, 25, 27, 29, 32, 40, 48, 56, 64, 64, 96, 128, 256, 384, 512
}
multipliers = {
	1.3, 1.5, 2, 2.6, 3, 4, 5.3, 6, 8, 12, 16, 24, 48
}
function diviplyFormatter(block) -- makes divipliers show up correctly in parameter menu
	local n = block.value
	local rString;

	if n < 0 then 
		rString = '/' .. divisors[math.abs(n)]
	elseif n == 0 then 
		rString = 'x1'
	elseif n > 0 then 
		rString = 'x' .. multipliers[n]
	end
	
	return rString 
end

local clocks = {};
local clockTemplate = function(n)	
	while true do
		local quantum; local val = params:get('ch'..n..'_diviply')

		if val < 0 then 
			quantum = divisors[math.abs(val)]
		elseif val == 0 then 
			quantum = 1
		elseif val > 0 then 
			--todo implement multiplications
		end

		clock.sync(quantum)
		print('trigger channel ' .. n)
		-- todo implement actual triggers
	end
end


function init()
	addParams()
	for i=1, 8 do
		clocks[i] = clockTemplate
		clock.run(clocks[i], i)
	end
	clock.run(clocks[1], 1)
end

function addParams()
	for i = 1, 8 do 
		params:add_separator('channel ' .. i)
		params:add_number(
			'ch' .. i .. '_diviply'
			, 'diviply'
			, -36
			, 13	
			, 0
			, diviplyFormatter
			, false
		)
	end

end

