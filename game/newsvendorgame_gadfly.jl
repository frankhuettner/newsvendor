### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ b0df24a1-480b-4d1f-9272-68403f75bd07
begin
	# Some packages will be loaded to speed up the debrief loading
	using  Statistics, Images, LaTeXStrings, DataFrames,ShortCodes,QuadGK,Parameters,OrderedCollections,  Tables, Configurations, Distributions,NewsvendorModel, Gadfly, Compose
	import Tar, CodecZlib	, Random, TOML, JSON3
	md""
end

# ╔═╡ 066e292c-8fcb-40fc-abc2-e9256dae01bd
using PlutoUI

# ╔═╡ dc1d2ab3-49bc-4692-ad57-670697459552
md"""
## The Simulation

#### Your Task...
is to make a decsion at the begining of each round: How many units do you want to stock for this round?

#### Your Goal...
is to maximize your profit.
"""		

# ╔═╡ 5950833a-9ece-4c0e-a603-f5ad165bcc6b
md"# Let's Go!"

# ╔═╡ a4dc0bec-7bda-4609-828b-46da3e3906f3
md"""### Load Previous Play 
... from a previously downloaded *.toml file $(@bind filepicker_toml FilePicker())
"""

# ╔═╡ 6d7a6303-55cb-4380-b044-e8503b257b47
Base.@kwdef struct Scenario
	name::String    # name of the scenario
		
	l::Real = 0 	# lower bound
	u::Real 		# upper bound
	μ::Real = (u - l)/2	 # mean demand
	σ::Real = sqrt((u - l)^2/12) 	# standard deviation of demand
	distr = TruncatedNormal(μ, σ, l, u) 	# Type of the demand distribution
	
	c::Real  # cost of creating one unit
	p::Real   # selling price
	s::Real = 0   # salvage value
	
	Co::Real = c - s   # Overage cost
	Cu::Real = p - c   # Underage cost
	CF::Real = Cu / (Cu + Co)  # Critical fractile
	
	q_opt::Real = quantile(distr, CF)  # profit optimal order quantity
	
	max_num_days::Int = 30  # Maximal number of rounds to play
	delay::Int = 300    # ms it takes for demand to show after stocking decision 
	allow_reset::Bool = true
		
	title::String  # A title to refer to this scenario
	story::String = ""    # An md string explaining the story of the scenario
	story_url::String = ""    # An url indicating md file of the story story 
end;

# ╔═╡ d4e98cf5-3a4b-4574-a582-9b44cf4c0e99
Base.@kwdef mutable struct SimData
	scenario::Scenario    # The scenario of the simulation
		
	demands::Vector{Int64}
	qs::Vector{<:Number} = Vector{Int64}()
	
	days_played::Int = length(qs)
	
	sales::Vector{<:Number} = Vector{Int64}()
	lost_sales::Vector{<:Number} = Vector{Int64}()
	left_overs::Vector{<:Number} = Vector{Int64}()
	revenues::Vector{<:Number} = Vector{Float64}()
	costs::Vector{<:Number} = Vector{Float64}()
	profits::Vector{<:Number} = Vector{Float64}()
	
	total_demand::Int64 = 0
	total_q::Int64 = 0
	total_sale::Int64 = 0
	total_lost_sale::Int64 = 0
	total_left_over::Int64 = 0
	total_revenue::Float64 = 0.0
	total_cost::Float64 = 0.0
	total_profit::Float64 = 0.0
	
	avg_demand::Float64 = 0.0
	avg_q::Float64 = 0.0
	avg_sale::Float64 = 0.0
	avg_lost_sale::Float64 = 0.0
	avg_left_over::Float64 = 0.0
	avg_revenue::Float64 = 0.0
	avg_cost::Float64 = 0.0
	avg_profit::Float64 = 0.0
	
	expected_lost_sales::Float64 = 0.0
	expected_sales::Float64 = 0.0
	expected_left_overs::Float64 = 0.0
	expected_profits::Float64 = 0.0
end; 

# ╔═╡ bbb71ed6-f9ca-41b6-b626-8cc88d7dd518
@option struct PlayLog
	demands::Vector{<:Number} = round.(Int, rand(TruncatedNormal(90, 30, 0, 180), 30))
	qs::Vector{<:Number} = Vector{Int64}()
end

# ╔═╡ f0791331-7272-483f-b20c-42731acd7d1e
@option struct StoryLog
	title::String = "Patisserie Cheers!"
	url::String = "https://raw.githubusercontent.com/frankhuettner/newsvendor/main/scenarios/cheers_1_story.md"
end

# ╔═╡ 5c70225e-711f-4af3-b483-92b534a9f296
@option struct UnitValueLog
	c::Real = 1 	# cost of creating one unit
	p::Real = 5  	# selling price
	s::Real = 0    # salvage value
end

# ╔═╡ 976c24ca-aceb-4ded-9a21-048994e356a9
@option struct DistributionLog
	typus = "Truncated Normal"
	l::Real = 0 	# lower bound
	u::Real = 180		# upper bound
	μ::Real = (u - l)/2	 # mean demand
	σ::Real = (u - l)/6 	# standard deviation of demand
	discrete_probs = [pdf(TruncatedNormal(90, 30, 0, 180), x) / 
				sum(pdf.(TruncatedNormal(90, 30, 0, 180), 1:180))  for x in 1:180]
end

# ╔═╡ fed529bd-dfd6-4314-9035-00bd6f54fc20
@option struct SimConfLog
	max_num_days::Int = 30  # Maximal number of rounds to play
	delay::Int = 300    # ms it takes for demand to show after stocking decision 
	allow_reset::Bool = false
end

# ╔═╡ 8eec208a-817f-4df6-bccb-44c6f03f7f67
@option struct ScenarioLog
	name::String="cheers_1"
	unit_value::UnitValueLog = UnitValueLog()
	distribution::DistributionLog = DistributionLog()
	story::StoryLog = StoryLog()	
	sim_conf::SimConfLog = SimConfLog()
end

# ╔═╡ 9bab1c8f-560c-4b03-acb1-e2ad478ed1ad
@option struct SimLog
	play::PlayLog = PlayLog()
	scenario::ScenarioLog = ScenarioLog()
end

# ╔═╡ c38fe6d4-f4bf-4af3-bfc4-f3f63f005851
html"""
	<style>

	@import url('https://fonts.googleapis.com/css2?family=Lexend+Deca:wght@200;300;400&display=swap');

	pluto-output table>tbody td {
	font-family: 'Lexend Deca', sans-serif;
    font-size: 1rem;
	}
	select, input   {
	font-family: 'Lexend Deca', sans-serif;
    font-size: 1rem;
	}
	pluto-output {
	font-family: 'Lexend Deca', sans-serif;
	}
	pluto-output h1, pluto-output h2, pluto-output h3, pluto-output h4, pluto-output h5, pluto-output h6 {                                                         font-family: 'Lexend Deca', sans-serif;
    font-weight: 300               
	}
	</style>
	"""

# ╔═╡ 25c97465-989e-4ef4-9e42-4c4026be37bd
md"""*Did you know?* Using the the key combo ` ⊞ Win` + `.` in Windows (`⌘` + `Ctrl` + `Space` in Mac OS) opens the smiley keyboard and you can "make" as many 🎂🍰🧁 as you want."""

# ╔═╡ d40b29d6-9254-4b7c-abfe-cfa276da7e8c
md"""
Show code: $(@bind show_ui CheckBox())
"""

# ╔═╡ b8bba9cb-6714-44ba-945a-85990e8207bc
if show_ui
md"# Source Code
## Packages
"
else
	md""
end

# ╔═╡ f2865ca5-ce36-4e6d-b3a0-35d354ef63bd
if show_ui
	md"## Data Structs
### Definition 
	"
else
	md""
end

# ╔═╡ dbc89555-bed9-4315-93b8-f8ffdcf9328f
list_of_datastructs = [Scenario,
	SimData,
SimLog,
	PlayLog,
	ScenarioLog,
	StoryLog,
	UnitValueLog,
	DistributionLog,
	SimConfLog
]; show_ui ? list_of_datastructs : md""

# ╔═╡ 02c37c81-dbbb-48b5-a75f-d58ee354baa9
if show_ui
	md"### Conversion"
else
	md""
end

# ╔═╡ 6e648e01-7b29-4d0e-a637-54c2a2bddef7
function scenariolog_to_scenario(scenariolog)
	scl = scenariolog
	c = scl.unit_value.c
	p = scl.unit_value.p
	s = scl.unit_value.s
	Co = c - s   # Overage cost
	Cu = p - c   # Underage cost
	CF = Cu / (Cu + Co)  # Critical fractile
	l = scl.distribution.l 	
	u = scl.distribution.u		
	μ = scl.distribution.μ	 
	σ = scl.distribution.σ 	
	distr = if scl.distribution.typus == "Uniform"  
			 	Uniform(l, u) 
			elseif scl.distribution.typus == "DiscreteNonParametric"  
				DiscreteNonParametric(l:u, discrete_probs)
			else
				TruncatedNormal(μ, σ, l, u)
			end
	
	Scenario(				
		name = scl.name,
		l = scl.distribution.l, 	
		u = scl.distribution.u,		
		μ = scl.distribution.μ,	 
		σ = scl.distribution.σ, 	
		distr = distr,		
		c = c,  
		p = p,   
		s = s,   
		Co = Co,   
		Cu = Cu,   
		CF = CF,  
		max_num_days = scl.sim_conf.max_num_days,
		delay = scl.sim_conf.delay,
		allow_reset = scl.sim_conf.allow_reset,
		title = scl.story.title,
		story_url = scl.story.url,  
	)
end; show_ui ? scenariolog_to_scenario : md""

