# frozen_string_literal: true

require "spec_helper"

RSpec.describe Esse::Hooks::Mixin do
  let(:store_key) { :esse_test_hooks }

  let(:hook_mixin) do
    key = store_key
    Module.new do
      include Esse::Hooks[store_key: key]
    end
  end

  let(:animal_model) do
    Class.new do
      def self.esse_callbacks
        {
          AnimalsIndex::Cat => {},
          AnimalsIndex::Dog => {}
        }
      end
    end
  end

  let(:user_model) do
    Class.new do
      def self.esse_callbacks
        {
          UsersIndex::User => {}
        }
      end
    end
  end

  let(:repositories) { AnimalsIndex.repo_hash.values + UsersIndex.repo_hash.values }

  before do
    stub_esse_index(:animals) do
      repository(:cat, const: true) {}
      repository(:dog, const: true) {}
    end

    stub_esse_index(:users) do
      repository(:user, const: true) {}
    end

    hook_mixin.register_model(animal_model)
    hook_mixin.register_model(user_model)
    allow(hook_mixin).to receive(:all_repos).and_return(repositories)
  end

  after do
    clear_hooks
  end

  describe ".resolve_index_repository" do
    specify do
      expect(hook_mixin.resolve_index_repository("users")).to eq(UsersIndex.repo(:user))
    end

    specify do
      expect(hook_mixin.resolve_index_repository("users_index")).to eq(UsersIndex.repo(:user))
    end

    specify do
      expect(hook_mixin.resolve_index_repository("users_index:user")).to eq(UsersIndex.repo(:user))
    end

    specify do
      expect(hook_mixin.resolve_index_repository("users:user")).to eq(UsersIndex.repo(:user))
    end

    specify do
      expect(hook_mixin.resolve_index_repository("UsersIndex")).to eq(UsersIndex.repo(:user))
    end

    specify do
      expect(hook_mixin.resolve_index_repository("UsersIndex::User")).to eq(UsersIndex.repo(:user))
    end

    specify do
      stub_const("Foo::V1::UsersIndex", UsersIndex)
      expect(hook_mixin.resolve_index_repository("Foo::V1::UsersIndex")).to eq(Foo::V1::UsersIndex.repo(:user))
      expect(hook_mixin.resolve_index_repository("foo/v1/users")).to eq(Foo::V1::UsersIndex.repo(:user))
      expect(hook_mixin.resolve_index_repository("foo/v1/users_index")).to eq(Foo::V1::UsersIndex.repo(:user))
      expect(hook_mixin.resolve_index_repository("foo/v1/users_index/user")).to eq(Foo::V1::UsersIndex.repo(:user))
      expect(hook_mixin.resolve_index_repository("foo/v1/users:user")).to eq(Foo::V1::UsersIndex.repo(:user))
    end
  end

  describe ".disable!" do
    it "disables the indexing of all repositories" do
      expect(hook_mixin.enabled?).to be true
      repositories.each do |repo|
        expect(hook_mixin.enabled?(repo)).to be true
        expect(hook_mixin.disabled?(repo)).to be false
      end

      hook_mixin.disable!

      expect(hook_mixin.enabled?).to be false
      repositories.each do |repo|
        expect(hook_mixin.enabled?(repo)).to be false
        expect(hook_mixin.disabled?(repo)).to be true
      end
    end

    it "disables the indexing for one or more indices" do
      expect(hook_mixin.enabled?(AnimalsIndex)).to be true
      expect(hook_mixin.enabled?(UsersIndex)).to be true

      hook_mixin.disable!(UsersIndex)

      expect(hook_mixin.enabled?(AnimalsIndex)).to be true
      expect(hook_mixin.enabled?(AnimalsIndex::Cat)).to be true
      expect(hook_mixin.enabled?(AnimalsIndex::Dog)).to be true
      expect(hook_mixin.enabled?(UsersIndex)).to be false
      expect(hook_mixin.enabled?(UsersIndex::User)).to be false
    end

    it "disables the indexing for one or more repositories" do
      expect(hook_mixin.enabled?(AnimalsIndex::Cat)).to be true
      expect(hook_mixin.enabled?(AnimalsIndex::Dog)).to be true
      expect(hook_mixin.enabled?(UsersIndex::User)).to be true

      hook_mixin.disable!(AnimalsIndex::Cat)

      expect(hook_mixin.enabled?(AnimalsIndex::Cat)).to be false
      expect(hook_mixin.enabled?(AnimalsIndex::Dog)).to be true
      expect(hook_mixin.enabled?(UsersIndex::User)).to be true

      expect(hook_mixin.disabled?(AnimalsIndex::Cat)).to be true
      expect(hook_mixin.disabled?(AnimalsIndex::Dog)).to be false
      expect(hook_mixin.disabled?(UsersIndex::User)).to be false
    end
  end

  describe ".enable!" do
    before do
      hook_mixin.disable!
    end

    it "enables the indexing of all repositories" do
      expect(hook_mixin.enabled?).to be false
      repositories.each do |repo|
        expect(hook_mixin.enabled?(repo)).to be false
        expect(hook_mixin.disabled?(repo)).to be true
      end

      hook_mixin.enable!

      expect(hook_mixin.enabled?).to be true
      repositories.each do |repo|
        expect(hook_mixin.enabled?(repo)).to be true
        expect(hook_mixin.disabled?(repo)).to be false
        expect(hook_mixin.enabled?(repo)).to be true
        expect(hook_mixin.disabled?(repo)).to be false
      end
    end

    it "disables the indexing for one or more indices" do
      expect(hook_mixin.enabled?(AnimalsIndex)).to be false
      expect(hook_mixin.enabled?(UsersIndex)).to be false

      hook_mixin.enable!(UsersIndex)

      expect(hook_mixin.enabled?(AnimalsIndex)).to be false
      expect(hook_mixin.enabled?(AnimalsIndex::Cat)).to be false
      expect(hook_mixin.enabled?(AnimalsIndex::Dog)).to be false
      expect(hook_mixin.enabled?(UsersIndex)).to be true
      expect(hook_mixin.enabled?(UsersIndex::User)).to be true
    end

    it "enables the indexing for one or more repositories" do
      expect(hook_mixin.enabled?(AnimalsIndex::Cat)).to be false
      expect(hook_mixin.enabled?(AnimalsIndex::Dog)).to be false
      expect(hook_mixin.enabled?(UsersIndex::User)).to be false

      hook_mixin.enable!(AnimalsIndex::Cat)

      expect(hook_mixin.enabled?(AnimalsIndex::Cat)).to be true
      expect(hook_mixin.enabled?(AnimalsIndex::Dog)).to be false
      expect(hook_mixin.enabled?(UsersIndex::User)).to be false
      expect(hook_mixin.disabled?(AnimalsIndex::Cat)).to be false
      expect(hook_mixin.disabled?(AnimalsIndex::Dog)).to be true
      expect(hook_mixin.disabled?(UsersIndex::User)).to be true
    end
  end

  describe ".without_indexing" do
    specify do
      expect(hook_mixin.enabled?).to be true
      hook_mixin.without_indexing do
        expect(hook_mixin.enabled?).to be false
        expect(hook_mixin.disabled?).to be true
      end
      expect(hook_mixin.enabled?).to be true
    end

    specify do
      expect(hook_mixin.enabled?).to be true
      hook_mixin.without_indexing(AnimalsIndex::Cat, UsersIndex::User) do
        expect(hook_mixin.enabled?(AnimalsIndex::Cat)).to be false
        expect(hook_mixin.enabled?(UsersIndex::User)).to be false
        expect(hook_mixin.enabled?(AnimalsIndex::Dog)).to be true
      end
      expect(hook_mixin.enabled?(UsersIndex::User)).to be true
      expect(hook_mixin.enabled?(AnimalsIndex::Cat)).to be true
      expect(hook_mixin.enabled?(AnimalsIndex::Dog)).to be true
    end

    specify do
      expect(hook_mixin.enabled?).to be true
      hook_mixin.without_indexing(AnimalsIndex) do
        expect(hook_mixin.enabled?(AnimalsIndex)).to be false
        expect(hook_mixin.enabled?(AnimalsIndex::Cat)).to be false
        expect(hook_mixin.enabled?(AnimalsIndex::Dog)).to be false
        expect(hook_mixin.enabled?(UsersIndex::User)).to be true
        expect(hook_mixin.enabled?(UsersIndex)).to be true
      end
      expect(hook_mixin.enabled?(UsersIndex::User)).to be true
      expect(hook_mixin.enabled?(AnimalsIndex::Cat)).to be true
      expect(hook_mixin.enabled?(AnimalsIndex::Dog)).to be true
    end

    specify do
      hook_mixin.disable!
      expect(hook_mixin.disabled?).to be true
      hook_mixin.without_indexing do
        expect(hook_mixin.enabled?).to be false
        expect(hook_mixin.disabled?).to be true
      end
      expect(hook_mixin.disabled?).to be true
    end
  end

  describe ".enable_model! and .disable_model!" do
    it "raises an error if the model class does not registered" do
      expect {
        hook_mixin.enable_model!(Class.new)
      }.to raise_error(/is not registered. The model should inherit from Esse::ActiveRecord::Model/)
    end

    it "enables and disables the indexing callbacks for the given model" do
      expect(hook_mixin.enabled_for_model?(animal_model)).to be true
      expect(hook_mixin.enabled_for_model?(user_model)).to be true

      hook_mixin.disable_model!(animal_model)
      expect(hook_mixin.enabled_for_model?(animal_model)).to be false
      expect(hook_mixin.enabled_for_model?(user_model)).to be true

      hook_mixin.enable_model!(animal_model)
      expect(hook_mixin.enabled_for_model?(animal_model)).to be true
      expect(hook_mixin.enabled_for_model?(user_model)).to be true
    end

    it "enables the indexing callbacks for the given model and repository" do
      expect(hook_mixin.enabled_for_model?(animal_model)).to be true
      expect(hook_mixin.enabled_for_model?(user_model)).to be true

      hook_mixin.disable_model!(animal_model, AnimalsIndex::Cat)
      expect(hook_mixin.enabled_for_model?(animal_model)).to be false
      expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Cat)).to be false
      expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Dog)).to be true
      expect(hook_mixin.enabled_for_model?(user_model)).to be true

      hook_mixin.enable_model!(animal_model, AnimalsIndex::Cat)
      expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Cat)).to be true
    end
  end

  describe ".without_indexing_for_model" do
    specify do
      expect(hook_mixin.enabled?).to be true
      expect(hook_mixin.enabled_for_model?(animal_model)).to be true
      expect(hook_mixin.enabled_for_model?(user_model)).to be true
      hook_mixin.without_indexing_for_model(animal_model) do
        expect(hook_mixin.enabled?).to be true
        expect(hook_mixin.enabled_for_model?(animal_model)).to be false
        expect(hook_mixin.enabled_for_model?(user_model)).to be true
      end
      expect(hook_mixin.enabled_for_model?(animal_model)).to be true
      expect(hook_mixin.enabled_for_model?(user_model)).to be true
    end

    specify do
      expect(hook_mixin.enabled?).to be true
      expect(hook_mixin.enabled_for_model?(animal_model)).to be true
      expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Cat)).to be true
      expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Dog)).to be true
      expect(hook_mixin.enabled_for_model?(user_model)).to be true
      hook_mixin.without_indexing_for_model(animal_model, AnimalsIndex::Cat) do
        expect(hook_mixin.enabled?).to be true
        expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Cat)).to be false
        expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Dog)).to be true
        expect(hook_mixin.enabled_for_model?(user_model)).to be true
      end
      expect(hook_mixin.enabled_for_model?(animal_model)).to be true
      expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Cat)).to be true
      expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Dog)).to be true
      expect(hook_mixin.enabled_for_model?(user_model)).to be true
    end

    it "reverts the to initial state after block execution" do
      hook_mixin.disable_model!(animal_model, AnimalsIndex::Dog)
      expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Cat)).to be true
      expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Dog)).to be false
      hook_mixin.without_indexing_for_model(animal_model, AnimalsIndex::Cat) do
        expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Cat)).to be false
        expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Dog)).to be false
      end
      expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Cat)).to be true
      expect(hook_mixin.enabled_for_model?(animal_model, AnimalsIndex::Dog)).to be false
    end
  end
end
