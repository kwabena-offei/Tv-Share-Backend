class Report < ApplicationRecord
  belongs_to :user
  belongs_to :reportable, polymorphic: true
  after_create :notify_admin

  def notify_admin
    ReportMailer.with(report: self).report_content.deliver_now
  rescue => e
    puts "There was an email sending the report content email"
    puts e.backtrace
  end
end
