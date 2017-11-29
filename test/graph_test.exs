defmodule GraphTest do
  use ExUnit.Case
  doctest Graph

  test "greets the world" do
    assert Graph.hello() == :world
  end
end
