module NeuronNumbers

import Random
import Base: isless, ==

export NeuronState, coldneuron, hotneuron, coolneuron

"""
    NeuronState <: Number

NeuronState encodes the "state" of a neuron as an Int8.

The possible states are:
    * `state = 0` for a "cold", or "off", state, meaning it can be triggered by a signal but it has not yet been triggered
    * `state = 1` for a "hot", or "on", state, meaning it has been triggered by a signal.

The aliases are
    * `coldneuron = NeuronState(Int8(0))`
    * `hotneuron = NeuronState(Int8(1))`
"""
struct NeuronState <: Number
    state::Int8
end

const coldneuron = NeuronState(Int8(0))
const hotneuron = NeuronState(Int8(1))

Base.show(io::IO, x::NeuronState) = print(io, x == coldneuron ? "cold" : "hot ")
Base.show(io::IO, ::MIME"text/plain", x::NeuronState) = print(io, "NeuronState:\n  ", x)

NeuronState(x::Number) = iszero(x) ? coldneuron :  hotneuron
(::Type{NeuronState})(x::NeuronState) = x
Base.convert(::Type{NeuronState}, y::Number) = NeuronState(y)
Base.convert(::Type{NeuronState}, y::NeuronState) = y

Base.float(x::Type{NeuronState}) = x

==(::NeuronState, ::Number) = false
==(::Number, ::NeuronState) = false
==(x::NeuronState, y::NeuronState) = x.state == y.state

isless(x::NeuronState, ::Number) = x != hotneuron
isless(::Number, x::NeuronState) = x == hotneuron
isless(x::NeuronState, y::NeuronState) = isless(x.state, y.state)

Base.one(NeuronState) = convert(NeuronState, 1)
Base.zero(NeuronState) = convert(NeuronState, 0)
Base.isnan(::NeuronState) = false
Base.isfinite(::NeuronState) = true
Base.typemin(::Type{NeuronState}) = coldneuron
Base.typemax(::Type{NeuronState}) = hotneuron

Base.size(::NeuronState) = ()
Base.size(::NeuronState, d::Integer) = d < 1 ? throw(BoundsError()) : 1
Base.axes(::NeuronState) = ()
Base.axes(::NeuronState, d::Integer) = d < 1 ? throw(BoundsError()) : Base.OneTo(1)
Base.eltype(::Type{NeuronState}) = NeuronState
Base.ndims(x::NeuronState) = 0
Base.ndims(::Type{NeuronState}) = 0
Base.length(x::NeuronState) = 1
Base.firstindex(x::NeuronState) = 1
Base.firstindex(::NeuronState, d::Int) = d < 1 ? throw(BoundsError()) : 1
Base.lastindex(x::NeuronState) = 1
Base.lastindex(::NeuronState, d::Int) = d < 1 ? throw(BoundsError()) : 1
Base.IteratorSize(::Type{NeuronState}) = Base.HasShape{0}()
Base.keys(::NeuronState) = Base.OneTo(1)

Base.getindex(x::NeuronState) = x

@inline Base.getindex(x::NeuronState, i::Integer) = @boundscheck i == 1 ? x : throw(BoundsError())
@inline Base.getindex(x::NeuronState, I::Integer...) = @boundscheck all(isone, I) ? x : throw(BoundsError())

Base.first(x::NeuronState) = x
Base.last(x::NeuronState) = x
Base.copy(x::NeuronState) = x

Base.signbit(x::NeuronState) = x.state < 0
Base.sign(x::NeuronState) = x.state

Base.iterate(x::NeuronState) = (x, nothing)
Base.iterate(::NeuronState, ::Any) = nothing
Base.isempty(x::NeuronState) = false
Base.in(x::NeuronState, y::NeuronState) = x == y

Base.map(f, x::NeuronState, ys::NeuronState...) = f(x, ys...)

Base.big(::NeuronState) = NeuronState

Base.promote_rule(::Type{NeuronState}, ::Type{<:Number}) = NeuronState

Random.rand(rng::Random.AbstractRNG, ::Random.SamplerType{NeuronState}) = 
    rand(rng, (coldneuron, hotneuron))

for f in [:+, :-, :abs, :abs2, :inv, :tanh, 
        :exp, :log, :log1p, :log2, :log10,
        :conj, :transpose, :adjoint, :angle]
    @eval Base.$f(x::NeuronState) = x
end

for f in [:one, :oneunit]
    @eval Base.$f(::NeuronState) = hotneuron
end

for f in [:zero]
    @eval Base.$f(::NeuronState) = coldneuron
end

for f in [:+, :-]
  @eval Base.$f(x::NeuronState, y::NeuronState) = max(x,y)
end

for f in [:*, :/, :^, :mod, :div, :rem, :widemul]
    @eval Base.$f(x::NeuronState, y::NeuronState) = max(x, y)
end

for f in [:+, :-, :*, :/, :^, :mod, :div, :rem, :widemul]
    # specialize to avoid conflict with Base
    @eval Base.$f(x::NeuronState, ::Integer) = x 
    @eval Base.$f(::Integer, y::NeuronState) = y
    @eval Base.$f(x::NeuronState, ::Real) = x
    @eval Base.$f(::Real, y::NeuronState) = y
    @eval Base.$f(x::NeuronState, ::Number) = x
    @eval Base.$f(::Number, y::NeuronState) = y
end

coolneuron(x) = x isa AbstractFloat ? coldneuron : x

end  # module