# ╔═╡ 1c9428db-b2ce-4069-a018-55a45cc8026f
function scenario_to_scenariolog(scenario)
	sc = scenario
	typus = if typeof(sc.distr) == typeof(Uniform(0, 60))
				"Uniform"  
			elseif typeof(sc.distr) == DiscreteNonParametric([0, 1, 2],[.3,.5,.2]) 
				"DiscreteNonParametric"
			else
				"Truncated Normal"
			end
	discrete_probs = [pdf(sc.distr, i)/
						sum(pdf.(sc.distr, sc.l:sc.u))  for i in 1:length(sc.l:sc.u)]
	
	from_kwargs(ScenarioLog, 
		name = sc.name,
		unit_value_c = sc.c,
		unit_value_p = sc.p,
		unit_value_s = sc.s,
		distribution_l = sc.l, 	
		distribution_u = sc.u,		
		distribution_μ = sc.μ,	 
		distribution_σ = sc.σ,
		distribution_typus = typus,
		distribution_discrete_probs = discrete_probs,	
		sim_conf_max_num_days = sc.max_num_days,
		sim_conf_delay = sc.delay,
		sim_conf_allow_reset = sc.allow_reset,
		story_title = sc.title,
		story_url = sc.story_url,  
	)	
end; show_ui ? scenario_to_scenariolog : md""

# ╔═╡ 1f1f72b4-abc8-443a-83db-578f797506e5
function simdata_to_simlog(simdata) 
	playlog = from_kwargs(PlayLog, qs = simdata.qs, demands = simdata.demands)
	scl = scenario_to_scenariolog(simdata.scenario)
	
	return SimLog(play = playlog, scenario = scl)
end; show_ui ? simdata_to_simlog : md""

# ╔═╡ 132f9155-d296-44d7-bb63-a84528455ae0
function simlogs_to_toml_string(ID, sim_datas)
	simlogs = Dict{String, Any}()	
	for (key,sd) in sim_datas 
		simlogs[key] = sd |> simdata_to_simlog |> to_dict
	end
	io = IOBuffer()
	TOML.print(io, Dict("player_id" => ID, "log" => simlogs))

   	return String(take!(io))
	
end; show_ui ? simlogs_to_toml_string : md""

# ╔═╡ 8989f06f-cff4-4294-98d6-536bb46ed246
function save_simlogs(filename, ID, sim_datas)
	simlogs = Dict{String, Any}()	
	for (key,sd) in sim_datas 
		simlogs[key] = sd |> simdata_to_simlog |> to_dict
	end
	
	open(filename * ".toml", "w") do io
	   	TOML.print(io, Dict("player_id" => ID, "log" => simlogs))
	end
	# filenamejld2 = filename * ".jld2"
	# @save filenamejld2 sim_datas 
	
end; show_ui ? save_simlogs : md""

# ╔═╡ a38416f3-2c4b-4e0f-95e2-424c9cd9ad52
if show_ui
	md"## Parameters"
else
	md""
end

# ╔═╡ be78d60c-50e0-4a41-bbcb-dda259f46438
if show_ui
	md"## Simulation Control"
else
	md""
end

# ╔═╡ 7f6e17dd-55a2-4d01-9bb4-ad045dcdff4c
if show_ui
	md"### Initialization"
else
	md""
end

# ╔═╡ b84291fe-1432-4357-9d77-cab8e3229ee1
function read_available_scenario_conf(path="",fname="available_scenario_confs.toml")	
	available_scenarios = Vector{Scenario}()
	if isfile(path*fname)
		available_scenario_confs = TOML.parsefile(path*fname)
	
		for (scl_name, f) in available_scenario_confs
			if isfile(f)
				scl = from_toml(ScenarioLog, f)
				push!(available_scenarios, scenariolog_to_scenario(scl))
			end
		end
	end
	available_scenarios
end; show_ui ? read_available_scenario_conf : md""

# ╔═╡ a5331fcf-1463-44f4-9343-4cca0f14aee0
begin	
	available_scenarios = read_available_scenario_conf()
	if length(available_scenarios) == 0
		cheers_1 = Scenario(name="cheers_1",
						u=180, σ=30, c=1, p=5, 
						delay=50, max_num_days=30, 
						allow_reset=true,
						title="Patisserie Cheers!", 
						story_url="https://git.io/Jz5EK"
						)
	
		cheers_2 = Scenario(name="cheers_2",
						l=0, u=60, distr=Uniform(0, 60),  c=4.0, p=5.5, 
						delay=50, 
						max_num_days=10,
						allow_reset=true,
						title="Patisserie Cheers! (II)", 
						story_url="https://git.io/Jz5DB")
			
		cheers_3 = Scenario(name="cheers_3",
						u=180, σ=30, c=1.5, p=9, s=0.5, 
						delay=50, max_num_days=10,
						allow_reset=true,
						title="Patisserie Cheers! (III)", 
						story_url="https://git.io/J2yGL")
		
		cheers_4 = Scenario(name="cheers_4",
						l=0, u=2, c=10, p=42, 
						distr=DiscreteNonParametric([0, 1, 2], [.3, .5, .2]),
						μ = mean(DiscreteNonParametric([0, 1, 2], [.3, .5, .2])),
						σ = sqrt(var(DiscreteNonParametric([0, 1, 2], [.3, .5, .2]))),
						delay=50, max_num_days=10,
						allow_reset=true,
						title="Patisserie Cheers! (IV)", 
						story_url="https://git.io/JK8J7")


	
		available_scenarios = [cheers_1, cheers_2, cheers_3, cheers_4]
	end
		
	# save_available_scenario_conf()
	
end; show_ui ? md"`Standard Scenarios`" : md""

# ╔═╡ eddefff7-b3e5-4361-ba6f-4a89dfd67cb3
# refer to predefined scenarios to offer a selection
begin 
	chosen_scenario = available_scenarios[1].name
	if length(available_scenarios) > 1
		
		
md"""
# ⏭ Continue with a Different Scenario
		
You can choose among $(length(available_scenarios)) different scenarios: 
$(@bind chosen_scenario HTML("<select>"*
join(["<option value='"*scenario.name*"'>"*scenario.title*"</option>" for scenario in available_scenarios])* "</select>") )🚪🏃‍"""
	end
end

# ╔═╡ 9787d683-eb06-48d5-917b-96c51bfa37a7
begin
	reset = 0
	resetables = Vector{String}() 
	scenarios_to_be_reset = Vector{String}() 
	for scenario in available_scenarios
		if scenario.allow_reset
			push!(resetables, scenario.title)
		end
	end	
	
	if length(resetables) > 0
md"""
# Reset
Pick a scenario and set it back to start all over again.
		
$(@bind scenarios_to_be_reset MultiSelect(resetables))
$(@bind reset CounterButton("Reset demands and quantities of selected scenario(s)"))
"""
	else
		md""
	end
end

# ╔═╡ 57a99799-10aa-4fd3-be58-fd5b298355ba
if show_ui
	md"### Simulation Events"
else
	md""
end

# ╔═╡ 76565946-55d5-4cb4-aaf0-e41d128a663c
if show_ui
	md"### Simulation Control Helpers"
else
	md""
end

# ╔═╡ 64fe5c24-2d87-4e95-9530-d18fd83049af
function is_sim_running(qs, scenario::Scenario)
	length(qs) < scenario.max_num_days
end; show_ui ? is_sim_running : md""

# ╔═╡ e37d4f2d-1b60-4832-83e4-d9bcd4b4aa01
if show_ui
	md"### Load & Save"
else
	md""
end

# ╔═╡ a6b5030b-b742-456c-b0ae-607b4bb58cd4
my_ID() = replace(replace(replace(@__FILE__, r".jl#.*" => ""), r"^.*\\\s*" => ""), r".*/" => ""); show_ui ? my_ID : md""

# ╔═╡ 3e4a8171-a439-4f29-8c59-611fb9e19a86
md"""
# Save/Load Your Score
### Download 
Enter your ID: $(@bind download_id TextField(default=my_ID()))
"""

# ╔═╡ 9de794aa-3069-4ffc-9ebc-e655b4279a4b
function get_logfile()
	if replace(@__DIR__, r"JuliaHub/.*" => "") == "/home/jrun/Notebooks/"
		# if on JuliaHub
		token = replace(@__DIR__, r"^.*JuliaHub/" => "")
		logfile = "../../../data/"*token
	elseif isdir("../simlog")
		# if on my server
		logfile = "../simlog/simlog_" * my_ID() 
	else
		# just in the same directory
		logfile = joinpath(@__DIR__, "simlog_" * my_ID())
	end
end; show_ui ? get_logfile : md""

# ╔═╡ 4d8d73b3-2977-46fb-afe6-3972f3e8d752
if typeof(filepicker_toml) == Nothing
	if isfile(get_logfile() * ".toml")
		loaded_simdata = TOML.tryparsefile(get_logfile() * ".toml" )
	else
		loaded_simdata = missing
	end
else
	loaded_simdata = TOML.tryparse(filepicker_toml["data"] |> IOBuffer )
end; show_ui ? md"`loaded_simdata`" : md""

# ╔═╡ 6a7a9a80-d414-4569-82be-04f2c0b44e73
if show_ui
	md"## Computation"
else
	md""
end

# ╔═╡ cfaa0a34-2218-4899-bb2d-ee1d7d068938
function my_round(x::Real; sigdigits::Int=3)
	x = round(x, sigdigits=sigdigits)
	if x >= 10^(sigdigits-1)
		Int(x)
	else
		x
	end
end;  show_ui ? my_round : md""

