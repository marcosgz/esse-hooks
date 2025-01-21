# frozen_string_literal: true

require "spec_helper"

RSpec.describe Esse::Hooks do
  after do
    clear_hooks
  end

  it "has a version number" do
    expect(Esse::Hooks::VERSION).not_to be_nil
  end

  describe ".hooks" do
    it "returns frozen empty hash" do
      expect(described_class.hooks).to eq({})
      expect(described_class.hooks).to be_frozen
    end
  end

  describe ".[]" do
    it "returns a mixin" do
      mixin = described_class[store_key: :foo]
      expect(mixin).to be_a(Esse::Hooks::Mixin)
      expect(mixin.store_key).to eq(:foo)
    end

    it "registers a mixin" do
      mixin = described_class[store_key: :foo]
      expect(described_class.hooks).to eq(foo: mixin)
    end
  end

  describe ".enable!" do
    context "when no hooks are registered" do
      it "does nothing" do
        expect { described_class.enable! }.not_to raise_error
      end
    end

    context "when hooks are registered" do
      let(:mixin) { described_class[store_key: :foo] }

      it "calls the mixin method" do
        allow(mixin).to receive(:enable!)
        described_class.enable!
        expect(mixin).to have_received(:enable!)
      end
    end
  end

  describe ".disable!" do
    context "when no hooks are registered" do
      it "does nothing" do
        expect { described_class.disable! }.not_to raise_error
      end
    end

    context "when hooks are registered" do
      let(:mixin) { described_class[store_key: :foo] }

      it "calls the mixin method" do
        allow(mixin).to receive(:disable!)
        described_class.disable!
        expect(mixin).to have_received(:disable!)
      end
    end
  end

  describe ".disabled?" do
    context "when no hooks are registered" do
      it "returns true" do
        expect(described_class.disabled?).to be(true)
      end
    end

    context "when hooks are registered" do
      let(:mixin) { described_class[store_key: :foo] }

      it "calls the mixin method" do
        allow(mixin).to receive(:disabled?)
        described_class.disabled?
        expect(mixin).to have_received(:disabled?)
      end
    end
  end

  describe ".enabled?" do
    context "when no hooks are registered" do
      it "returns true" do
        expect(described_class.enabled?).to be(true)
      end
    end

    context "when hooks are registered" do
      let(:mixin) { described_class[store_key: :foo] }

      it "calls the mixin method" do
        allow(mixin).to receive(:enabled?)
        described_class.enabled?
        expect(mixin).to have_received(:enabled?)
      end
    end
  end

  describe ".without_indexing" do
    context "when no hooks are registered" do
      it "does nothing" do
        expect { described_class.without_indexing }.not_to raise_error
      end
    end

    context "when hooks are registered" do
      let(:mixin) { described_class[store_key: :foo] }

      it "calls the mixin method" do
        allow(mixin).to receive(:without_indexing)
        described_class.without_indexing
        expect(mixin).to have_received(:without_indexing)
      end
    end
  end

  describe ".without_indexing_for_model" do
    let(:model) { double }

    context "when no hooks are registered" do
      it "does nothing" do
        expect { described_class.without_indexing_for_model(model) }.not_to raise_error
      end
    end

    context "when hooks are registered" do
      let(:mixin) { described_class[store_key: :foo] }

      it "calls the mixin method" do
        allow(mixin).to receive(:without_indexing_for_model)
        described_class.without_indexing_for_model(model)
        expect(mixin).to have_received(:without_indexing_for_model).with(model)
      end
    end
  end

  describe ".with_indexing" do
    context "when no hooks are registered" do
      it "does nothing" do
        expect { described_class.with_indexing }.not_to raise_error
      end
    end

    context "when hooks are registered" do
      let(:mixin) { described_class[store_key: :foo] }

      it "calls the mixin method" do
        allow(mixin).to receive(:with_indexing)
        described_class.with_indexing
        expect(mixin).to have_received(:with_indexing)
      end
    end
  end

  describe ".with_indexing_for_model" do
    let(:model) { double }

    context "when no hooks are registered" do
      it "does nothing" do
        expect { described_class.with_indexing_for_model(model) }.not_to raise_error
      end
    end

    context "when hooks are registered" do
      let(:mixin) { described_class[store_key: :foo] }

      it "calls the mixin method" do
        allow(mixin).to receive(:with_indexing_for_model)
        described_class.with_indexing_for_model(model)
        expect(mixin).to have_received(:with_indexing_for_model).with(model)
      end
    end
  end
end
