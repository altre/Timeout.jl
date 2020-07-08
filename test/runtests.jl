using Test
using Timeout

@testset "Timeout" begin
    t = @elapsed @test_throws InterruptException @timeout 0.5 sleep(10)
    @test t < 10
    @test_throws ErrorException @timeout 0.5 throw(ErrorException("bar"))
end