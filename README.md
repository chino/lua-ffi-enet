Example Lua bindings for Enet using luajit2 ffi.

luajit2 ffi makes using C from Lua super easy.

It can parse header files and auto generate bindings.

In this example everything in enet.h is loaded into the enet name space.

A small convenience wrapper is also provided.


Note:

	The enet.h header was generated by running it through cpp.

	libenet.so was built by modifying Enet's automake files.


Simple chat interface using the bindings:

	# host an enet session on port 2300 and wait for clients
	./test.lua localhost 2300

	# in another console
	# using source port 2301 connect to the host on 2300
	./test.lua localhost 2301 localhost 2300
