#!/usr/bin/env luajit
local enet = require('enet')
local os = require('os')

function printf(s,...) print(s:format(...)) end
function die(...) print(...); os.exit(1) end

if #arg < 2 then
	die('Usage: ', arg[0],
		' <local-host> <local-port> <remote-host> <remote-port>')
end

local session = enet.new( arg[1], arg[2]+0, 10 )
if not session then
	die('failed to bind socket')
end

local host
if arg[3] and arg[4] then
	host = session:connect( arg[3], arg[4]+0, 10 )
	if not host then
		die('failed to connect to host')
	end
end

while true do

	local event, peer, data, channel = session:service(100)

	if event == 'none' then
		print('got no event')

	elseif event == 'connect' then
		print('connect from ',
			peer.address.host, ':',
			peer.address.port)

	elseif event == 'disconnect' then
		print('disconnect from ',
			peer.address.host, ':',
			peer.address.port)

	elseif event == 'receive' then
		print('received ', #data, ' bytes from ',
			peer.address.host,':',peer.address.port,
			'on channel ', channel,
			' saying: ', data)

	end		

	-- need to do this from ffi
	-- http://fly.thruhere.net/projects/net_proxy/lua/lib/io_ready/
	if #arg > 2 then
		local message = io.read()
		if message then
			session:send(host,message)
			session:flush()
		end
	end

end
