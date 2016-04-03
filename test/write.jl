@require "../write" writeEDN entity_id edn_tag

entity_id(x) = object_id(x)

test("primitives") do
  @test writeEDN(nothing) == "nil"
  @test writeEDN(:a) == "a"
  @test writeEDN(1) == "1"
  @test writeEDN(Int8(1)) == "#Int8 [1]"
  @test writeEDN(1.1) == "1.1"
  @test writeEDN(-1.1) == "-1.1"
  @test writeEDN(10000) == "1e4"
  @test writeEDN(true) == "true"
  @test writeEDN(false) == "false"
  @test writeEDN("ab\n") == "\"ab\\n\""
  @test writeEDN('a') == "\\a"
  @test writeEDN('\n') == "\\newline"
end

test("Dict") do
  @test writeEDN(Dict()) == "{}"
  @test writeEDN(Dict(:a=>1)) == "{a 1}"
  @test writeEDN(Dict(:a=>1,true=>2)) == "{a 1 true 2}"
  a = Dict()
  b = Dict(:a => a)
  a[:b] = b
  @test writeEDN(Dict(:a=>a, :b=>b)) == "{a {b {a #ref [a]}} b #ref [a b]}"
end

@test writeEDN(Set()) == "#{}"
@test writeEDN(Set([1])) == "#{1}"
@test writeEDN(Set([2,1])) == "#{2 1}"

@test writeEDN([]) == "[]"
@test writeEDN([1,2]) == "[1 2]"

@test writeEDN(()) == "()"
@test writeEDN((1,2)) == "(1 2)"

@test writeEDN(DateTime(1985,4,12,23,20,50,520)) == "#inst \"1985-04-12T23:20:50.52\""
@test writeEDN(Date(1985,4,12)) == "#inst \"1985-04-12\""

@test writeEDN(Base.Random.UUID(UInt128(1))) == "#uuid \"00000000-0000-0000-0000-000000000001\""

@test writeEDN(1//2) == "#Rational{Int64} [1 2]"
@test writeEDN(Nullable{Int32}(Int32(1))) == "#Nullable{Int32} [#Int32 [1]]"
@test writeEDN(Nullable{Int32}()) == "#Nullable{Int32} []"

type A val end
edn_tag(::A) = "A"

test("composite types") do
  a = A(1)
  b = A(a)
  println(writeEDN([a,b]))
  @test writeEDN([a,b]) == "[#A [1] #A [#ref [1]]]"
end
