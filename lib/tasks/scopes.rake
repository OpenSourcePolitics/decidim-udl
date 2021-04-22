# frozen_string_literal: true

namespace :scopes do
  desc "Seed scopes for UDL"
  task seed: :environment do
    raise ArgumentError, "Please provide the organization ID using ORGANIZATION_ID env variable" if ENV["ORGANIZATION_ID"].blank?

    organization_id = ENV["ORGANIZATION_ID"].to_i
    scope_type = Decidim::ScopeType.find_or_create_by!(
      decidim_organization_id: organization_id,
      name: { fr: "Statut", en: "Status" },
      plural: { fr: "Statuts", en: "Statuses" }
    )

    generate_scope_for(:student, organization_id, scope_type.id, true)
    generate_scope_for(:teacher, organization_id, scope_type.id, true)
    generate_scope_for(:personal, organization_id, scope_type.id, true)

    puts "Scope type created ID ##{scope_type.id}"
    puts "Scopes created : #{total_scopes}"
    puts "Task succeeded"

  rescue ArgumentError => e
    puts e.message.to_s
    puts "It will create #{total_scopes} scopes"
    puts "Tasks canceled"
  end
end

def new_scope(opts = {})
  Decidim::Scope.find_or_create_by!(
    decidim_organization_id: opts[:decidim_organization_id],
    name: opts[:name],
    scope_type_id: opts[:scope_type_id],
    code: "#{opts[:code_prefix]}#{opts[:index]}"
  )
end

def generate_scope_for(target, decidim_organization_id, scope_type_id, _save = false)
  target = target.to_sym if target.is_a? String

  scopes[target][:name].each_with_index do |name, idx|
    new_scope(
      decidim_organization_id: decidim_organization_id,
      name: name,
      scope_type_id: scope_type_id,
      code_prefix: scopes[target][:code_prefix],
      index: idx
    )
  end
end

def total_scopes
  total_scopes = 0
  scopes.keys.each { |key| total_scopes += scopes[key][:name].count }

  total_scopes
end

def scopes
  {
    student: {
      name: [
        {
          fr: "Faculté de chirurgie dentaire",
          en: "Faculté de chirurgie dentaire"
        },
        {
          fr: "Faculté de médecine",
          en: "Faculté de médecine"
        },
        {
          fr: "Faculté de pharmacie",
          en: "Faculté de pharmacie"
        },
        {
          fr: "Faculté des humanités",
          en: "Faculté des humanités"
        },
        {
          fr: "Faculté des langues, littératures et civilisations étrangères",
          en: "Faculté des langues, littératures et civilisations étrangères"
        },
        {
          fr: "Faculté des sciences du sport et de l'éducation physique",
          en: "Faculté des sciences du sport et de l'éducation physique"
        },
        {
          fr: "Faculté des sciences économiques, sociales et des territoires",
          en: "Faculté des sciences économiques, sociales et des territoires"
        },
        {
          fr: "Faculté des sciences et technologies",
          en: "Faculté des sciences et technologies"
        },
        {
          fr: "Faculté des sciences juridiques, politiques et sociales",
          en: "Faculté des sciences juridiques, politiques et sociales"
        },
        {
          fr: "Faculté ingénierie et management de la santé",
          en: "Faculté ingénierie et management de la santé"
        },
        {
          fr: "UFR de psychologie",
          en: "UFR de psychologie"
        },
        {
          fr: "UFR DECCID",
          en: "UFR DECCID"
        },
        {
          fr: "UFR langues étrangères appliquées",
          en: "UFR langues étrangères appliquées"
        },
        {
          fr: "IAE Lille - University School of Management",
          en: "IAE Lille - University School of Management"
        },
        {
          fr: "Institut de formation de musiciens intervenant en milieu scolaire",
          en: "Institut de formation de musiciens intervenant en milieu scolaire"
        },
        {
          fr: "Institut de préparation à l'administration générale",
          en: "Institut de préparation à l'administration générale"
        },
        {
          fr: "Institut national supérieur du professorat et de l'éducation de l'académie de Lille - Hauts-de-France (INSPE Lille HdF)",
          en: "Institut national supérieur du professorat et de l'éducation de l'académie de Lille - Hauts-de-France (INSPE Lille HdF)"
        },
        {
          fr: "Institut universitaire de technologie A (IUT A)",
          en: "Institut universitaire de technologie A (IUT A)"
        },
        {
          fr: "Institut universitaire de technologie B (IUT B)",
          en: "Institut universitaire de technologie B (IUT B)"
        },
        {
          fr: "Institut universitaire de technologie C (IUT C)",
          en: "Institut universitaire de technologie C (IUT C)"
        },
        {
          fr: "Ecole polytechnique universitaire de Lille (Polytech Lille)",
          en: "Ecole polytechnique universitaire de Lille (Polytech Lille)"
        },
        {
          fr: "Département Sciences de l'éducation et de la formation d'adultes (SEFA)",
          en: "Département Sciences de l'éducation et de la formation d'adultes (SEFA)"
        },
        {
          fr: "Sciences PO Lille",
          en: "Sciences PO Lille"
        },
        {
          fr: "Ensait (Ecole nationale supérieure des arts et industrie textiles)",
          en: "Ensait (Ecole nationale supérieure des arts et industrie textiles)"
        },
        {
          fr: "ESJ Lille (Ecole supérieure de journalisme de Lille)",
          en: "ESJ Lille (Ecole supérieure de journalisme de Lille)"
        },
        {
          fr: "ENSAPL (Ecole Nationale Supérieure d'Architecture et de Paysage de Lille)",
          en: "ENSAPL (Ecole Nationale Supérieure d'Architecture et de Paysage de Lille)"
        }
      ],
      code_prefix: "SE-"
    },
    teacher: {
      name: [
        {
          fr: "Fondation I-Site",
          en: "Fondation I-Site"
        }
      ],
      code_prefix: "ST-"
    },
    personal: {
      name: [
        {
          fr: "Siège Université de Lille (Site Paul Duez) - Services communs",
          en: "Siège Université de Lille (Site Paul Duez) - Services communs"
        },
        {
          fr: "Siège Université de Lille (Site Paul Duez) - Services centraux",
          en: "Siège Université de Lille (Site Paul Duez) - Services centraux"
        }
      ],
      code_prefix: "SP-"
    }
  }
end
