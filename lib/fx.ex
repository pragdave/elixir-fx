defmodule Fx do

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
      require unquote(__MODULE__)
    end
  end
  
  defmacro fx(arg),        do: _fx(0, arg)
  defmacro fx(arity, arg), do: _fx(arity, arg)
  
  defp _fx(arity, {fun, line, args}) when is_atom(fun) do
    placeholders = find_placeholders_in(args, [])
    generate_local_call(fun, line, args, placeholders, arity)
  end

  defp _fx(arity, {{:., _, _} = fun, line, args}) do
    IO.puts "remote function"
    placeholders = find_placeholders_in(args, [])
    generate_local_call(fun, line, args, placeholders, arity)
  end

  defp _fx(arity, expr) do
    IO.inspect expr
    res = quote do
      fn -> unquote(expr) end
    end
    IO.inspect res
  end

  defp find_placeholders_in([], result), do: Enum.reverse(result)
  defp find_placeholders_in([{:&, _, [n]}|t], result) do
    find_placeholders_in(t, [n | result])
  end
  defp find_placeholders_in([_|t], result) do
    find_placeholders_in(t, result)
  end

  # No placeholders
  defp generate_local_call(fun, line, args, [], 0) do
    quote do
      fn -> unquote(fun)(unquote_splicing(args)) end
    end
  end

  # Placeholders
  defp generate_local_call(fun, line, args, placeholders, arity) do
    named_placeholders = assign_names_to(placeholders)
    fn_params = named_placeholders 
                |> fill_in_missing_placeholders(arity)
                |> Enum.map(fn name -> { name, [], Elixir } end)

    IO.inspect named_placeholders
    IO.inspect fn_params
    IO.inspect args
    args = replace_placeholders_in(args, named_placeholders)

    res = quote do
      fn unquote_splicing(fn_params) -> unquote(fun)(unquote_splicing(args)) end
    end
    IO.puts(inspect res, pretty: true)
    res
  end


  defp assign_names_to(placeholders) do
    placeholders
    |> Enum.uniq
    |> Enum.reduce(HashDict.new, &name_for(&1, &2))
  end

  defp name_for(placeholder, hash) do
    Dict.put_new hash, placeholder, :"param #{placeholder}"
  end

  defp fill_in_missing_placeholders(named_placeholders, arity) do
    highest = named_placeholders |> Dict.keys |> Enum.sort |> List.last

    1..max(highest || 0, arity)
    |> Enum.reduce(named_placeholders, &add_one_missing(&1, &2))
    |> Enum.map(fn {_,pname} -> pname end)
  end

  defp add_one_missing(n, dict) do
    Dict.put_new dict, n, :_
  end

  defp replace_placeholders_in({:&, line, [n]}, named_placeholders) do
    { Dict.get(named_placeholders, n), line, Elixir }
  end

  defp replace_placeholders_in({atom, line, list}, named_placeholders) do
    { atom,
      line, 
      replace_placeholders_in(list, named_placeholders)
    }
  end

  defp replace_placeholders_in(list, named_placeholders) when is_list(list) do
    Enum.map(list, 
             fn node -> 
                  replace_placeholders_in(node, named_placeholders) end) 
  end

  defp replace_placeholders_in(thing, _), do: thing

end
