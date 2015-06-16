class Registry < ActiveRecord::Base
  has_many :namespaces
  validates :name, presence: true, uniqueness: true
  validates :hostname, presence: true, uniqueness: true

  def create_global_namespace!
    team = Team.create(
      name: Namespace.sanitize_name(hostname),
      owners: [User.where(admin: true).first],
      hidden: true)
    Namespace.create!(
      name: Namespace.sanitize_name(hostname),
      registry: self,
      public: true,
      global: true,
      team: team)
  end

  def global_namespace
    Namespace.find_by(registry: self, global: true)
  end
end