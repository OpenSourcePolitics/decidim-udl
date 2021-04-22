# frozen_string_literal: true

module Decidim
  # A form object used to handle user registrations
  class RegistrationForm < Form
    mimic :user

    STATUSES = [{ value: "student" }, { value: "teacher" }, { value: "personal" }, { value: "partner", hidden: true }].freeze
    SCOPE_CODES = { "student" => "SE-", "teacher" => "ST-", "personal" => "SP-" }.freeze

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
    validates :nickname, presence: true, format: /\A[\w\-]+\z/, length: { maximum: Decidim::User.nickname_max_length }
    validates :email, presence: true, 'valid_email_2/email': { disposable: true }
    validates :password, confirmation: true
    validates :password, password: { name: :name, email: :email, username: :nickname }
    validates :password_confirmation, presence: true
    validates :tos_agreement, allow_nil: false, acceptance: true
    validates :status, presence: true, inclusion: { in: STATUSES.collect { |status| status[:value] } }

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
      @provenances ||= [student_provenances, personal_provenances, teacher_provenances].flatten.map do |scope|
        [scope.name[I18n.try(:locale).to_s || I18n.default_locale.to_s], scope.id, { "data-status" => search_in_scope_codes(scope.code) }]
      end
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

    def no_provenance_selected
      errors.add :provenance, I18n.t("devise.failure.no_provenance_selected")
    end

    def provenance_not_needed
      errors.add :provenance, I18n.t("devise.failure.not_needed")
    end

    def provenance_not_in_list
      return unless provenance_required?

      errors.add :provenance, I18n.t("devise.failure.not_in_list")
    end

    def provenance_required?
      status_with_provenance.include? status
    end

    def provenance_presence_required
      return if status.blank?
      return provenance_not_in_list unless statuses_list.include?(status)
      return no_provenance_selected if provenance.blank? && provenance_required?
      return provenance_not_needed if provenance.present? && !provenance_required?

      provenance_not_in_list unless provenance_for_status
    end

    def provenance_for_status
      status_exists = false

      provenances.each do |prov|
        status_exists = true if prov.second == provenance.try(:to_i)
      end

      status_exists
    end

    def statuses_list
      STATUSES.collect { |stat| stat[:value] }
    end

    def status_with_provenance
      STATUSES.select { |stat| stat[:hidden].blank? }&.collect { |status| status[:value] }
    end

    def student_provenances
      @student_provenances ||= find_provenance_for("student").to_a
    end

    def personal_provenances
      @personal_provenances ||= find_provenance_for("personal").to_a
    end

    def teacher_provenances
      @teacher_provenances ||= find_provenance_for("teacher").to_a
    end

    def find_provenance_for(type)
      Decidim::Scope.where("code ~* ?", "^#{SCOPE_CODES[type]}")
    end

    def search_in_scope_codes(code)
      SCOPE_CODES.values.each do |value|
        return SCOPE_CODES.key(value) if code.start_with? value
      end
    end
  end
end
