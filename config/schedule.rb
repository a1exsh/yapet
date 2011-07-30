# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

set :cron_log, "#{RAILS_ROOT}/log/cron.log"

every :hour do
  runner "Account.expired_sandboxes.destroy_all"
end

every :day do
  runner "PasswordResetRequest.expired.delete_all"
  runner "Invitation.expired.delete_all"
end
