require_dependency "account_controller"

class AccountController
  def invalid_credentials_with_locking
    if user = User.find_by_login(params[:username].to_s)
      #increment brute-force counter
      pref = user.pref
      pref[:brute_force_counter] = pref[:brute_force_counter].to_i + 1
      pref.save
      #lock the user immediately if detecting a brute force attack
      user.lock! if brute_forcing?(user)
    end
    #original action
    invalid_credentials_without_locking
  end
  alias_method_chain :invalid_credentials, :locking

  private
  def brute_forcing?(user)
    user.pref[:brute_force_counter].to_i >= 3
  end
end
