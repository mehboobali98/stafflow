# frozen_string_literal: true

namespace :leave do
  desc 'reset remaining count of user leaves'
  task reset_leaves: :environment do
    logger = Logger.new('leave_rake_task.log')
    Company.all.each do |company|
      Company.current_company_id = company.id
      if company.setting.present? && company.setting.leave_resets_at.to_date == DateTime.now.to_date
        UserLeave.includes(:applied_leaves).where(applied_leaves: { archived: false }).find_each do |user_leave|
          ActiveRecord::Base.transaction do
            user_leave.update!(remaining_count: user_leave.total_count)
            user_leave.applied_leaves.each do |applied_leave|
              applied_leave.update!(archived: true)
            end
          rescue ActiveRecord::RecordInvalid
            logger.error "#{DateTime.now.to_date}--#{company.id}--#{user_leave.id}, failed to reset leave count."
          end
        end
      end
    end
  end
end
