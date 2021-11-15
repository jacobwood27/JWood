using Plots, StatsBase, LinearAlgebra
LinearAlgebra.BLAS.set_num_threads(1)

function sim(f, p, b, n)
    x = 1.0
    for _ in 1:n
        w = f*x
        if rand() < p
            x = x + w*b
        else
            x = x - w
        end
    end
    return x
end

function simV(f, p, b, n)
    X = ones(n+1)
    x = 1.0
    X[1] = x
    for i in 1:n
        w = f*x
        if rand() < p
            x = x + w*b
        else
            x = x - w
        end
        X[i+1] = x
    end
    return X
end

function sim(f, p, b, n, N_mc)
    X = zeros(N_mc)
    @Threads.threads for i in 1:N_mc
        X[i] = sim(f, p, b, n)
    end
    return X
end


X = [simV(0.5,0.5,1.9,5) for _ in 1:50]
plot(X, legend=false)





# Betting 50% on a 2:1 bet
X = sim(100, 0.5, 0.5, 1.0, 2, 1000000);
plot(X,lt=:hist,bins=0:10:300,normalize=:probability)
gcdf = ecdf(X)
plot(twinx(),x -> gcdf(x), 0, 300, axis=:right,color=:red,xticks=:none,ylims=[0,1])

# Variance increases, but EV is even over 100 rolls with enough sims, looks like some rounding error might effect us at higher numbers of simulations
f(n) = mean(sim(100, 0.5, 0.5, 2.0, n, 1000000))
X = [f.(1:100) for _ in 1:10]
plot(X, ylims = [0,200], legend=false)

X = [f.(1:10) for _ in 1:10]
plot(X, legend=false)


P1 = []
P49 = []
P99 = []
P199 = []
N = 100000
for n in 1:1000
    X = sim(100, 0.7, 0.99, 0.01, n, N)
    push!(P1, count(X.>1)/N)
    push!(P49, count(X.>49)/N)
    push!(P99, count(X.>99)/N)
    push!(P199, count(X.>199)/N)
end

plot(P1)
plot!(P49)
plot!(P99)
plot!(P199)
ylims!(0.99,1.0)




function sime(f,b,p,n)
    l = [(1-p)^(n-k) * p^k *binomial(big(n),k) for k in 0:n]
    r = [(1-f)^(n-k) * (1+f*b)^k for k in 0:n]
    e = sum(l.*r)
    return l,r,e
end

function frac_gt(l,r,thresh = 0.999)
    idx = r.>thresh
    sum(l[idx])
end

l,r,e = sime(0.5,2.1,0.5,50)
frac_gt(l,r)

x = []
E = []
for n in 1:50
    l,r,e = sime(0.5,2.0,0.5,n)
    push!(x, frac_gt(l,r,2.0))
    push!(E,e)
end
plot(x)
plot(E, yaxis=:log)




# Bet it all on a sure thing?
f = 0.99; b = 1.1; p = 0.9;
x = []
E = []
for n in 1:25
    l,r,e = sime(f,b,p,n)
    push!(x, frac_gt(l,r,2.0))
    push!(E,e)
end
plot(x, title="Chance we double our money")



b = 1.1; p = 0.5;
b = 1.; p = 0.6;

f = (p + (p-1)/b)/4
x = []
E = []
for n in 1:300
    l,r,e = sime(f,b,p,n)
    push!(x, frac_gt(l,r,10.0))
    push!(E,e)
end
plot(x, title="Chance we double our money", lw=2, legend=false, ylims=[0.0,1.0])



b = 1.1; p = 0.9;
b = 1.; p = 0.6;

f = (p + (p-1)/b)*2
x = []
E = []
for n in 1:300
    l,r,e = sime(f,b,p,n)
    push!(x, frac_gt(l,r,10.0))
    push!(E,e)
end
plot(E, title="Expected Value", lw=2, legend=false)