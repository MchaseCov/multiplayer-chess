class ApplicationController < ActionController::Base
  before_action :set_active,
                if: lambda {
                      user_signed_in? && (current_user.updated_at < 10.minutes.ago)
                    }

  private

  def set_active
    current_user.touch
  end
end
