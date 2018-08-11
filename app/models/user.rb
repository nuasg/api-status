class User < ApplicationRecord
  ADMINS = ['sdc2637']

  def self.admins
    self.where admin: true
  end
end
