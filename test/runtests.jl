using ClassificationMetrics
using Test
using Aqua
using JET

@testset "ClassificationMetrics.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(ClassificationMetrics)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(ClassificationMetrics; target_defined_modules = true)
    end
    # Write your tests here.
end
