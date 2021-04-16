# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  class RegistrationForm < Form
    mimic :user

    STATUSES = [
      { value: "student" }, { value: "teacher" }, { value: "personal" }, { value: "partner", hidden: true }
    ].freeze

    PROVENANCE_SCOPE_TYPE = "Provenance"

    attribute :name, String
    attribute :nickname, String
    attribute :email, String
    attribute :password, String
    attribute :password_confirmation, String
    attribute :newsletter, Boolean
    attribute :tos_agreement, Boolean
    attribute :current_locale, String
    attribute :status, String
    attribute :provenance, String

    validates :name, presence: true
    validates :status, presence: true

    validates :nickname, presence: true, format: /\A[\w\-]+\z/, length: { maximum: Decidim::User.nickname_max_length }
    validates :email, presence: true, 'valid_email_2/email': { disposable: true }
    validates :password, confirmation: true
    validates :password, password: { name: :name, email: :email, username: :nickname }
    validates :password_confirmation, presence: true
    validates :tos_agreement, allow_nil: false, acceptance: true

    validate :email_unique_in_organization
    validate :nickname_unique_in_organization
    validate :no_pending_invitations_exist

    validate :provenance_presence_required

    def newsletter_at
      return nil unless newsletter?

      Time.current
    end

    def statuses
      STATUSES
    end

    def provenances
      scope_provenances
    end

    private

    def email_unique_in_organization
      errors.add :email, :taken if User.no_active_invitation.find_by(email: email, organization: current_organization).present?
    end

    def nickname_unique_in_organization
      errors.add :nickname, :taken if User.no_active_invitation.find_by(nickname: nickname, organization: current_organization).present?
    end

    def no_pending_invitations_exist
      errors.add :base, I18n.t("devise.failure.invited") if User.has_pending_invitations?(current_organization.id, email)
    end

    def no_status_selected
      errors.add :status, I18n.t("devise.failure.no_status_selected")
    end

    def no_provenance_selected
      errors.add :status, I18n.t("devise.failure.no_provenance_selected")
    end

    def provenance_not_in_list
      errors.add :provenance, I18n.t("devise.failure.not_in_list")
    end

    def provenance_not_required?
      status_without_provenance.include? status
    end

    def provenance_presence_required
      return no_status_selected if status.blank?
      return if provenance_not_required?

      no_provenance_selected if provenance.blank?
      # provenance_not_in_list if provenance_list.include? provenance
    end

    def status_without_provenance
      STATUSES.select { |stat| stat[:value] && stat[:hidden] }&.collect { |status| status[:value] }
    end

    def provenance_scope_type_id
      Decidim::ScopeType.where(organization: current_organization).where("name ->>'fr' = ? ", PROVENANCE_SCOPE_TYPE)&.first.try(:id)
    end

    def scope_provenances
      Decidim::Scope.where(organization: current_organization, scope_type_id: provenance_scope_type_id)
    end
  end
end
