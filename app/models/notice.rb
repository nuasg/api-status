class Notice < ApplicationRecord
  validates :title, presence: true
  enum severity: %w(info success warning danger dark)

  def deactivate
    self.active = false
    self.deactivated = DateTime.now

    self.save!
  end

  def self.has_active_auto_notice?
    !self.find_by(active: true, auto: true).nil?
  end
end
