Enet binding for lua using luajit2 ffi.

The enet.h header was created using cpp.

libenet.so was built by modifying the automake files.

The enet.lua shows that all you need is to load the
enet.h file and the libenet.so for a low level binding.

On top of that enet.lua provides a simple wrapper
that makes it easier to work with enet from lua.

Look at test.lua for an example of using the wrapper.
