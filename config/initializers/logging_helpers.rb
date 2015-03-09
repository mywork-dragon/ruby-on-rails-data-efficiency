# Log to info
def li(s)
  Rails.logger.info s 
end

# Log to debug
def ld(s)
  Rails.logger.debug s
end

# Log to warn
def lw(s)
  Rails.logger.warn s
end

# Log to error
def le(s)
  Rails.logger.error s
end

# Log to fatal
def lf(s)
  Rails.logger.fatal s
end
