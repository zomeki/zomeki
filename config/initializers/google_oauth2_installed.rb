module GoogleOauth2Installed
  class Setup
    def zomeki_get_auth_url
      checks.check_for_environment!
      get_auth_url
    end

    def zomeki_get_access_token(auth_code)
      get_token auth_code
    end
  end
end