# ╔═╡ 523e474d-2da8-4e20-855d-30690bbbad38
function compute_expected_values(qs::Vector{<:Number}, scenario::Scenario) 
	n_days = length(qs)
	if n_days == 0 return zeros(1,4) end

	expected_values = Matrix{Number}(undef, n_days, 4)

	for i in 1:n_days
		expected_values[i,:] = compute_expected_values(qs[i], scenario) 
	end

	return mean(expected_values, dims=1)
end;  show_ui ? compute_expected_values : md""

# ╔═╡ 9909e1ea-76e3-4f6d-95c9-6203897851cc
# L(x) = ∫ₓᵘ (y - x)f(y)dy
function L(f, x, u)
	L, _ = quadgk(y -> (y - x) * f(y), x, u, rtol=1e-8)
	return L
end; show_ui ? L : md""

# ╔═╡ 9ba19506-9cd0-4a6f-a966-db2e94845f72
function compute_expected_values(q::Number, scenario::Scenario) 
	sc = scenario

	
	expected_lost_sale = L(x->pdf(sc.distr, x), min(q, sc.u), sc.u)
	expected_sale = mean(sc.distr) - expected_lost_sale
	expected_left_over = q - expected_sale
	expected_profit = (sc.p - sc.c) * expected_sale - (sc.c - sc.s) * expected_left_over
	
	return [expected_lost_sale,
			expected_sale,
			expected_left_over,
			expected_profit]
end; show_ui ? compute_expected_values : md""

# ╔═╡ 2f0655ad-b3a6-4dd7-881b-998c511b5650
function update_sim_data!(sd::SimData)
	sd.days_played = length(sd.qs)
	
	sd.sales = min.(sd.qs, sd.demands[1:sd.days_played])
	sd.lost_sales = sd.demands[1:sd.days_played] - sd.sales
	sd.left_overs = sd.qs - sd.sales
	sd.revenues = sd.scenario.p .* sd.sales + sd.scenario.s .* sd.left_overs
	sd.costs = sd.scenario.c .* sd.qs
	sd.profits = sd.revenues - sd.costs
	
	sd.total_demand = sum(sd.demands[1:sd.days_played])
	sd.total_q = sum(sd.qs)
	sd.total_sale = sum(sd.sales)
	sd.total_lost_sale = sum(sd.lost_sales)
	sd.total_left_over = sum(sd.left_overs)
	sd.total_revenue = sum(sd.revenues)
	sd.total_cost = sum(sd.costs)
	sd.total_profit = sum(sd.profits)
	
	if sd.days_played > 0
		sd.avg_demand = sd.total_demand / sd.days_played
		sd.avg_q = sd.total_q / sd.days_played
		sd.avg_sale = sd.total_sale / sd.days_played
		sd.avg_lost_sale = sd.total_lost_sale / sd.days_played
		sd.avg_left_over = sd.total_left_over / sd.days_played
		sd.avg_revenue = sd.total_revenue / sd.days_played
		sd.avg_cost = sd.total_cost / sd.days_played
		sd.avg_profit = sd.total_profit / sd.days_played
	end
	
	sd.expected_lost_sales, sd.expected_sales, sd.expected_left_overs, sd.expected_profits = 	
	compute_expected_values(sd.qs, sd.scenario)
	
end; show_ui ? update_sim_data! : md""

# ╔═╡ 4108e505-a66a-403d-ae5d-aadce5058a99
function simlog_to_simdata(simlog)
	sd = SimData(				
		scenario = scenariolog_to_scenario(simlog.scenario),
		demands = simlog.play.demands,
		qs =  simlog.play.qs,
	)
	update_sim_data!(sd)
	return sd
end; show_ui ? simlog_to_simdata : md""

# ╔═╡ 68359905-a06b-4a40-959b-cfa7dbd3788b
begin
	sim_datas = Dict{String, SimData}()		
	for scenario in available_scenarios
		sim_datas[scenario.name] =  SimData(scenario=scenario, 
									 		 demands=round.(Int, rand(scenario.distr, 
															scenario.max_num_days))
									)
	end
	
	# load simdata from filepicker
	if typeof(loaded_simdata) != Missing
		for scenario in available_scenarios
			# check if some play was saved
			if typeof(loaded_simdata["log"][scenario.name]["play"]["qs"]) == Vector{Int64}
				simlog_load = from_dict(SimLog, loaded_simdata["log"][scenario.name])
				sim_data_load = simlog_to_simdata(simlog_load)
				update_sim_data!(sim_data_load)
				sim_datas[scenario.name] =  sim_data_load			
			end
		end
	end
	
end; 	show_ui ? md"`initialization call`" : md""

# ╔═╡ b8bd59de-5ef5-4da8-99ac-96dcc36b7b0c
begin
# Reseting scenarios that are selected to be reset
	reset
	
	for sc in available_scenarios
		if typeof(scenarios_to_be_reset) != Missing && 
		   scenarios_to_be_reset != "" && 
		   sc.title ∈ scenarios_to_be_reset
			
			new_sim_data = SimData(scenario=sc, 
								demands=round.(Int, rand(sc.distr,	sc.max_num_days)
											)
							)

			sim_datas[sc.name] = new_sim_data
		end
	end
	
show_ui ? md"`reset handling`" : md""
end

# ╔═╡ 2c9271b2-c3e3-498a-9958-e4bc5d0faf2d
begin 
	reset;
	if typeof(chosen_scenario) == Missing
		sim_data = sim_datas[available_scenarios[1].name]
	else
		sim_data = sim_datas[chosen_scenario]
	end
	cluttered_history = [-1.0]; 
	
show_ui ? md"`triggered by reset`" : md""	
end

# ╔═╡ a7d494b4-8fb7-47f2-b06e-55ebf3f36690
if sim_data.scenario.story_url != ""	
	story_file = download(sim_data.scenario.story_url)
	Markdown.parse_file(story_file)
else
	Markdown.parse(sim_data.scenario.story)
end

# ╔═╡ c2bb52a3-6a8a-46f2-98df-af7cb9aecdfc
begin
	sim_data.days_played	
	md"""
	$(@bind q NumberField(0:500, default=0))
	$(@bind submit_counter_button CounterButton("Submit")) *(Please reload the webpage if the submit button does not work.)*
	"""
end

# ╔═╡ e7e4f425-f6b8-450e-92e6-a71ad0a2b904
begin 
	sim_data.days_played
	initial_difference = Vector{Int}()
	
show_ui ? md"`setup handling`" : md""
end

# ╔═╡ 7a2e8ed8-24c8-41d9-a3ed-e38f96b0e172
if submit_counter_button == 1 && sim_data.days_played != 0
	initial_difference[1] = sim_data.days_played - 1
end; show_ui ? md"`submit_counter_button handling`" : md""

# ╔═╡ e4565d5b-3d19-4337-919e-d8fe27990f95
begin
	if typeof(submit_counter_button) != String
		push!(initial_difference, submit_counter_button-sim_data.days_played)
		submit_count = 	initial_difference[1] + submit_counter_button
	else
		submit_count = 0
	end
	
show_ui ? md"`submit_count handling`" : md""
end

# ╔═╡ cc37aec2-3a40-4e4a-8df8-9075ae471440
stringed_toml_for_download() = simlogs_to_toml_string(download_id, sim_datas); show_ui ? stringed_toml_for_download : md""

# ╔═╡ 356cb7b4-addf-4826-98da-f9610b51f221
submit_count; DownloadButton(stringed_toml_for_download(), "result_"*download_id*".toml")

# ╔═╡ 4e7d30ba-fb9e-4848-8fb6-8e388e8a8447
function monte_carlo_for_observed_avg_likelihood(observed_mean, scenario::Scenario, trials=100_000::Int)
	sc = scenario
	
	obs_distance = abs(sc.μ - observed_mean)
	count = 0
	for i in 1:trials
		if abs( mean(rand(sc.distr, sc.max_num_days)) - sc.μ )  > obs_distance
			count = count+1
		end
	end
	return count/trials
end; show_ui ? monte_carlo_for_observed_avg_likelihood : md""

# ╔═╡ 44d1507d-5cc4-420e-86f9-4acd018cf488
if show_ui
	md"## Plot and Table Generation"
else
	md""
end

# ╔═╡ 93501b5a-0862-4f34-9bc5-77589f7f0bdd
function update_submission_and_result_panel(sim_data)
	sd = sim_data
	
	if sd.days_played > 0 && sd.days_played < sd.scenario.max_num_days
md" ##### 👉 How much do you want to stock for day $(sd.days_played+1)?"
	elseif sd.days_played == sd.scenario.max_num_days 
				
md"""
!!! danger "You came to the end of the simulation." 
	👍 Great job!
	
	Scroll down to find a comparison of your result with alternative strategies.
 
	"""
	else
md" ##### 👉 How much do you want to stock for day $(sd.days_played+1)?"
	end
end; show_ui ? update_submission_and_result_panel : md""

# ╔═╡ 32736a2e-3af8-4447-b723-f461a0543cc3
function update_result_panel(sim_data)
	sd = sim_data
	
	if sd.days_played == sd.scenario.max_num_days 
			
days_out_of_stock = count(sd.qs .< sd.demands)
days_demand_satisfied = sd.scenario.max_num_days - days_out_of_stock
service_level = my_round(100 * days_demand_satisfied/sd.scenario.max_num_days)
			
md"""
!!! tip "Here is some information about your play and a comparison with other strategies." 

		

		
##### Your average order was:  $(my_round(sd.avg_q, sigdigits=4)) units.

The **observed average demand** was **$(my_round(sd.avg_demand, sigdigits=4))**, whereas $(my_round(sd.scenario.μ, sigdigits=4)) was expected. (Did you have an extreme sample of demands? To give you an idea as to how (un)usual your random draws were: Out of 100 students runing this simulation, 
$(round(Int,(100*monte_carlo_for_observed_avg_likelihood(sd.avg_demand, sd.scenario))))  observe an average in their simulation that is even further from the mean than yours.)
			


##### ☝️ Your service level was $(service_level)%. 

On $(days_out_of_stock) out of $(sd.scenario.max_num_days), you ran out of stock; **on $(days_demand_satisfied) out of $(sd.scenario.max_num_days), you satisfied all customers**, 
which gives the service level  $(days_demand_satisfied) /  $(sd.scenario.max_num_days) = $(my_round(service_level)) %. 
 
	"""
	else
