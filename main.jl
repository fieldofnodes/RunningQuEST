using Pkg
Pkg.activate(".")
using Graphs
using VeriQuEST


# Grover graph
num_vertices = 8
graph = Graph(num_vertices)
add_edge!(graph,1,2)
add_edge!(graph,2,3)
add_edge!(graph,3,6)
add_edge!(graph,6,7)
add_edge!(graph,1,4)
add_edge!(graph,4,5)
add_edge!(graph,5,8)
add_edge!(graph,7,8)



function forward_flow(vertex)
    v_str = string(vertex)
    forward = Dict(
        "1" =>4,
        "2" =>3,
        "3" =>6,
        "4" =>5,
        "5" =>8,
        "6" =>7,
        "7" =>0,
        "8" =>0)
    forward[v_str]
end


function generate_grover_secret_angles(search::String)

    Dict("00"=>(1.0*π,1.0*π),"01"=>(1.0*π,0),"10"=>(0,1.0*π),"11"=>(0,0)) |>
    x -> x[search] |>
    x -> [0,0,1.0*x[1],1.0*x[2],0,0,1.0*π,1.0*π] |>
    x -> Float64.(x)
end



io = InputOutput(Inputs(),Outputs([7,8]))
qgraph = QuantumGraph(graph,io)
flow = Flow(forward_flow)
search = "11"
secret_angles = generate_grover_secret_angles(search)

measurement_angles = Angles(secret_angles)
total_rounds = 10
computation_rounds = 1
trapification_strategy = TestRoundTrapAndDummycolouring()



# Initial setups
ct = LeichtleVerification(
    total_rounds,
    computation_rounds,
    trapification_strategy,
    qgraph,flow,measurement_angles)
nt_bp = BellPairExplicitNetwork()#
nt_im = ImplicitNetworkEmulation()
st = DensityMatrix()
ch = NoisyChannel(NoNoise(NoQubits()))

for i in Base.OneTo(100)
    ver_res1 = run_verification_simulator(ct,nt_bp,st,ch)
    ver_res2 = run_verification_simulator(ct,nt_im,st,ch)
    @assert ver_res1.tests isa Ok
    @assert ver_res2.tests isa Ok
end

vr = run_verification_simulator(ct,nt_bp,st,ch)
get_tests(vr) 
get_computations(vr)
get_tests_verbose(vr)
get_computations_verbose(vr) 
get_computations_mode(vr) 