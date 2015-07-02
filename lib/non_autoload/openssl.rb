OpenSSL::Buffering.module_eval do

	include Enumerable

	attr_accessor :sync

	BLOCK_SIZE = 1024*240

end