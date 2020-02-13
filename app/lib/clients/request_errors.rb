module RequestErrors
  class NotAllowed < RuntimeError; end
  class BadRequest < RuntimeError; end
  class NotFound < RuntimeError; end
  class Unauthorized < RuntimeError; end
  class InternalServerErrror < RuntimeError; end
  class RateLimitExceeded < RuntimeError; end
end
