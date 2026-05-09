# frozen_string_literal: true

require 'test_helper'
require 'stringio'

class CommandDispatcherTest < Minitest::Test
  FakeManager = Struct.new(:calls, :list_result, :relink_all_result) do
    def add(app) = calls << [:add, app]
    def remove(app) = calls << [:remove, app]
    def relink(app) = calls << [:relink, app]
    def list = list_result || []
    def relink_all = relink_all_result || []
  end

  def setup
    @out = StringIO.new
    @manager = FakeManager.new([], [], [])
  end

  def dispatcher(quiet: false)
    StowMan::CLI::CommandDispatcher.new(manager: @manager, out: @out, quiet: quiet)
  end

  # add

  def test_add_calls_manager_and_prints
    dispatcher.dispatch('add', ['nvim'])

    assert_equal [[:add, 'nvim']], @manager.calls
    assert_equal "Added app 'nvim'\n", @out.string
  end

  def test_add_quiet_suppresses_output
    dispatcher(quiet: true).dispatch('add', ['nvim'])

    assert_equal [[:add, 'nvim']], @manager.calls
    assert_empty @out.string
  end

  def test_add_missing_arg_raises_usage_error
    err = assert_raises(StowMan::UsageError) { dispatcher.dispatch('add', []) }

    assert_includes err.message, 'add requires APP argument'
  end

  def test_add_multiple_args_raises_usage_error
    err = assert_raises(StowMan::UsageError) { dispatcher.dispatch('add', ['nvim', 'zsh']) }

    assert_includes err.message, 'add accepts only one APP argument'
  end

  # list

  def test_list_prints_each_app
    @manager.list_result = %w[nvim zsh]

    dispatcher.dispatch('list', [])

    assert_equal "nvim\nzsh\n", @out.string
  end

  def test_list_empty_manager_prints_nothing
    dispatcher.dispatch('list', [])

    assert_empty @out.string
  end

  def test_list_with_args_raises_usage_error
    err = assert_raises(StowMan::UsageError) { dispatcher.dispatch('list', ['extra']) }

    assert_includes err.message, 'list does not accept arguments'
  end

  # remove

  def test_remove_calls_manager_and_prints
    dispatcher.dispatch('remove', ['nvim'])

    assert_equal [[:remove, 'nvim']], @manager.calls
    assert_equal "Removed app 'nvim'\n", @out.string
  end

  def test_remove_quiet_suppresses_output
    dispatcher(quiet: true).dispatch('remove', ['nvim'])

    assert_empty @out.string
  end

  def test_remove_missing_arg_raises_usage_error
    err = assert_raises(StowMan::UsageError) { dispatcher.dispatch('remove', []) }

    assert_includes err.message, 'remove requires APP argument'
  end

  # relink

  def test_relink_calls_manager_and_prints
    dispatcher.dispatch('relink', ['nvim'])

    assert_equal [[:relink, 'nvim']], @manager.calls
    assert_equal "Relinked app 'nvim'\n", @out.string
  end

  def test_relink_quiet_suppresses_output
    dispatcher(quiet: true).dispatch('relink', ['nvim'])

    assert_empty @out.string
  end

  def test_relink_missing_arg_raises_usage_error
    err = assert_raises(StowMan::UsageError) { dispatcher.dispatch('relink', []) }

    assert_includes err.message, 'relink requires APP argument'
  end

  # relink-all

  def test_relink_all_calls_manager_and_prints_count
    @manager.relink_all_result = %w[nvim zsh]

    dispatcher.dispatch('relink-all', [])

    assert_equal 'Relinked 2 app(s)', @out.string.strip
  end

  def test_relink_all_quiet_suppresses_output
    @manager.relink_all_result = %w[nvim]

    dispatcher(quiet: true).dispatch('relink-all', [])

    assert_empty @out.string
  end

  def test_relink_all_with_args_raises_usage_error
    err = assert_raises(StowMan::UsageError) { dispatcher.dispatch('relink-all', ['extra']) }

    assert_includes err.message, 'relink-all does not accept arguments'
  end

  # unknown command

  def test_unknown_command_raises_usage_error
    err = assert_raises(StowMan::UsageError) { dispatcher.dispatch('frobnicate', []) }

    assert_includes err.message, 'Unknown command: frobnicate'
  end
end
