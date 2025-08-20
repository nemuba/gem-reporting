module Reporting
  # ReportRequest model for handling report requests in the Reporting module
  class ReportRequest < ApplicationRecord
    self.table_name = "reporting_report_requests"

    # Enums .........................................
    # 0: pending, 1: processing, 2: done, 3: failed
    enum :status, { queued: 0, processing: 1, done: 2, failed: 3 }, prefix: true

    # Relationships ...................................
    # File attachment
    has_one_attached :file

    # Validations .....................................
    validates :token, presence: true, uniqueness: true

    # Callbacks .....................................
    before_validation :ensure_token, on: :create

    def ensure_token
      self.token ||= SecureRandom.urlsafe_base64(32)
    end
  end
end
