# frozen_string_literal: true

class UsersController < ApplicationController
  
  def create
    Users::Create.perform(
      user_params.merge(current_user:),
      default_create_callbacks,
      User
    )
  end
end