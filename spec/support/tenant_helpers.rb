# frozen_string_literal: true

# The application resolves the current tenant from the request subdomain and
# stores it in Thread.current. Specs have no request, so they set it directly.
module TenantHelpers
  # Runs the block with the given company as the current tenant, restoring
  # whatever was set before. Nesting is safe.
  def as_tenant(company)
    previous = Company.current_company_id
    Company.current_company_id = company.id
    yield
  ensure
    Company.current_company_id = previous
  end

  # Reads a model without any tenant scoping, for asserting what is really in
  # the table rather than what the current tenant is allowed to see.
  def unscoped(model)
    model.unscoped
  end
end
