local ffi = require('ffi')

ffi.cdef[[

  int select(int nfds, fd_set *readfds, fd_set *writefds,
             fd_set *exceptfds, struct timeval *timeout);

	int fileno(FILE *stream); 

  struct timeval {
      long    tv_sec;         /* seconds */
      long    tv_usec;        /* microseconds */
  };

]]

function ready( fd )
	ffi.C.select()
	ffi.C.fileno(ffi.new())
end

return {
	ready = ready
}
