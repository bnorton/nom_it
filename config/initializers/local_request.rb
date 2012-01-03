module ActionDispatch
  class Request < Rack::Request
    def local?
      return false if Rails.env.production?
      return false if Rails.env.staging?
    end
  end
end
