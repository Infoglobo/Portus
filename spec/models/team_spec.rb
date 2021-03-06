# == Schema Information
#
# Table name: teams
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  hidden      :boolean          default(FALSE)
#  description :text(65535)
#
# Indexes
#
#  index_teams_on_name  (name) UNIQUE
#

require "rails_helper"

describe Team do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:owners) }
  it { should have_many(:namespaces) }

  it "does not check whether the given name is downcased or not" do
    # Does not check name case because:
    # - default namespace is not provided anymore on team creation
    # [ISSUE #234](https://github.com/SUSE/Portus/issues/234)
    # [PR #235](https://github.com/SUSE/Portus/pull/235)
    expect { FactoryGirl.create(:team, name: "TeAm") }.not_to raise_error
  end

  it "Counts all the non special teams" do
    # The registry does not count.
    # NOTE: the registry factory also creates a user.
    create(:registry)
    expect(Team.all_non_special).to be_empty
    expect(Team.count).to be(2)

    # Creating a proper team, this counts.
    create(:team, owners: [User.first])
    expect(Team.all_non_special.count).to be(1)
    expect(Team.count).to be(3)

    # Personal namespaces don't count.
    create(:user)
    expect(Team.all_non_special.count).to be(1)
    expect(Team.count).to be(4)
  end

  describe "make_valid" do
    it "does nothing if there's no team with the name" do
      name = "something"

      expect(Team.make_valid(name)).to eq name
    end

    it "adds an increment if a team with the name already exists" do
      name = "something"

      create(:team, name: name)
      expect(Team.make_valid(name)).to eq "#{name}0"

      create(:team, name: "#{name}0")
      expect(Team.make_valid(name)).to eq "#{name}1"
    end
  end
end
