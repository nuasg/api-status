class Notice < ApplicationRecord
  enum severity: %w(info success warning danger dark)

  def deactivate
    self.active = false
    self.deactivated = DateTime.now

    self.save!
  end
end
