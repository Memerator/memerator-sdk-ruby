# A report!
class Memerator::Report
  # @!visibility private
  def initialize(data)
    @data = data
  end

  # @return [Integer] the report ID.
  def id
    @data['id']
  end

  # The status of the meme. Used to see where the report is.
  # Status 0 means it's open and unclaimed
  # Status 1 means it's claimed, but not settled.
  # Status 2 means it's resolved.
  def status
    @data['status']
  end

  # @return [String] the ID of the meme being reported.
  def memeid
    @data['memeid']
  end

  # @return [String] the reason for the report.
  def reason
    @data['message']['reason']
  end

  # @return [String] more detailed explanation
  def description
    @data['message']['description']
  end

  # @return [User] the staff member assigned to this report
  # @return [nil] if no one is assigned.
  def assignee
    return nil if @data['assignee'].nil?

    Memerator::User.new(@data['assignee'])
  end

  # @return [String, nil] the staff member's comment, if they responded.
  def comment
    @data['comment']
  end

  # @return [true, false] if the report is open
  def open?
    status == 0
  end

  # @return [true, false] if the report is assigned to someone
  def assigned?
    status == 1
  end

  # @return [true, false] if the report is closed
  def closed?
    status == 2
  end
end
