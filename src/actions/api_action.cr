# Include modules and add methods that are for all API requests
abstract class ApiAction < Lucky::Action
  # APIs typically do not need to send cookie/session data.
  # Remove this line if you want to send cookies in the response header.
  disable_cookies
  accepted_formats [:json], default: :json

  include Api::Auth::Helpers

  # By default all actions require sign in.
  # Add 'include Api::Auth::SkipRequireAuthToken' to your actions to allow all requests.
  include Api::Auth::RequireAuthToken
  include Lucky::EnforceUnderscoredRoute
end
