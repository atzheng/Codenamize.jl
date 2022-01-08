using Test
using Codenamize

a = Dict(:a => 1, :b => 2)
b = Dict(:a => 1, :b => 2)
c = Dict(:a => 2, :b => 2)

@test codenamize(a) == codenamize(b)
@test all(codenamize_particles(a) .!= codenamize_particles(c))
@test codenamize.(randn(1000); adjectives=3) |> unique |> length == 1000