md""
	end
end; show_ui ? update_result_panel : md""

# ╔═╡ 7c186c55-dbd0-41d6-b2b6-1ab7552a18f1
function update_demand_realization_panel(sim_data::SimData)
	sd = sim_data

	if sd.days_played > 0 && sd.days_played <= sd.scenario.max_num_days
md"""
**Total profit: €$(my_round(sd.total_profit, sigdigits=4))** ``~~`` 

**Average profit: €$(my_round(sd.avg_profit, sigdigits=4))**
		
**Result for day $(sd.days_played):**
		
Day  	| Stocked 	| Demand 	| Sold 	| Left over 	| Lost sales 	| Profit 	|
|---	|---	|---	|---	|---	|---	|---	|
|$(sd.days_played)  | $(sd.qs[end]) 	| $(sd.demands[sd.days_played]) 	| $(sd.sales[end]) 	| $(sd.left_overs[end]) 	| $(sd.lost_sales[end]) 	| €$(sd.profits[end]) 	|	
"""
	else	
md""
	end
end; show_ui ? update_demand_realization_panel : md""

# ╔═╡ 5c9ce442-0f58-4ce5-9742-fd1f98aa8a64
function update_history_table(sim_data::SimData)
	if sim_data.days_played > 0
		T = Tables.table(hcat( 	1:sim_data.days_played,
								sim_data.qs, 
								sim_data.demands[1:sim_data.days_played],
								sim_data.sales,
								sim_data.left_overs,
								sim_data.lost_sales,
								sim_data.profits); 
			
		header = ["Day","Stocked","Demand","Sold","Left over","Lost sales","Profit"])
		# data_table(T)
		T
	else
		return md""
	end
end; show_ui ? update_history_table : md""

# ╔═╡ 69f073e7-2d57-4539-ae5a-17b64b532906
function update_plot_panel_2(sd::SimData)
	
	# T = sd.days_played
	# xs = 1:T
	# Gadfly.set_default_plot_size(18cm ,6cm)


	# plt_profits = Gadfly.plot(
	# 	Gadfly.layer(xmin = xs.-0.3, xmax = xs, y = sd.revenues[1:T], color=[colorant"limegreen"], 		Gadfly.Geom.bar ),
	# 	Gadfly.layer(xmin =xs, xmax = xs.+0.3, y = sd.profits, color=[colorant"gold4"], Gadfly.Geom.bar ),
	# 	Gadfly.layer(xmin = xs.-0.3, xmax = xs, y = 0 .- sd.costs, color=[colorant"deepskyblue3"], Gadfly.Geom.bar ),
		
	# 			Gadfly.Guide.xlabel("Day"), 
	# 			Gadfly.Guide.ylabel(nothing), 
	# 			Gadfly.Guide.xticks(ticks=1:T),
 #   				Gadfly.Guide.manual_color_key("", ["Cost", "Profit", "Revenue"],
	# 				["deepskyblue3", "gold4","limegreen"], size=[5pt, 5pt, 5pt],
	# 			),

	# 	     	Gadfly.style(key_title_font=fig_font,
	# 						 key_label_font=fig_font,
	# 						 major_label_font=fig_font,
	# 						 minor_label_font=fig_font,
	# 			),
		
	# )
end; show_ui ? update_plot_panel_2 : md""

# ╔═╡ e16cb65f-1083-420e-a0d0-3dcbf2faa41c
function show_scenario_data_1(scenario::Scenario)
	sc = scenario

	md"""
	#### Information Abouth The Demand	
	* Customer **demand is uncertain** and will be **between $(sc.l) and $(sc.u)** every day. 
	* Independent of the demand of the previous day, you **expect μ = $(my_round(sc.μ))** and face uncertainty captured by a standard deviation of **σ = $(my_round(sc.σ))**. The distribution is shown in the figure below.
	"""
end; show_ui ? show_scenario_data_1 : md""

# ╔═╡ 2b672651-530b-4337-87b3-a76e2fbe1de5
show_scenario_data_1(sim_data.scenario)

# ╔═╡ a3658128-3822-42c5-ab47-13338cef4f91
function show_scenario_data_3(scenario::Scenario)
	sc = scenario

	md"""
	#### Unit Price and Cost
	* You **pay €$(sc.c)** for each unit that you stock.
	* You **get €$(sc.p)** for each unit that you sell to your customer.
	* At the end of each round, unsold units are discarded at a **salvage value** of **€$(sc.s)**.
	* The simulation lasts for **$(sc.max_num_days) rounds**.
	"""
end; show_ui ? show_scenario_data_3 : md""

# ╔═╡ fea06a1c-6026-4169-baf4-889f9af42798
show_scenario_data_3(sim_data.scenario)

# ╔═╡ 5d4fd167-1392-4af0-ba76-5e724cc08154
if show_ui
	md"## Styling and Pluto Sugur"
else
	md""
end

# ╔═╡ 99e4abb4-9b49-4542-a8c7-3b8ac5a620bd
fig_font = "Lexend Deca"; show_ui ? md"""`fig_font = ` $(fig_font)""" : md""

# ╔═╡ 8aa57969-9116-4eb3-a1cf-e54ddaa00162
function update_plot_panel_1(sim_data::SimData)
	sd = sim_data
	T = sd.days_played
	

if T > 0
	plt_sales = Gadfly.plot(
		Gadfly.layer(y = sd.demands[1:T], size=[3pt], color=[colorant"deepskyblue3"], 		Gadfly.Geom.point, Gadfly.Geom.line, linestyle=[:dash], ),
    	Gadfly.layer(y = sd.qs, size=[3pt], color=[colorant"orange"], Gadfly.Geom.point, Gadfly.Geom.line,  linestyle=[:dash],
				),
    	Gadfly.layer(y = sd.sales, size=[6pt], color=[colorant"limegreen"],  Gadfly.Geom.point			
				),
				
				Gadfly.Guide.xlabel("Day"), 
				Gadfly.Guide.ylabel(nothing), 
				Gadfly.Guide.xticks(ticks=1:T),
   				Gadfly.Guide.manual_color_key("", ["Demand", "Stock", "Sales"],
					["deepskyblue3", "orange","limegreen"], size=[3pt, 3pt, 5pt],
				),
				Gadfly.Coord.Cartesian(xmin=0.7,xmax=T+0.4),

		     	Gadfly.style(key_title_font=fig_font,
							 key_label_font=fig_font,
							 major_label_font=fig_font,
							 minor_label_font=fig_font,
				),
		
	)
	
	
	xs = 1:T
	
	plt_profits = Gadfly.plot(
		Gadfly.layer(xmin = xs.-0.3, xmax = xs, y = sd.revenues[1:T], color=[colorant"limegreen"], 		Gadfly.Geom.bar ),
		Gadfly.layer(xmin =xs, xmax = xs.+0.3, y = sd.profits, color=[colorant"gold4"], Gadfly.Geom.bar ),
		Gadfly.layer(xmin = xs.-0.3, xmax = xs, y = 0 .- sd.costs, color=[colorant"deepskyblue3"], Gadfly.Geom.bar ),
		
				Gadfly.Guide.xlabel("Day"), 
				Gadfly.Guide.ylabel(nothing), 
				Gadfly.Guide.xticks(ticks=1:T),
   				Gadfly.Guide.manual_color_key("", ["Cost", "Profit", "Revenue"],
					["deepskyblue3", "gold4","limegreen"], size=[5pt, 5pt, 5pt],
				),
				Gadfly.Coord.Cartesian(xmin=0.7,xmax=T+0.4),

		     	Gadfly.style(key_title_font=fig_font,
							 key_label_font=fig_font,
							 major_label_font=fig_font,
							 minor_label_font=fig_font,
				),
		
	)
	Gadfly.set_default_plot_size(18cm ,18cm)
	vstack([plt_sales, plt_profits])
else
	md" "
end
end; show_ui ? update_plot_panel_1 : md""

# ╔═╡ 0d2f0256-1e28-47e0-88bd-43a8e47e1f41
function show_scenario_data_2(scenario::Scenario)
	sc = sim_data.scenario
	Gadfly.set_default_plot_size(11cm ,7cm)
	if typeof(sc.distr)==DiscreteNonParametric{Int64, Float64, Vector{Int64}, Vector{Float64}}
		xs = params(sc.distr)[1]
		p = Gadfly.plot(xmin=xs .-0.1, xmax=xs .+0.1, y=pdf.(sc.distr,sc.l:sc.u), 
			Gadfly.Geom.bar(position=:identity),
			Gadfly.Guide.xlabel("Daily Demand"), 
			Gadfly.Guide.ylabel("Probability"), 
			Gadfly.Guide.xticks(ticks=x=sc.l:sc.u),
		)
	else
		xs=sc.l:sc.u
		ys=pdf.(sc.distr,sc.l:sc.u)
		ymins = zeros(length(xs))
		text_μ = Compose.text(sc.μ, pdf(sc.distr,sc.μ)/10, "μ = $(my_round(sc.μ))", 
						 hleft, vbottom, 
						 Compose.Rotation(-pi/2,sc.μ, pdf(sc.distr,sc.μ)/10))
		p = Gadfly.plot(x=xs, y=ys, ymin = ymins, ymax=ys, xintercept=[sc.μ],
			Gadfly.Geom.vline(color="white", style=:dot), 
			Gadfly.Geom.line, 
			Gadfly.Geom.ribbon, 
			Gadfly.Guide.xlabel("Daily Demand"), 
			Gadfly.Guide.ylabel("Likelihood"), 
			Gadfly.Guide.yticks(ticks=nothing),
			Gadfly.Coord.Cartesian(xmin=sc.l,xmax=sc.u),
			Gadfly.Guide.annotation(compose(context(), text_μ, 
									Gadfly.fontsize(10pt), Gadfly.font(fig_font) 
									)),
     	    Gadfly.style(key_title_font=fig_font,
						 key_label_font=fig_font,
						 major_label_font=fig_font,
						 minor_label_font=fig_font,
			)
			
		)
	end
	# Gadfly.draw(SVG("demand.svg", 6inch, 4inch), p)	
