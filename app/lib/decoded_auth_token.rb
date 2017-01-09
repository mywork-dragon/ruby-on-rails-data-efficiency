# We could just return the payload as a hash, but having keys with indifferent access is always nice, plus we get an expired? method that will be useful later
class DecodedAuthToken < HashWithIndifferentAccess
  def expired?
    self[:exp] <= Time.now.to_i
  end

  def is_second_session?
    user_id = self[:user_id]
    user_id && User.find(user_id).refresh_token != self[:refresh_token]
  end
end