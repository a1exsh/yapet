module InvitationsHelper
  def invites_left_text
    if current_user.no_invites_left?
      _("No invites left.") + " " \
      + mail_to("alex.shulgin@gmail.com", _("Ask for more"),
                :subject => "[YaPET] Moar invitez pweez!")
    else
      _("%d invites left") % current_user.invites_left
    end
  end
end
