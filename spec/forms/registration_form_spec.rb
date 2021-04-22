# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe RegistrationForm do
    subject do
      described_class.from_params(
        attributes
      ).with_context(
        context
      )
    end

    let(:organization) { create(:organization) }
    let(:name) { "User" }
    let(:nickname) { "justme" }
    let(:email) { "user@example.org" }
    let(:password) { "S4CGQ9AM4ttJdPKS" }
    let(:password_confirmation) { password }
    let(:status) { "student" }
    let(:provenance) { scope.id }
    let(:tos_agreement) { "1" }

    let(:attributes) do
      {
        name: name,
        nickname: nickname,
        email: email,
        password: password,
        password_confirmation: password_confirmation,
        status: status,
        provenance: provenance,
        tos_agreement: tos_agreement
      }
    end

    let(:context) do
      {
        current_organization: organization
      }
    end

    let!(:scope) { create(:scope, organization: organization, code: "SE-1") }

    context "when everything is OK" do
      it { is_expected.to be_valid }
    end

    context "when the email is a disposable account" do
      let(:email) { "user@mailbox92.biz" }

      it { is_expected.to be_invalid }
    end

    context "when the name is not present" do
      let(:name) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the status is not present" do
      let(:status) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the status is present" do
      let(:status) { "student" }

      it { is_expected.to be_valid }

      context "and status is not in list" do
        let(:status) { "Unknown status" }

        it { is_expected.to be_invalid }
      end

      context "and provenance is present" do
        let(:provenance) { scope.id }

        it { is_expected.to be_valid }

        context "and is not present in list" do
          let(:provenance) { 235 }

          it { is_expected.to be_invalid }
        end
      end
    end

    context "when the provenance is not present" do
      let(:provenance) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the status is 'partner'" do
      let(:status) { "partner" }

      context "and provenance is present" do
        let(:provenance) { scope.id }

        it { is_expected.to be_invalid }
      end

      context "and provenance is not present" do
        let(:provenance) { nil }

        it { is_expected.to be_valid }
      end
    end

    context "when the nickname is not present" do
      let(:nickname) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the email is not present" do
      let(:email) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the email already exists" do
      let!(:user) { create(:user, organization: organization, email: email) }

      it { is_expected.to be_invalid }

      context "and is pending to accept the invitation" do
        let!(:user) { create(:user, organization: organization, email: email, invitation_token: "foo", invitation_accepted_at: nil) }

        it { is_expected.to be_invalid }
      end
    end

    context "when the nickname already exists" do
      let!(:user) { create(:user, organization: organization, nickname: nickname) }

      it { is_expected.to be_invalid }

      context "and is pending to accept the invitation" do
        let!(:user) { create(:user, organization: organization, nickname: nickname, invitation_token: "foo", invitation_accepted_at: nil) }

        it { is_expected.to be_valid }
      end
    end

    context "when the nickname is too long" do
      let(:nickname) { "verylongnicknamethatcreatesanerror" }

      it { is_expected.to be_invalid }
    end

    context "when the password is not present" do
      let(:password) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the password is weak" do
      let(:password) { "aaaabbbbcccc" }

      it { is_expected.to be_invalid }
    end

    context "when the password confirmation is not present" do
      let(:password_confirmation) { nil }

      it { is_expected.to be_invalid }
    end

    context "when the password confirmation is different from password" do
      let(:password_confirmation) { "invalid" }

      it { is_expected.to be_invalid }
    end

    context "when the tos_agreement is not accepted" do
      let(:tos_agreement) { "0" }

      it { is_expected.to be_invalid }
    end
  end
end
