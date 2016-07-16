module CatViews

using Base.Cartesian

export CatView

immutable CatView{T<:Number,N} <: AbstractArray{T,1}
    arr::NTuple{N,AbstractVector{T}}
    len::NTuple{N,Integer}
end

Base.size(A::CatView) = (sum(A.len),)

# TODO: Base.@propagate_inbounds ?

function Base.getindex(A::CatView, i::Int)
    i < 1 || i > length(A) && throw(BoundsError("index out of bounds."))

    a = 0
    b = A.len[1]
    for j = 1:length(A.len)
        if i <= b
            return A.arr[j][i-a]
        else
            a = b
            b = b + A.len[j+1]
        end
    end   
end

function Base.setindex!(A::CatView, val, i::Int)
    i < 1 || i > length(A) && throw(BoundsError("index out of bounds."))

    a = 0
    b = A.len[1]
    for j = 1:length(A.len)
        if i <= b
            A.arr[j][i-a] = val
            return val
        else
            a = b
            b = b + A.len[j+1]
        end
    end   
end

@inline function CatView{T}(a::AbstractVector{T}...)
    CatView(a)
end

@generated function CatView{N,T}(arr::NTuple{N,AbstractArray{T}})
  quote
  len = @ntuple $N (n)->length(arr[n])
  CatView{T,N}(arr,len)
  end
end


end # module
