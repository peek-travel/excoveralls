defmodule ExCoveralls do
  @moduledoc """
  Provides the entry point for coverage calculation and output.
  This module method is called by Mix.Tasks.Test
  """
  alias ExCoveralls.Stats
  alias ExCoveralls.Cover
  alias ExCoveralls.ConfServer
  alias ExCoveralls.StatServer
  alias ExCoveralls.Travis
  alias ExCoveralls.Circle
  alias ExCoveralls.Semaphore
  alias ExCoveralls.Drone
  alias ExCoveralls.Local
  alias ExCoveralls.Html
  alias ExCoveralls.Json
  alias ExCoveralls.Post

  @type_travis      "travis"
  @type_circle      "circle"
  @type_semaphore   "semaphore"
  @type_drone       "drone"
  @type_local       "local"
  @type_html        "html"
  @type_json        "json"
  @type_post        "post"

  @doc """
  This method will be called from mix to trigger coverage analysis.
  """
  def start(compile_path, _opts) do
    Cover.compile(compile_path)
    fn() ->
      execute(ConfServer.get)
    end
  end

  def execute(options) do
    stats = Cover.modules() |> Stats.report() |> Enum.map(&Enum.into(&1, %{}))

    if options[:umbrella] do
      store_stats(stats, options)
    else
      analyze(stats, options[:type] || "local", options)
    end
  end

  defp store_stats(stats, options) do
    stats = Stats.append_sub_app_name(stats, options[:relative_to])
    Enum.each(stats, fn(stat) -> StatServer.add(stat) end)
  end

  @doc """
  Logic for posting from travis-ci server
  """
  def analyze(stats, @type_travis, options) do
    Travis.execute(stats, options)
  end

  @doc """
  Logic for posting from circle-ci server
  """
  def analyze(stats, @type_circle, options) do
    Circle.execute(stats, options)
  end

  @doc """
  Logic for posting from semaphore-ci server
  """
  def analyze(stats, @type_semaphore, options) do
    Semaphore.execute(stats, options)
  end

  @doc """
  Logic for posting from drone-ci server
  """
  def analyze(stats, @type_drone, options) do
    Drone.execute(stats, options)
  end

  @doc """
  Logic for local stats display, without posting server
  """
  def analyze(stats, @type_local, options) do
    Local.execute(stats, options)
  end

  @doc """
  Logic for html stats display, without posting server
  """
  def analyze(stats, @type_html, options) do
    Html.execute(stats, options)
  end

  @doc """
  Logic for JSON output, without posting server
  """
  def analyze(stats, @type_json, options) do
    Json.execute(stats, options)
  end

  @doc """
  Logic for posting from general CI server with token.
  """
  def analyze(stats, @type_post, options) do
    Post.execute(stats, options)
  end

  def analyze(_stats, type, _options) do
    raise "Undefined type (#{type}) is specified for ExCoveralls"
  end
end