end; show_ui ? show_scenario_data_2 : md""

# ╔═╡ 2cfc08fe-3422-4d3b-86c6-38ad59be93a0
show_scenario_data_2(sim_data.scenario)

# ╔═╡ 4c51ede4-cb91-4b45-84cb-e629244c4ac3
function show_scenario_data_4(scenario::Scenario)
	Gadfly.set_default_plot_size(11cm ,7cm)
	sc = scenario
	ys = [1,2,3]
	cs = [colorant"lightblue", colorant"lightsalmon", colorant"palegreen2"]
	text_s = Compose.text(0.02*sc.p, 1, "Unit Salvage Value", hleft, vcenter)
	text_c = Compose.text(0.02*sc.p, 2, "Unit Cost", hleft, vcenter)
	text_p = Compose.text(0.02*sc.p, 3, "Unit Selling Price", hleft, vcenter)
	Gadfly.plot(x=[sc.s,sc.c,sc.p], ymin=ys .- 0.3, ymax=ys .+ 0.3, color=cs,
				Gadfly.Geom.bar(orientation=:horizontal, position=:identity),
				
				Gadfly.Guide.annotation(compose(context(), text_s, 	
										Gadfly.fontsize(12pt), Gadfly.font(fig_font))
				),
				Gadfly.Guide.annotation(compose(context(), text_c, 	
										Gadfly.fontsize(12pt), Gadfly.font(fig_font))
				),
				Gadfly.Guide.annotation(compose(context(), text_p, 	
										Gadfly.fontsize(12pt), Gadfly.font(fig_font))
				),
		
				Gadfly.Guide.xlabel(nothing), 
				Gadfly.Guide.ylabel(nothing), 
				Gadfly.Guide.yticks(ticks=nothing),
				Gadfly.Guide.xticks(ticks=1:sc.p),
		     	Gadfly.style(key_title_font=fig_font,
							 key_label_font=fig_font,
							 major_label_font=fig_font,
							 minor_label_font=fig_font,
				),
	)
end; show_ui ? show_scenario_data_4 : md""

# ╔═╡ f7987a00-fcd2-4237-8812-573eb84c9913
show_scenario_data_4(sim_data.scenario)

# ╔═╡ 627d4b10-6878-4631-843e-ab55de368815
function result_figures(sim_data::SimData) 

	sd = sim_data
	sc = sd.scenario
	
	sftsz = 11
	lftsz = 13
	
	
	results = OrderedDict("Your play" => sd)

	
	naive_data = SimData(scenario = sc, 
						demands = sd.demands, 
						qs = round.(Int,sc.μ*ones(sd.days_played)))
	update_sim_data!(naive_data)
	results["Always order\nthe mean,\nstock = $(sc.μ)"] = naive_data	
	
	opt_data = SimData(scenario = sc, 
						demands = sd.demands, 
						qs = round.(Int,sc.q_opt*ones(sd.days_played)))
	update_sim_data!(opt_data)
	results["The strategy\nthat maximizes\nexpected profit,\ni.e. if Service Level\n= Critical Fractile"] = opt_data
	
	dream_data = SimData(scenario = sc, 
						demands = sd.demands, 
						qs = sd.demands[1:sd.days_played])
	update_sim_data!(dream_data)
	dream_data.expected_lost_sales = 0.0
	dream_data.expected_sales = mean(sc.distr)
	dream_data.expected_left_overs = 0.0
	dream_data.expected_profits = (sc.p-sc.c) * mean(sc.distr)
	compute_expected_values
	results["God mode: you\nknow the future,\nstock = units to\n   be demanded"] = dream_data

	
	plt = Gadfly.plot(Gadfly.Guide.xticks(ticks=1:4),)
	cs = [colorant"lightsalmon", colorant"lightblue", colorant"palegreen", colorant"plum1"]
	

	text_descriptions = []
	x_loc = 1
	for (description, _) in results
		push!(text_descriptions, Compose.text(x_loc, dream_data.expected_profits/20, description, hcenter, vbottom))
		x_loc = x_loc + 1
	end	

	# comparing avg_profit
	avg_profits = my_round.([data.avg_profit for (description, data) in results])
	avg_profits_plt = plot( x=collect(1:4), label=string.(avg_profits),
		xmin=collect(1:4).-0.48, xmax=collect(1:4).+0.48, y=avg_profits ,
		color=cs,
		Geom.label(), Geom.bar, 
		Coord.Cartesian(xmin=0.6,xmax=4+0.4),
        Guide.ylabel("Average Profit With Observed Demands"), 
        Guide.xlabel(nothing), 
		Guide.yticks(ticks=avg_profits ),
		Guide.xticks(ticks=nothing),
		Guide.annotation(compose(context(), text_descriptions[1], font(fig_font))),
		Guide.annotation(compose(context(), text_descriptions[2], font(fig_font))),
		Guide.annotation(compose(context(), text_descriptions[3], font(fig_font))),
		Guide.annotation(compose(context(), text_descriptions[4], font(fig_font))),
	)
	# comparing exp_profit
	exp_profits = my_round.([data.expected_profits for (description, data) in results])
	exp_profits_plt = plot( x=collect(1:4), label=string.(exp_profits),
		xmin= collect(1:4).-0.48, xmax=collect(1:4).+0.48, y=exp_profits, 
		color=cs, alpha=[0.5], Geom.label(), Geom.bar(position=:identity), 
		Coord.Cartesian(xmin=0.6,xmax=4+0.4),
		
        Guide.ylabel("Expected Daily Profit \n(If We Play This Way Forever)"), 
        Guide.xlabel(nothing), 
		Guide.yticks(ticks=exp_profits ),
		Guide.xticks(ticks=nothing),
		Guide.annotation(compose(context(), text_descriptions[1], font(fig_font))),
		Guide.annotation(compose(context(), text_descriptions[2], font(fig_font))),
		Guide.annotation(compose(context(), text_descriptions[3], font(fig_font))),
		Guide.annotation(compose(context(), text_descriptions[4], font(fig_font))),
	)

	Gadfly.set_default_plot_size(18cm ,18cm)
	vstack([avg_profits_plt, exp_profits_plt])

end;   show_ui ? result_figures : md""

# ╔═╡ c0232e07-7fe9-4358-a162-3bf01939063e
function update_result_figures_panel(sd::SimData)
	if sd.days_played == sd.scenario.max_num_days
		result_figures(sd) 
	else
		md""
	end	
end; show_ui ? update_result_figures_panel : md""

# ╔═╡ f93fe5d6-126c-48cf-9127-bb29849f3ae1
begin
	submit_count
	if typeof(q) == Int && is_sim_running(sim_data.qs, sim_data.scenario) 
		if sim_data.days_played < submit_count 
			push!(sim_data.qs, q)
			update_sim_data!(sim_data)
			# push!(anticounter, anticounter[end]+1)			
		end
	end
	
	submission_and_result_panel = update_submission_and_result_panel(sim_data)
	result_panel = update_result_panel(sim_data)
	result_figures_panel = update_result_figures_panel(sim_data)
	sleep(sim_data.scenario.delay / 1000)
	demand_realization_panel = update_demand_realization_panel(sim_data)
	sleep(sim_data.scenario.delay/10_000)
	plot_panel_1 = update_plot_panel_1(sim_data)
	plot_panel_2 = update_plot_panel_2(sim_data)
	result_figures_panel = update_result_figures_panel(sim_data)
	history_table = update_history_table(sim_data)
	
	# @save sim_datas to logfile  
	save_simlogs(get_logfile(), my_ID(), sim_datas)

show_ui ?  md"`triggered by submit_count`" : md""	
end

# ╔═╡ 1080cbab-e04f-4d2d-b6f3-33e8c5e7878f
submission_and_result_panel

# ╔═╡ 2d66e877-ddd9-41ef-b231-de6a41dc9eaa
demand_realization_panel

# ╔═╡ 52902751-b61f-4d1a-9c25-ac219f538528
plot_panel_1

# ╔═╡ 5724d527-7160-46a7-8599-b8c970366ab7
plot_panel_2

# ╔═╡ f408f533-e1d8-4d1d-a79a-976602c559f0
history_table

# ╔═╡ b4f738e6-781a-4e80-9892-3a12680ddfbb
result_panel

# ╔═╡ 90943ce5-bfdb-48b7-beb1-6e7d39222e48
result_figures_panel

