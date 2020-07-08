module Timeout

function timeout(f, timeout_sec)
    t = @async begin
        task = current_task()
        function timeout_cb(timer)
            Base.throwto(task, InterruptException())
        end
        timeout = Timer(timeout_cb, timeout_sec)
        try
            f()
        catch e
            if typeof(e) == InterruptException
                @error "Timed out after $(timeout_sec)s"
            end
            throw(e)
        end
        close(timeout)
    end
    try
        wait(t)
    catch ex
        throw(ex.task.exception)
    end
end

"""
    @timeout limit expr

Runs `expr` as and throws an `InterruptException` after `timeout_sec`.
## Example:
```julia
julia> @timeout 0.5 sleep(1)
┌ Error: Timed out after 0.5s
└ @ Main REPL[1]:12
ERROR: InterruptException:
Stacktrace:
 [1] timeout(::var"#8#9", ::Float64) at ./REPL[1]:21
 [2] top-level scope at REPL[3]:1
```
"""
macro timeout(limit, expr)
    :(timeout(()->$expr, $limit))
end

export @timeout

end # module
