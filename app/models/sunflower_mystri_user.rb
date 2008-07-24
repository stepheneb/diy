class SunflowerMystriUser < SunflowerModel

  set_table_name "mystri_users"
  set_primary_key "user_id"

  def self.find_user(identifier)
    if SunflowerMystriUser.connection_possible?
      if user = SunflowerMystriUser.find_by_user_username(identifier)
        user
      else
        if user = SunflowerMystriUser.find_by_user_email(identifier)
          user
        else
          nil
        end
      end
    else
      nil
    end
  end
  
end
