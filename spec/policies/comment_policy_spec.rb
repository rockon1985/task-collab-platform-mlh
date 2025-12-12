require 'rails_helper'

RSpec.describe CommentPolicy, type: :policy do
  let(:project) { create(:project, owner: project_owner) }
  let(:task) { create(:task, project: project, creator: project_owner) }
  let(:comment) { create(:comment, task: task, user: comment_author) }
  let(:project_owner) { create(:user) }
  let(:comment_author) { create(:user) }
  let(:admin_user) { create(:user, role: 'admin') }
  let(:other_user) { create(:user) }

  describe '#show?' do
    it 'grants access to any user' do
      policy = described_class.new(other_user, comment)
      expect(policy.show?).to be true
    end
  end

  describe '#create?' do
    it 'grants access to any user' do
      policy = described_class.new(other_user, comment)
      expect(policy.create?).to be true
    end
  end

  describe '#update?' do
    it 'grants access to comment author' do
      policy = described_class.new(comment_author, comment)
      expect(policy.update?).to be true
    end

    it 'grants access to admin users' do
      policy = described_class.new(admin_user, comment)
      expect(policy.update?).to be true
    end

    it 'denies access to other users' do
      policy = described_class.new(other_user, comment)
      expect(policy.update?).to be false
    end
  end

  describe '#destroy?' do
    it 'grants access to comment author' do
      policy = described_class.new(comment_author, comment)
      expect(policy.destroy?).to be true
    end

    it 'grants access to admin users' do
      policy = described_class.new(admin_user, comment)
      expect(policy.destroy?).to be true
    end

    it 'denies access to other users' do
      policy = described_class.new(other_user, comment)
      expect(policy.destroy?).to be false
    end
  end
end
