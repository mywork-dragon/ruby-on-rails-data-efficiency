OpenSSL::Buffering.module_eval do

	include Enumerable

	##
	# The "sync mode" of the SSLSocket.
	#
	# See IO#sync for full details.

	attr_accessor :sync

	##
	# Default size to read from or write to the SSLSocket for buffer operations.

	BLOCK_SIZE = 1024*160

	#16384

end