# frozen_string_literal: true

module Crud
  class SoftDelete < Crud::Destroy
    def destroy
      super do
        instance.soft_delete
      end
    end
  end
end
