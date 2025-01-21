# frozen_string_literal: true

require "esse"
require_relative "hooks/version"
require_relative "hooks/mixin"
require_relative "hooks/primitives/string"

module Esse
  # Esse::Hooks is a module that extends Esse with hooks capabilities.
  #
  # @example
  #   module Esse::ActiveRecord::Hooks
  #     include Esse::Hooks[store_key: :esse_active_record_hooks]
  module Hooks
    @@hooks = {}.freeze

    module_function

    # Global variable with list of hooks.
    #
    # @return [Hash{Symbol => Module}]
    def hooks
      @@hooks
    end

    # Register a hook.
    #
    # @param [Symbol] name The hook name.
    # @param [Module] hook The hook module.
    def [](store_key:)
      mixin = Mixin.new(store_key: store_key)
      dup = @@hooks.dup
      dup[mixin.store_key] = mixin
      @@hooks = dup.freeze
      mixin
    end

    %i[
      enable!
      disable!
      with_indexing
      with_indexing_for_model
      without_indexing
      without_indexing_for_model
    ].each do |method_name|
      define_method(method_name) do |*args, &block|
        hooks.each_value do |mixin|
          mixin.public_send(method_name, *args, &block)
        end
      end
    end

    %i[
      disabled?
      enabled?
    ].each do |method_name|
      define_method(method_name) do
        hooks.values.all?(&method_name)
      end
    end
  end
end
