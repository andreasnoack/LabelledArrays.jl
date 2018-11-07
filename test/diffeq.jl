using LabelledArrays, OrdinaryDiffEq, Test

LorenzVector = @SLArray Float64 (:x,:y,:z)
LorenzParameterVector = @SLArray Float64 (:σ,:ρ,:β)

function f(u,p,t)
  x = p.σ*(u.y-u.x)
  y = u.x*(p.ρ-u.z) - u.y
  z = u.x*u.y - p.β*u.z
  LorenzVector(x,y,z)
end

u0 = LorenzVector(1.0,0.0,0.0)
p = LorenzParameterVector(10.0,28.0,8/3)
tspan = (0.0,10.0)
prob = ODEProblem(f,u0,tspan,p)
sol = solve(prob,Tsit5())
@test typeof(prob.u0) == eltype(sol.u) == LorenzVector
@test typeof(prob.p) == LorenzParameterVector
@test sol[10].x > 0

function iip_f(du,u,p,t)
  du.x = p.σ*(u.y-u.x)
  du.y = u.x*(p.ρ-u.z) - u.y
  du.z = u.x*u.y - p.β*u.z
end

u0 = @LArray [1.0,0.0,0.0] (:x,:y,:z)
p = LorenzParameterVector(10.0,28.0,8/3)
tspan = (0.0,10.0)
prob = ODEProblem(iip_f,u0,tspan,p)

@test similar(u0) isa LArray
@test zero(u0) isa LArray

sol = solve(prob,Tsit5())
@test typeof(prob.u0) == eltype(sol.u) == typeof(u0)
@test typeof(prob.p) == LorenzParameterVector
@test sol[10].x > 0
