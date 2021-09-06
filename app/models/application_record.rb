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
    end

    trace = TracePoint.new(:end) do |trace_point|
      if trace_point.self == subclass && trace_point.self.multitenant?
        trace.disable
        subclass.instance_eval { default_scope { where(company_id: Company.current_company_id) } }
      end
    end
    trace.enable
  end
end