defmodule FxTest do
  use ExUnit.Case
  use Fx

  test "local function with no placeholders" do
    f = fx rem(5,4)
    assert f.() == 1
  end

  test "local function with one placeholder" do
    f = fx rem(5, &1)
    assert f.(3) == 2
  end

  test "local function with two placeholders" do
    f = fx rem(&1, &2)
    assert f.(5, 3) == 2
  end

  test "local function with two placeholders out of order" do
    f = fx rem(&2, &1)
    assert f.(3, 5) == 2
  end
  
  test "local function with non-sequential placeholders" do
    f = fx rem(&1, &4)
    assert f.(5, 4, 3, 2) == 1
  end

  test "local function with explicit arity" do 
    f = fx 3, rem(&1, &2)
    assert f.(5, 3, "unused") == 2
  end

  test "explicit arity is overriden by higher numbered placeholder" do
    f = fx 1, rem(&1, &2)
    assert f.(5, 3) == 2
  end


  ##
  #   Remote functions

  test "remote function with one placeholder" do
    f = fx Kernel.rem(5, &1)
    assert f.(3) == 2
  end

  test "remote function with two placeholders" do
    f = fx Kernel.rem(&1, &2)
    assert f.(5, 3) == 2
  end

  test "remote function with two placeholders out of order" do
    f = fx Kernel.rem(&2, &1)
    assert f.(3, 5) == 2
  end
  
  test "remote function with non-sequential placeholders" do
    f = fx Kernel.rem(&1, &4)
    assert f.(5, 4, 3, 2) == 1
  end

  test "remote function with explicit arity" do 
    f = fx 3, Kernel.rem(&1, &2)
    assert f.(5, 3, "unused") == 2
  end

  test "explicit arity is overriden by higher numbered placeholder" do
    f = fx 1, Kernel.rem(&1, &2)
    assert f.(5, 3) == 2
  end
  
  test "plays nicely with Enum.map" do
    res = Enum.map 1..5, fx(&1*2)
    assert res == [2, 4, 6, 8, 10]
  end

  test "plays nicely with Enum.reduce" do
    res = Enum.reduce 1..5, 0, fx(&1+&2)
    assert res == 15
  end

  test "handles Erlang functions" do
    res = :lists.filter fx(&1 > 3), [1, 2, 3, 4, 5]
    assert res == [4, 5]
  end

  
end

