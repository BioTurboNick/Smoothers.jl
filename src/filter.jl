"""
Package: Smoothers

    filter(b,a,x,si)

Apply a digital filter to x using the following linear, time-invariant difference equation

```math
y(n) = \\sum_{k=0}^M d_{k+1} \\cdot x_{n-k}-\\sum_{k=1}^N c_{k+1} \\cdot y_{n-k} 
\\\\ \\forall n | 1\\le n \\le \\left\\| x \\right\\| | c=a/a_1, d=b/a_1
```

The implementation follows the description of [Octave filter function](https://octave.sourceforge.io/octave/function/filter.html)

# Arguments
- `a`: Vector of numerator coefficients for the filter rational transfer function.
- `b`: Vector of denominator coefficients for the filter rational transfer function.
- `x`: Vector of data.
- `si`: Vector of initial states.

# Returns

Vector of filtered data

# Examples
```julia-repl
using Plots

t = Array(LinRange(-pi,pi,100));
x = sin.(t) .+ 0.25*rand(length(t));

# Moving Average Filter
w = 5; 
b = ones(w)/w;
a = [1];

plot(t,x,label="sin(x)",legend=:bottomright)
y1 = filter(b,a,x)
si = x[1:4] .+ .1;
y2 = filter(b,a,x,si)
plot!(t,y1,label="MA")
plot!(t,y2,label="MA with si")
```
"""
@inline function filter(b::AbstractVector{A},
                        a::AbstractVector{B},
                        x::AbstractVector{C},
                        si::AbstractVector{D}=zeros(C,max(length(a),length(b))-1)
                        ) where {A<:Real,B<:Real,C<:Real,D<:Real}

    a,b,x,si = promote(a,b,x,si)
    
    Na,Nb,Nx = length(a),length(b),length(x)
    Nsi = max(Na,Nb)-1
    @assert Nsi == length(si) "length(si) must be max(length(a),length(b))-1)"
    @assert a[1] != 0 "a[1] must not be zero"
    
    N,M = Na-1,Nb-1
    c,d = a/a[1],b/a[1]

    T = eltype(x)
    y = zeros(T,Nx)
    y[1:Nsi] = si

    for n in 1:Nx
        for k in 0:M
            @inbounds y[n] += n-k > 0 ? d[k+1]*x[n-k] : T(0)
        end
        for k in 1:N
            @inbounds y[n] -= n-k > 0 ? c[k+1]*y[n-k] : T(0)
        end
    end
    y
end