# Fx–Extended Anonymous Functions for Elixir

This is a simple library that let's me play with alternative
anonymous function declaration syntaxes in Elixir.

In the same way that you can write `&(&1+&2)` (soon to be `&(%1+%1)`)
in Elixir, this library lets you write `fx(&1+&2)`.

However, unlike the `&` capture in Elixir, `fx` also supports

* Capturing functions with zero arity


  ~~~
  (fx IO.puts("Hello").()   #=> Hello
  
  f = fx 42
  IO.puts f.()              #=> 42
  ~~~

* Faking out the arity

  `Enum.each 1..3, fx(1, IO.puts("hello"))`

* Having non-sequential placeholders

  ~~~
  f = fx &2 + &4
  IO.puts f.(5,6,7,8)  #=> 14
  ~~~

### Usage:

Add `/pragdave/elixir-fx` to your dependencies, and `use Fx` anywhere
you want the `fx` helper.

### If I Can Convince José

(and this isn't going to happen...). Add a new operator (perhaps `\`
or `$`) or add some of this functionality to `&` when the parameters
change from `&1` to `%1`. This would also make it easier to implement
the `&(%1+%2)` → `&Kernel.+/2` trick.

### Copyright and License

Copyright © 2013 Dave Thomas, The Pragmatic Programmers

Licensed under the same terms as Elixir.
