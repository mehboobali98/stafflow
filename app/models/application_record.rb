class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.inherited(subclass)
    super

    subclass.instance_eval do
      def set_not_multitenant
        @not_multitenant = true
      end

      def multitenant?
        @not_multitenant.nil?
      end

      # The block is evaluated per query rather than here, which is what makes
      # the opt-out readable at all: `inherited` runs before the class body, so
      # `set_not_multitenant` has not been called yet at this point. A tenant
      # that is unset yields `company_id IS NULL` and matches nothing, so the
      # scope fails closed rather than open.
      default_scope { multitenant? ? where(company_id: Company.current_company_id) : all }
    end
  end
end