# ╔═╡ 08c4d7e6-85ae-4b53-80ed-3a64bb216551
function precompile()
	pre_scl = from_kwargs(ScenarioLog, name="precompile", 
							sim_conf_max_num_days=2, sim_conf_delay=1)		
	playlog = PlayLog(demands = [69, 67])
	sdl = SimLog(scenario = pre_scl, play = playlog) 
	push!(sdl.play.qs, 111) 
	sd = simlog_to_simdata(sdl)
	update_submission_and_result_panel(sd)
	update_result_panel(sd)
	update_result_figures_panel(sd)
	sleep(sd.scenario.delay / 1000)
	update_demand_realization_panel(sd)
	update_plot_panel_1(sd)
	update_plot_panel_2(sd)
	update_result_figures_panel(sd)
	update_history_table(sd)
	push!(sd.qs, 99) 
	
	sd = simlog_to_simdata(sdl)
	update_submission_and_result_panel(sd)
	update_result_panel(sd)
	update_result_figures_panel(sd)
	update_demand_realization_panel(sd)
	update_plot_panel_1(sd)
	update_plot_panel_2(sd)
	update_result_figures_panel(sd)
	update_history_table(sd)
	# save_simlogs(get_logfile(), my_ID(), sim_datas);	
end; precompile(); show_ui ? precompile : md""

# ╔═╡ aaf76732-a964-4e0b-8ed9-d38bb0d985e5
if !show_ui
	html"""
	<style>
	pluto-input {
		display: none;
	}
	main {
    margin-top: 20px;
    cursor: auto;
	}

	#at_the_top,
	#export,
	preamble > button,
	pluto-cell > button,
	pluto-input > button,
	pluto-shoulder,
	footer,
	pluto-runarea,
	#helpbox-wrapper {
	    display: none !important;
	}
	</style>
	"""
end

# ╔═╡ eb03e796-4b3d-49e9-9dc6-02b325940355
md"""
Show TOC: $(@bind show_toc CheckBox())
"""

# ╔═╡ 7ad97285-5bd1-4c4a-89d2-a722ba89ada4
if show_toc
	TableOfContents()
else
	md""
end

# ╔═╡ 34b7fa8d-7ba2-4c7e-b832-0a5ab24d0175
if show_ui
	md"## Unused"
else
	md""
end

# ╔═╡ 73b3e6e7-cf58-4b82-a68f-302dd997887e
# if typeof(loaded_simdata) != Missing
# 	for scenario in available_scenarios
# 		if typeof(loaded_simdata["log"][scenario.name]["play"]["qs"]) == Vector{Int64}
# 			simlog_load = from_dict(SimLog, loaded_simdata["log"][scenario.name])
# 			sim_data_load = simlog_to_simdata(simlog_load)
# 			update_sim_data!(sim_data_load)
# 			sim_datas[scenario.name] =  sim_data_load			
# 		end
# 	end
# end; 
show_ui ? md"`load sim_data`" : md""

# ╔═╡ f7f26892-8999-4236-aa5f-dba4add232e6
# function load_simlog()
	# if isfile(get_logfile() * ".toml")
# 		return = TOML.tryparsefile(get_logfile() * ".toml" )
	# end
# end
show_ui ? md"`load_simlog()`" : md""

# ╔═╡ 928e6d59-b54f-496f-adb7-a078ba9d68c3
function save_available_scenario_conf(available_scenarios=available_scenarios, path="")	
	d = Dict([sc.name => sc.name*"_conf.toml"  for sc in available_scenarios])
	
	open(path*"available_scenario_confs.toml", "w") do io
		TOML.print(to_toml, io, d)
	end
	
	for sc in available_scenarios
		to_toml(path*sc.name*"_conf.toml", sc |> scenario_to_scenariolog)
	end
end; show_ui ? save_available_scenario_conf : md""

# ╔═╡ af0c80a7-09b6-45f5-a379-a2a0cdea20a1
# function data_table(table)
# 	d = Dict(
#         "headers" => [Dict("text" => string(name), "value" => string(name)) for name in Tables.columnnames(table)],
#         "data" => [Dict(string(name) => row[name] for name in Tables.columnnames(table)) for row in Tables.rows(table)]
#     )
# 	djson = JSON3.write(d)
	
# 	return HTML("""
# 		<link href="https://cdn.jsdelivr.net/npm/@mdi/font@5.x/css/materialdesignicons.min.css" rel="stylesheet">


# 	  <div id="app">
# 		<v-app>
# 		  <v-data-table
# 		  :headers="headers"
# 		  :items="data"
# 		></v-data-table>
# 		</v-app>
# 	  </div>

# 	  <script src="https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js"></script>
# 	  <script src="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.js"></script>
	
# 	<script>
# 		new Vue({
# 		  el: '#app',
# 		  vuetify: new Vuetify(),
# 		  data () {
# 				return $djson
# 			}
# 		})
# 	</script>
# 	<style>
# 		.v-application--wrap {
# 			min-height: 10vh;
# 		}
# 		.v-data-footer__select {
# 			display: none;
# 		}
# 	</style>
# 	""")
# end; 
show_ui ? md"`data_table`" : md""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CodecZlib = "944b1d66-785c-5afd-91f1-9de20f533193"
Compose = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
Configurations = "5218b696-f38b-4ac9-8b61-a12ec717816d"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Gadfly = "c91e804a-d5a3-530f-b6f0-dfbca275c004"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
NewsvendorModel = "63d3702b-073a-45e6-b43c-f47e8b08b809"
OrderedCollections = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
Parameters = "d96e819e-fc66-5662-9728-84c9c7592b0a"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
QuadGK = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
ShortCodes = "f62ebe17-55c5-4640-972f-b59c0dd11ccf"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
TOML = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
Tar = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[compat]
CodecZlib = "~0.7.0"
Compose = "~0.9.4"
Configurations = "~0.17.3"
DataFrames = "~1.4.1"
Distributions = "~0.25.53"
Gadfly = "~1.3.4"
Images = "~0.25.2"
JSON3 = "~1.9.4"
LaTeXStrings = "~1.3.0"
NewsvendorModel = "~0.2.2"
OrderedCollections = "~1.4.1"
Parameters = "~0.12.3"
PlutoUI = "~0.7.48"
QuadGK = "~2.6.0"
ShortCodes = "~0.3.3"
Tables = "~1.10.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "e2da484dbb9c7fb7ffd9f27cf3655658356c8fa2"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "69f7020bd72f069c219b5e8c236c1fa90d2cb409"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.2.1"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "195c5505521008abea5aee4f96930717958eac6f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.4.0"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "66771c8d21c8ff5e3a93379480a2307ac36863f7"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.0.1"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "1dd4d9f5beebac0c03446918741b1a03dc5e5788"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.6"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.Calculus]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f641eb0a4f00c343bbc32346e1217b86f3ce9dad"
uuid = "49dc2e85-a5d0-5ad3-a950-438e2897f1b9"
version = "0.5.1"

