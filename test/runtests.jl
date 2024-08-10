using ClassificationMetrics
using Test
using Aqua
using JET
function get_pkg_version(name::AbstractString)
    for dep in values(Pkg.dependencies())
        if dep.name == name
            return dep.version
        end
    end
    return error("Dependency not available")
end

@testset "ClassificationMetrics.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(ClassificationMetrics)
    end
    @testset "Code linting (JET.jl)" begin
        if VERSION >= v"1.9"
            @assert get_pkg_version("JET") >= v"0.8.3"
            JET.test_package(ClassificationMetrics; target_defined_modules=true)
        end
    end
    # Write your tests here.
end
