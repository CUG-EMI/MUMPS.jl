# Factorize two different matrices (one real, one complex) and solve for multiple rhs and free memory
if nworkers()<3
    addprocs(3)
end
@everywhere using MUMPS
if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end
using Compat
include("getDivGrad.jl");

A  = getDivGrad(24,20,22);
A2 = getDivGrad(30,31,33);

n  = size(A,1);
n2 = size(A2,1);
A  = A + im*spdiagm(rand(n),0);

nrhs = 10;
rhs = randn(n,nrhs) + im*randn(n,nrhs);
rhs2 = randn(n2,nrhs);

@test nworkers()>=3

println("Factorize complex matrix on worker 1")
tic();
F1 = remotecall_fetch(factorMUMPS,workers()[1], A,1)
toc();
dump(F1)

println("Factorize real matrix on worker 2")
tic();
F2 = remotecall_fetch(factorMUMPS,workers()[2],A2,1)
toc();
dump(F2)

println("Solve complex system on worker 1")
tic();
x = remotecall_fetch(applyMUMPS,workers()[3],F1,rhs)
toc();
err = zeros(nrhs)
for i=1:nrhs
        err[i] =  norm(A*x[:,i]-rhs[:,i]) / norm(rhs[:,i])
end
@test maximum(err) < 1e-14

println("Solve real system on worker 2")
tic();
x2 = remotecall_fetch(applyMUMPS,workers()[2],F2,rhs2)
toc();
err = zeros(nrhs)
for i=1:nrhs
        err[i] =  norm(A2*x2[:,i]-rhs2[:,i]) / norm(rhs2[:,i]);
end
@test maximum(err) < 1e-14

println("Free memory on worker 1")
destroyMUMPS(F1)
# remotecall_fetch(destroyMUMPS,workers()[1],F1);

println("Free memory on worker 2")
destroyMUMPS(F2)
# remotecall_fetch(destroyMUMPS,workers()[2],F2);

println("DONE!")


