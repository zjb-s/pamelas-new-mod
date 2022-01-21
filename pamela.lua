-- a test script by z	
divisors = {
	1.5, 2, 2.6, 3, 4, 5, 5.3, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 19, 21, 23, 24, 25, 27, 29, 32, 40, 48, 56, 64, 64, 96, 128, 256, 384, 512
}
multipliers = {
	1.3, 1.5, 2, 2.6, 3, 4, 5.3, 6, 8, 12, 16, 24, 48
}

shapes = {"pulse", "tri", "sin"}
SHAPE_PULSE = 1
SHAPE_TRI = 2
SHAPE_SIN = 3

destinations = {"unassigned", "crow 1", "crow 2", "crow 3", "crow 4"}

DEST_UNASSIGNED = 1
DEST_CROW_1 = 2
DEST_CROW_2 = 3
DEST_CROW_3 = 4
DEST_CROW_4 = 5


function crow_destination(ch)
  local dest = params:get(pn('destination', ch))
  if dest >= DEST_CROW_1 and dest <= DEST_CROW_4 then
    return dest - DEST_CROW_1 + 1
  end
  return nil
end

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
		local quantum; local val = params:get(pn('diviply', n))

		if val < 0 then 
			quantum = divisors[math.abs(val)]
		elseif val == 0 then 
			quantum = 1
		elseif val > 0 then 
			--todo implement multiplications
		end

		clock.sync(quantum)
		print('trigger channel ' .. n)
		local width = params:get(pn("width", n))
		local crow_dest = crow_destination(n)
		if crow_dest then
		  local shape = params:get(pn("shape", n))
		  local asl_shape = "now"
		  if shape == SHAPE_PULSE then 
		    asl_shape = "now"
		  elseif shape == SHAPE_TRI then
		    asl_shape = "linear"
		  elseif shape == SHAPE_SIN then
		    asl_shape = "sine"
		  end
		  local bs = clock.get_beat_sec()
		  -- Technically I don't think this /2 should be in here. I think there is a bug in crow? See how it works on your crow.
		  local action =  string.format("{ to(5, %.4f, '%s'), to(0, %.4f, '%s') }", bs*quantum*width/2, asl_shape, bs*quantum*(1-width)/2, asl_shape)
		  print(action)
		  crow.output[crow_dest].action = action
      crow.output[crow_dest]()
		end
    
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

function pn(name, chan)
  return 'ch' .. chan .. '_' .. name
end

function addParams()
	for i = 1, 8 do 
		params:add_separator('channel ' .. i)
		params:add_number(
			pn('diviply', i)
			, 'diviply'
			, -36
			, 13	
			, 0
			, diviplyFormatter
			, false
		)
		params:add_option(pn('shape', i), 'shape', shapes, SHAPE_PULSE)
		local width_spec = controlspec.UNIPOLAR:copy()
		width_spec.default = 0.5
		params:add_control(pn('width', i), 'width', width_spec)
		params:add_option(pn('destination', i), 'destination', destinations, DEST_UNASSIGNED)
	end

end