[[deps.CatIndices]]
deps = ["CustomUnitRanges", "OffsetArrays"]
git-tree-sha1 = "a0f80a09780eed9b1d106a1bf62041c2efc995bc"
uuid = "aafaddc9-749c-510e-ac4f-586e18779b91"
version = "0.2.2"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "5084cc1a28976dd1642c9f337b28a3cb03e0f7d2"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.7"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "Random", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "64df3da1d2a26f4de23871cd1b6482bb68092bd5"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.3"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "d08c20eef1f2cbc6e60fd3612ac4340b89fea322"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.9"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Compose]]
deps = ["Base64", "Colors", "DataStructures", "Dates", "IterTools", "JSON", "LinearAlgebra", "Measures", "Printf", "Random", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "d853e57661ba3a57abcdaa201f4c9917a93487a2"
uuid = "a81c6b42-2e10-5240-aca2-a61377ecd94b"
version = "0.9.4"

[[deps.ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[deps.Configurations]]
deps = ["ExproniconLite", "OrderedCollections", "TOML"]
git-tree-sha1 = "62a7c76dbad02fdfdaa53608104edf760938c4ca"
uuid = "5218b696-f38b-4ac9-8b61-a12ec717816d"
version = "0.17.4"

[[deps.Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[deps.CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "681ea870b918e7cff7111da58791d7f718067a19"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.2"

[[deps.CoupledFields]]
deps = ["LinearAlgebra", "Statistics", "StatsBase"]
git-tree-sha1 = "6c9671364c68c1158ac2524ac881536195b7e7bc"
uuid = "7ad07ef1-bdf2-5661-9d2b-286fd4296dac"
version = "0.2.0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.CustomUnitRanges]]
git-tree-sha1 = "1a3f97f907e6dd8983b744d2642651bb162a3f7a"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.2"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "558078b0b78278683a7445c626ee78c86b9bb000"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.4.1"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "80c3e8639e3353e5d2912fb3a1916b8455e2494b"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.4.0"

[[deps.Distances]]
deps = ["LinearAlgebra", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "3258d0659f812acde79e8a74b11f17ac06d0ca04"
uuid = "b4f34e82-e78d-54a5-968a-f98e89d6e8f7"
version = "0.10.7"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "04db820ebcfc1e053bd8cbb8d8bccf0ff3ead3f7"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.76"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.ExproniconLite]]
git-tree-sha1 = "2321c9c5a07c2658484dacf8e68e3cd8e2470d5d"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.7.6"

[[deps.FFTViews]]
deps = ["CustomUnitRanges", "FFTW"]
git-tree-sha1 = "cbdf14d1e8c7c8aacbe8b19862e0179fd08321c2"
uuid = "4f61f5a4-77b1-5117-aa51-3ab5ef4ef0cd"
version = "0.3.2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "90630efff0894f8142308e334473eba54c433549"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.5.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "7be5f99f7d15578798f338f5433b6c432ea8037b"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.16.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "802bfc139833d2ba893dd9e62ba1767c88d708ae"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.5"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Gadfly]]
deps = ["Base64", "CategoricalArrays", "Colors", "Compose", "Contour", "CoupledFields", "DataAPI", "DataStructures", "Dates", "Distributions", "DocStringExtensions", "Hexagons", "IndirectArrays", "IterTools", "JSON", "Juno", "KernelDensity", "LinearAlgebra", "Loess", "Measures", "Printf", "REPL", "Random", "Requires", "Showoff", "Statistics"]
git-tree-sha1 = "13b402ae74c0558a83c02daa2f3314ddb2d515d3"
uuid = "c91e804a-d5a3-530f-b6f0-dfbca275c004"
version = "1.3.4"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "78e2c69783c9753a91cdae88a8d432be85a2ab5e"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.0+0"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "d61890399bc535850c4bf08e4e0d3a7ad0f21cbd"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.2"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "ba2d094a88b6b287bd25cfa86f301e7693ffae2f"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.7.4"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[deps.Hexagons]]
deps = ["Test"]
git-tree-sha1 = "de4a6f9e7c4710ced6838ca906f81905f7385fd6"
uuid = "a1b4810d-1bce-5fbd-ac56-80944d57a21f"
version = "0.2.0"

[[deps.HypergeometricFunctions]]
deps = ["DualNumbers", "LinearAlgebra", "OpenLibm_jll", "SpecialFunctions", "Test"]
git-tree-sha1 = "709d864e3ed6e3545230601f94e11ebc65994641"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.11"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "c54b581a83008dc7f292e205f4c409ab5caa0f04"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.10"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "b51bb8cae22c66d0f6357e3bcb6363145ef20835"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.5"

[[deps.ImageContrastAdjustment]]
deps = ["ImageCore", "ImageTransformations", "Parameters"]
git-tree-sha1 = "0d75cafa80cf22026cea21a8e6cf965295003edc"
uuid = "f332f351-ec65-5f6a-b3d1-319c6670881a"
version = "0.3.10"

[[deps.ImageCore]]
deps = ["AbstractFFTs", "ColorVectorSpace", "Colors", "FixedPointNumbers", "Graphics", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "Reexport"]
git-tree-sha1 = "acf614720ef026d38400b3817614c45882d75500"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.4"

[[deps.ImageDistances]]
deps = ["Distances", "ImageCore", "ImageMorphology", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "b1798a4a6b9aafb530f8f0c4a7b2eb5501e2f2a3"
uuid = "51556ac3-7006-55f5-8cb3-34580c88182d"
version = "0.2.16"

[[deps.ImageFiltering]]
deps = ["CatIndices", "ComputationalResources", "DataStructures", "FFTViews", "FFTW", "ImageBase", "ImageCore", "LinearAlgebra", "OffsetArrays", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "TiledIteration"]
git-tree-sha1 = "8b251ec0582187eff1ee5c0220501ef30a59d2f7"
uuid = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
version = "0.7.2"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "342f789fd041a55166764c351da1710db97ce0e0"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.6"

[[deps.ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils", "Libdl", "Pkg", "Random"]
git-tree-sha1 = "5bc1cb62e0c5f1005868358db0692c994c3a13c6"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.2.1"

[[deps.ImageMagick_jll]]
deps = ["Artifacts", "Ghostscript_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "124626988534986113cfd876e3093e4a03890f58"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.12+3"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "36cbaebed194b292590cba2593da27b34763804a"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.8"

[[deps.ImageMorphology]]
deps = ["ImageCore", "LinearAlgebra", "Requires", "TiledIteration"]
git-tree-sha1 = "e7c68ab3df4a75511ba33fc5d8d9098007b579a8"
uuid = "787d08f9-d448-5407-9aad-5290dd7ab264"
version = "0.3.2"

[[deps.ImageQualityIndexes]]
deps = ["ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "LazyModules", "OffsetArrays", "Statistics"]
git-tree-sha1 = "0c703732335a75e683aec7fdfc6d5d1ebd7c596f"
uuid = "2996bd0c-7a13-11e9-2da2-2f5ce47296a9"
version = "0.3.3"

[[deps.ImageSegmentation]]
deps = ["Clustering", "DataStructures", "Distances", "Graphs", "ImageCore", "ImageFiltering", "ImageMorphology", "LinearAlgebra", "MetaGraphs", "RegionTrees", "SimpleWeightedGraphs", "StaticArrays", "Statistics"]
git-tree-sha1 = "36832067ea220818d105d718527d6ed02385bf22"
uuid = "80713f31-8817-5129-9cf8-209ff8fb23e1"
version = "1.7.0"

[[deps.ImageShow]]
deps = ["Base64", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "b563cf9ae75a635592fc73d3eb78b86220e55bd8"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.6"

[[deps.ImageTransformations]]
deps = ["AxisAlgorithms", "ColorVectorSpace", "CoordinateTransformations", "ImageBase", "ImageCore", "Interpolations", "OffsetArrays", "Rotations", "StaticArrays"]
git-tree-sha1 = "8717482f4a2108c9358e5c3ca903d3a6113badc9"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.9.5"

[[deps.Images]]
deps = ["Base64", "FileIO", "Graphics", "ImageAxes", "ImageBase", "ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "ImageIO", "ImageMagick", "ImageMetadata", "ImageMorphology", "ImageQualityIndexes", "ImageSegmentation", "ImageShow", "ImageTransformations", "IndirectArrays", "IntegralArrays", "Random", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "StatsBase", "TiledIteration"]
git-tree-sha1 = "03d1301b7ec885b266c0f816f338368c6c0b81bd"
uuid = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
version = "0.25.2"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "87f7662e03a649cffa2e05bf19c303e168732d3e"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.2+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "5cd07aab533df5170988219191dfad0519391428"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.3"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.IntegralArrays]]
deps = ["ColorTypes", "FixedPointNumbers", "IntervalSets"]
git-tree-sha1 = "be8e690c3973443bec584db3346ddc904d4884eb"
uuid = "1d092043-8f09-5a30-832f-7509e371ab51"
version = "0.1.5"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "842dd89a6cb75e02e85fdd75c760cdc43f5d6863"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.14.6"

[[deps.IntervalSets]]
deps = ["Dates", "Random", "Statistics"]
git-tree-sha1 = "3f91cd3f56ea48d4d2a75c2a65455c5fc74fa347"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.3"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLD2]]
deps = ["FileIO", "MacroTools", "Mmap", "OrderedCollections", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "acb4be8227e1f3ff890d564d55dcde9cf92e4337"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.26"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "fd6f0cae36f42525567108a42c1c674af2ac620d"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.5"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "a77b273f1ddec645d1b7c4fd5fb98c8f90ad10a5"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.1"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b53380851c6e6664204efb2e62cd24fa5c47e4ba"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.2+0"

[[deps.Juno]]
deps = ["Base64", "Logging", "Media", "Profile"]
git-tree-sha1 = "07cb43290a840908a771552911a6274bc6c072c7"
uuid = "e5e0dc1b-0480-54bc-9374-aad01c23163d"
version = "0.8.4"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "9816b296736292a80b9a3200eb7fbb57aaa3917a"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.5"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "3eb79b0ca5764d4799c06699573fd8f533259713"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.4.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Loess]]
deps = ["Distances", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "46efcea75c890e5d820e670516dc156689851722"
uuid = "4345ca2d-374a-55d4-8d30-97f9976e7612"
version = "0.5.4"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "2ce8695e1e699b68702c03402672a69f54b8aca9"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.2.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "42324d08725e200c23d4dfb549e0d5d89dede2d2"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.10"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "Random", "Sockets"]
git-tree-sha1 = "03a9b9718f5682ecb107ac9f7308991db4ce395b"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[deps.Media]]
deps = ["MacroTools", "Test"]
git-tree-sha1 = "75a54abd10709c01f1b86b84ec225d26e840ed58"
uuid = "e89f7d12-3494-54d1-8411-f7d8b9ae1f27"
version = "0.5.0"

[[deps.Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

[[deps.MetaGraphs]]
deps = ["Graphs", "JLD2", "Random"]
git-tree-sha1 = "2af69ff3c024d13bde52b34a2a7d6887d4e7b438"
uuid = "626554b9-1ddb-594c-aa3c-2596fe9399a5"
version = "0.7.1"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "b34e3bc3ca7c94914418637cb10cc4d1d80d877d"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.3"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "a7c3d1da1189a1c2fe843a3bfa04d18d20eb3211"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.0.1"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "440165bf08bc500b8fe4a7be2dc83271a00c0716"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.12"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.NewsvendorModel]]
deps = ["Distributions", "Printf", "QuadGK"]
git-tree-sha1 = "73aafd452d06c8be9cb5d279714b6f2f5871e6c8"
uuid = "63d3702b-073a-45e6-b43c-f47e8b08b809"
version = "0.2.2"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "f71d8950b724e9ff6110fc948dff5a329f901d64"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.12.8"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "327f53360fdb54df7ecd01e96ef1983536d1e633"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.2"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "923319661e9a22712f24596ce81c54fc0366f304"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.1.1+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "cf494dca75a69712a72b80bc48f59dcf3dea63ec"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.16"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "f809158b27eba0c18c269cf2a2be6ed751d3e81d"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.17"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "03a7a85b76381a3d04c7a1656039197e70eda03d"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.11"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "cceb0257b662528ecdf0b4b4302eb00e767b38e7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f6cf8e7944e50901594838951729a1861e668cb8"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.2"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "98ac42c9127667c2731072464fcfef9b819ce2fa"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "d7a7aef8f8f2d537104f170139553b14dfe39fe9"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.7.2"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "18e8f4d1426e965c7b532ddd260599e1510d26ce"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "97aa253e65b784fd13e83774cadc95b38011d734"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.6.0"

[[deps.Quaternions]]
deps = ["LinearAlgebra", "Random"]
git-tree-sha1 = "fcebf40de9a04c58da5073ec09c1c1e95944c79b"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.6.1"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "dc84268fe0e3335a62e315a3a7cf2afa7178a734"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.3"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RegionTrees]]
deps = ["IterTools", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "4618ed0da7a251c7f92e869ae1a19c74a7d2a7f9"
uuid = "dee08c22-ab7f-5625-9660-a9af2021b33f"
version = "0.3.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[deps.Rotations]]
deps = ["LinearAlgebra", "Quaternions", "Random", "StaticArrays", "Statistics"]
git-tree-sha1 = "793b6ef92f9e96167ddbbd2d9685009e200eb84f"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.3.3"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.ShortCodes]]
deps = ["Base64", "CodecZlib", "HTTP", "JSON3", "Memoize", "UUIDs"]
git-tree-sha1 = "0fcc38215160e0a964e9b0f0c25dcca3b2112ad1"
uuid = "f62ebe17-55c5-4640-972f-b59c0dd11ccf"
version = "0.3.3"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays", "Test"]
git-tree-sha1 = "a6f404cc44d3d3b28c793ec0eb59af709d827e4e"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.2.1"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "8fb59825be681d451c246a795117f317ecbcaa28"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.2"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "StaticArraysCore", "Statistics"]
git-tree-sha1 = "f86b3a049e5d05227b10e15dbb315c5b90f14988"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.5.9"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6b7ba252635a5eff6a0b0664a41ee140a1c9e72a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.0"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "f9af7f195fb13589dd2e2d57fdb401717d2eb1f6"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.5.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "d1bf48bfcc554a3761a133fe3a9bb01488e06916"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.21"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "HypergeometricFunctions", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5783b877201a82fc0014cbf381e7e6eb130473a4"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.0.1"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "ca4bccb03acf9faaf4137a9abc1881ed1841aa70"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.10.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "70e6d2da9210371c927176cb7a56d41ef1260db7"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.6.1"

[[deps.TiledIteration]]
deps = ["OffsetArrays"]
git-tree-sha1 = "5683455224ba92ef59db72d10690690f4a8dc297"
uuid = "06e1c1a7-607b-532d-9fad-de7d9aa2abac"
version = "0.3.1"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "libpng_jll"]
git-tree-sha1 = "d4f63314c8aa1e48cd22aa0c17ed76cd1ae48c3c"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.3+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╟─a7d494b4-8fb7-47f2-b06e-55ebf3f36690
# ╟─dc1d2ab3-49bc-4692-ad57-670697459552
# ╟─2b672651-530b-4337-87b3-a76e2fbe1de5
# ╟─2cfc08fe-3422-4d3b-86c6-38ad59be93a0
# ╟─fea06a1c-6026-4169-baf4-889f9af42798
# ╟─f7987a00-fcd2-4237-8812-573eb84c9913
# ╟─5950833a-9ece-4c0e-a603-f5ad165bcc6b
# ╟─1080cbab-e04f-4d2d-b6f3-33e8c5e7878f
# ╟─c2bb52a3-6a8a-46f2-98df-af7cb9aecdfc
# ╟─2d66e877-ddd9-41ef-b231-de6a41dc9eaa
# ╟─52902751-b61f-4d1a-9c25-ac219f538528
# ╟─5724d527-7160-46a7-8599-b8c970366ab7
# ╟─f408f533-e1d8-4d1d-a79a-976602c559f0
# ╟─b4f738e6-781a-4e80-9892-3a12680ddfbb
# ╟─90943ce5-bfdb-48b7-beb1-6e7d39222e48
# ╟─3e4a8171-a439-4f29-8c59-611fb9e19a86
# ╟─356cb7b4-addf-4826-98da-f9610b51f221
# ╟─a4dc0bec-7bda-4609-828b-46da3e3906f3
# ╟─eddefff7-b3e5-4361-ba6f-4a89dfd67cb3
# ╟─9787d683-eb06-48d5-917b-96c51bfa37a7
# ╟─b8bba9cb-6714-44ba-945a-85990e8207bc
# ╟─b0df24a1-480b-4d1f-9272-68403f75bd07
# ╟─066e292c-8fcb-40fc-abc2-e9256dae01bd
# ╟─f2865ca5-ce36-4e6d-b3a0-35d354ef63bd
# ╟─dbc89555-bed9-4315-93b8-f8ffdcf9328f
# ╟─6d7a6303-55cb-4380-b044-e8503b257b47
# ╟─d4e98cf5-3a4b-4574-a582-9b44cf4c0e99
# ╟─9bab1c8f-560c-4b03-acb1-e2ad478ed1ad
# ╟─bbb71ed6-f9ca-41b6-b626-8cc88d7dd518
# ╟─8eec208a-817f-4df6-bccb-44c6f03f7f67
# ╟─f0791331-7272-483f-b20c-42731acd7d1e
# ╟─5c70225e-711f-4af3-b483-92b534a9f296
# ╟─976c24ca-aceb-4ded-9a21-048994e356a9
# ╟─fed529bd-dfd6-4314-9035-00bd6f54fc20
# ╟─02c37c81-dbbb-48b5-a75f-d58ee354baa9
# ╟─132f9155-d296-44d7-bb63-a84528455ae0
# ╟─8989f06f-cff4-4294-98d6-536bb46ed246
# ╟─6e648e01-7b29-4d0e-a637-54c2a2bddef7
# ╟─4108e505-a66a-403d-ae5d-aadce5058a99
# ╟─1c9428db-b2ce-4069-a018-55a45cc8026f
# ╟─1f1f72b4-abc8-443a-83db-578f797506e5
# ╟─a38416f3-2c4b-4e0f-95e2-424c9cd9ad52
# ╟─a5331fcf-1463-44f4-9343-4cca0f14aee0
# ╟─be78d60c-50e0-4a41-bbcb-dda259f46438
# ╟─7f6e17dd-55a2-4d01-9bb4-ad045dcdff4c
# ╟─68359905-a06b-4a40-959b-cfa7dbd3788b
# ╟─4d8d73b3-2977-46fb-afe6-3972f3e8d752
# ╟─b84291fe-1432-4357-9d77-cab8e3229ee1
# ╟─57a99799-10aa-4fd3-be58-fd5b298355ba
# ╟─b8bd59de-5ef5-4da8-99ac-96dcc36b7b0c
# ╟─e7e4f425-f6b8-450e-92e6-a71ad0a2b904
# ╟─7a2e8ed8-24c8-41d9-a3ed-e38f96b0e172
# ╟─e4565d5b-3d19-4337-919e-d8fe27990f95
# ╟─2c9271b2-c3e3-498a-9958-e4bc5d0faf2d
# ╟─f93fe5d6-126c-48cf-9127-bb29849f3ae1
# ╟─76565946-55d5-4cb4-aaf0-e41d128a663c
# ╟─08c4d7e6-85ae-4b53-80ed-3a64bb216551
# ╟─64fe5c24-2d87-4e95-9530-d18fd83049af
# ╟─2f0655ad-b3a6-4dd7-881b-998c511b5650
# ╟─e37d4f2d-1b60-4832-83e4-d9bcd4b4aa01
# ╟─a6b5030b-b742-456c-b0ae-607b4bb58cd4
# ╟─9de794aa-3069-4ffc-9ebc-e655b4279a4b
# ╟─cc37aec2-3a40-4e4a-8df8-9075ae471440
# ╟─6a7a9a80-d414-4569-82be-04f2c0b44e73
# ╟─cfaa0a34-2218-4899-bb2d-ee1d7d068938
# ╟─9ba19506-9cd0-4a6f-a966-db2e94845f72
# ╟─523e474d-2da8-4e20-855d-30690bbbad38
# ╟─9909e1ea-76e3-4f6d-95c9-6203897851cc
# ╟─4e7d30ba-fb9e-4848-8fb6-8e388e8a8447
# ╟─44d1507d-5cc4-420e-86f9-4acd018cf488
# ╟─93501b5a-0862-4f34-9bc5-77589f7f0bdd
# ╟─32736a2e-3af8-4447-b723-f461a0543cc3
# ╟─7c186c55-dbd0-41d6-b2b6-1ab7552a18f1
# ╟─5c9ce442-0f58-4ce5-9742-fd1f98aa8a64
# ╟─8aa57969-9116-4eb3-a1cf-e54ddaa00162
# ╟─69f073e7-2d57-4539-ae5a-17b64b532906
# ╟─c0232e07-7fe9-4358-a162-3bf01939063e
# ╟─e16cb65f-1083-420e-a0d0-3dcbf2faa41c
# ╟─0d2f0256-1e28-47e0-88bd-43a8e47e1f41
# ╟─a3658128-3822-42c5-ab47-13338cef4f91
# ╟─4c51ede4-cb91-4b45-84cb-e629244c4ac3
# ╟─627d4b10-6878-4631-843e-ab55de368815
# ╟─5d4fd167-1392-4af0-ba76-5e724cc08154
# ╟─99e4abb4-9b49-4542-a8c7-3b8ac5a620bd
# ╟─c38fe6d4-f4bf-4af3-bfc4-f3f63f005851
# ╟─aaf76732-a964-4e0b-8ed9-d38bb0d985e5
# ╟─7ad97285-5bd1-4c4a-89d2-a722ba89ada4
# ╟─25c97465-989e-4ef4-9e42-4c4026be37bd
# ╟─d40b29d6-9254-4b7c-abfe-cfa276da7e8c
# ╟─eb03e796-4b3d-49e9-9dc6-02b325940355
# ╟─34b7fa8d-7ba2-4c7e-b832-0a5ab24d0175
# ╟─73b3e6e7-cf58-4b82-a68f-302dd997887e
# ╟─f7f26892-8999-4236-aa5f-dba4add232e6
# ╟─928e6d59-b54f-496f-adb7-a078ba9d68c3
# ╟─af0c80a7-09b6-45f5-a379-a2a0cdea20a1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
