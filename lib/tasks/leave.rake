namespace :leave do
  desc 'reset remaining count of user leaves'
  task reset_leaves: :environment do
    logger = Logger.new('leave_rake_task.log')
    Company.all.each do |company|
      company.user_leaves.includes(:applied_leaves).where(applied_leaves: { archived: false }).find_each do |user_leave|
        ActiveRecord::Base.transaction do
          user_leave.update!(remaining_count: user_leave.count)
          user_leave.applied_leaves.each do |applied_leave|
            applied_leave.update!(archived: true)
          end
        rescue ActiveRecord::RecordInvalid
          logger.error "#{Time.now}--#{company.id}--#{user_leave.id}, failed to reset."
        end
      end
    end
  end
end