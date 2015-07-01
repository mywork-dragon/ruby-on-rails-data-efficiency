OpenSSL::Buffering.module_eval do

	puts "hello!!!"

	include Enumerable

	##
	# The "sync mode" of the SSLSocket.
	#
	# See IO#sync for full details.

	attr_accessor :sync

	##
	# Default size to read from or write to the SSLSocket for buffer operations.

	BLOCK_SIZE = 1024*16


	def patch_test
		puts "this patch works!!!"
	end

end