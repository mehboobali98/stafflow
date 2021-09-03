class AddSubdomainToCompanies < ActiveRecord::Migration[6.0]
  def change
    add_column :companies, :subdomain, :string
  end
end
