# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe DestroyAccountMailer, type: :mailer do
    let(:organization) { create(:organization) }
    let(:user) { create(:user, organization: organization) }

    describe "#notify_of_deletion" do
      let(:mail) { described_class.notify_of_deletion(user) }

      let(:subject) { "Subject" }
      let(:default_subject) { "Your account has been deleted" }

      let(:body) { "" }
      let(:default_body) { "" }

      include_examples "localised email"
    end

    describe "#warn_of_deletion" do
      let(:mail) { described_class.warn_of_deletion(user) }

      let(:subject) { "Subject" }
      let(:default_subject) { "Your account will be deleted if you don't log in again" }

      let(:body) { "" }
      let(:default_body) { "" }

      include_examples "localised email"
    end
  end
end
