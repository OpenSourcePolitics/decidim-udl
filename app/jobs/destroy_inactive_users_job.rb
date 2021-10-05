# frozen_string_literal: true

require "rake"

class DestroyInactiveUsersJob < ApplicationJob
  queue_as :scheduled

  def perform
    Rails.application.load_tasks

    Rake::Task[task].reenable
    Rake::Task[task].invoke
  end

  private

  def task
    "decidim:destroy_inactive_users"
  end
end
