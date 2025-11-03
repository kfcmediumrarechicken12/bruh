class LaunchDiscussionWorkflow

  def initialize(discussion, host, raw_emails)
    @discussion = discussion
    @host = host
    @raw_emails = raw_emails
    @participants = []
  end

    def prepare_participants
    emails = parse_emails
    @participants = emails.map { |email| User.create(email: email, password: Devise.friendly_token) }
  end

    # Expects @participants array to be filled with User objects
  def run
    return unless valid_participants?

    run_callbacks(:create) do
      ActiveRecord::Base.transaction do
        @discussion.save!
        create_discussion_roles!
      end
    end
  end

  def parse_emails
    return [] if @raw_emails.blank?

    @raw_emails
      .split(/\s+/)
      .map(&:strip)
      .reject(&:empty?)
      .map(&:downcase)
      .uniq
  end

  def valid_participants?
    @participants.any?
  end
end

discussion = Discussion.new(title: "fake", ...)
host = User.find(42)
participants = "fake1@example.com\nfake2@example.com\nfake3@example.com"

workflow = LaunchDiscussionWorkflow.new(discussion, host, participants)
workflow.prepare_participants
workflow.run