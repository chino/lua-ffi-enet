local io = require('io')
local ffi = require('ffi')

-- include the enet header
-- enet.h was first passed through cpp
-- since ffi doesn't support preprocessor yet
ffi.cdef( io.open('enet.h'):read('*all') )

-- load enet shared object
-- this was built by following these steps
-- 1. add AC_PROG_LIBTOOL to configure.in
-- 2. add lib_LTLIBRARIES = libenet.la to Makefile.am
-- 3. run libtoolize
-- 4. aclocal && automake -a -c --foreign && autoconf
-- 5. make
local enet = ffi.load('./libenet.so')

-- list of methods
local methods = {}

-- meta table for session
local mt = {
	__index = methods,
	__gc = function ( o ) 
		print("garbage collecting enet host")
		if o.host then
			enet.enet_host_destroy( o.host )
		end
	end
}

function new( host, port, peers )
	local o = setmetatable({},mt)
	local rv = o:bind( host, port, peers )
	if not rv then
		return false
	else
		return o
	end
end

function methods:bind( host, port, peers )
	local address = ffi.new('ENetAddress')
	if host then
		enet.enet_address_set_host( address, host )
	else
		address.host = enet.ENET_HOST_ANY
	end
	address.port = port
	self.host = enet.enet_host_create( address, peers, 0, 0 ) 
	return not not self.host
end

function methods:connect( host, port, channels )
	if not self.host then
		self.host = enet.enet_host_create( nil, 1, 0, 0 )
	end
	local address = ffi.new('ENetAddress')
	enet.enet_address_set_host( address, host )
	address.port = port
	return enet.enet_host_connect( self.host, address, channels ) 
end

function methods:service( wait )
	local event = ffi.new('ENetEvent')
	while enet.enet_host_service( self.host, event, wait or 0 ) > 0 do

		if event.type == enet.ENET_EVENT_TYPE_NONE then
			return "none"

		elseif event.type == enet.ENET_EVENT_TYPE_CONNECT then
			return "connect", event.peer

		elseif event.type == enet.ENET_EVENT_TYPE_DISCONNECT then
			return "disconnect", event.peer

		elseif event.type == enet.ENET_EVENT_TYPE_RECEIVE then
			local data = ffi.string(
				event.packet.data, event.packet.dataLength )
			enet.enet_packet_destroy( event.packet )
			return "receive", event.peer, data, event.channelID

		end
	end
end

local packet_flags = {
	reliable = enet.ENET_PACKET_FLAG_RELIABLE,
	unsequenced = enet.ENET_PACKET_FLAG_UNSEQUENCED
}

function methods:send( peer, data, channel, flags )
	local packet = enet.enet_packet_create(
		data, #data+1, packet_flags[flags] or 0 )
	return 0 == enet.enet_peer_send( peer, channel or 0, packet )
end

function methods:flush()
	if self.host then
		enet.enet_host_flush( self.host )
	end
end

enet.enet_initialize()

return {
	new = new;
}
