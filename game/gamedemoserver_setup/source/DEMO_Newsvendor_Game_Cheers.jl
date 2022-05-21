### A Pluto.jl notebook ###
# v0.19.4

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
# using PlutoUI, Plots, Distributions, Parameters, QuadGK, OrderedCollections, DataFrames;


begin
 #    import Pkg
 #    Pkg.activate(mktempdir())
	# Pkg.add(["JSON3","Tables"])
 #    Pkg.add([
 #        Pkg.PackageSpec(name="Plots", version="1.22.1"),
 #        Pkg.PackageSpec(name="PlutoUI", version="0.7.16"),
 #        Pkg.PackageSpec(name="Distributions", version="0.25.16"),
 #        Pkg.PackageSpec(name="QuadGK"),
 #        Pkg.PackageSpec(name="OrderedCollections", version="1.4.1"),  
 #        Pkg.PackageSpec(name="Configurations"),    
 #    ])
    using Pluto
	using PlutoUI, Plots, Distributions, QuadGK, OrderedCollections
	using JSON3
	using Tables
	using Configurations
	# using JLD2
	import TOML
end;

# ╔═╡ dc1d2ab3-49bc-4692-ad57-670697459552
md"""
## The Simulation

#### Your Task...
is to make a decsion at the begining of each round: How many units do you want to stock for this round?

#### Your Goal...
is to maximize your profit.
"""		

# ╔═╡ 5950833a-9ece-4c0e-a603-f5ad165bcc6b
md"## Let's Go!"

# ╔═╡ b7f28c45-0434-4d88-88b5-c525c8ea037b
md"""
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

# ╔═╡ 64fe5c24-2d87-4e95-9530-d18fd83049af
function is_sim_running(qs, scenario::Scenario)
	length(qs) < scenario.max_num_days
end;

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
end; 

# ╔═╡ 8aa57969-9116-4eb3-a1cf-e54ddaa00162
function update_plot_panel_1(sim_data::SimData)
	sd = sim_data
	
	scatter(sd.sales,  label="Sales", markerstrokewidth=3.5,c=:white, markersize=7,  markerstrokecolor = 3, bar_width=sd.days_played*0.01)	

	scatter!(sd.demands[1:sd.days_played], label = "Demanded", c = 1, msw = 0, 
		xlabel = "Day", xticks=1:sd.days_played, xrotation=60, size=(700, 450),
		right_margin=-8Plots.mm)
	plot!(sd.demands[1:sd.days_played], lw=1, ls=:dash, label="", c = 1)

	# plot!([sd.avg_demand], seriestype="hline", 
	# 	c=1,lw=2,ls=:dot,label="Observed\naverage\ndemand\n($(my_round(sd.avg_demand)))")

	scatter!(sd.qs, label = "You stocked", c = 2,  msw = 0)
	plot!(sd.qs, lw=1, ls=:dash, label="", c = 2, legend = :outerright)

	# plot!([sd.avg_q], seriestype="hline", 
	# 	c=2,lw=2, ls=:dot,label="Your average\ndecision ($(my_round(sd.avg_q)))")
		

end;

# ╔═╡ 69f073e7-2d57-4539-ae5a-17b64b532906
function update_plot_panel_2(sd::SimData)
	
	days = 1:sd.days_played
	bar(days, sd.revenues, label="Revenue", lw=0,  c = :green, fillalpha = 0.61, bar_width=0.17, 
		size=(750, 150), xticks=days, xrotation=60, legend=:outerright)
	bar!(days.+0.17, sd.profits, label="Profit", lw=0,c = 5, fillalpha = 0.95, bar_width=0.17,)
	bar!(days, 0 .- sd.costs, label="Cost", lw=0,c = 2, fillalpha = 0.81, bar_width=0.17, )
	plot!(x->0, label="",  c = :black, left_margin=-2Plots.mm, right_margin=-6Plots.mm, bottom_margin=2Plots.mm)
end;

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
end;

# ╔═╡ 4c51ede4-cb91-4b45-84cb-e629244c4ac3
function show_scenario_data_4(scenario::Scenario)
	sc = scenario

	plt_econ = bar([1], [sc.s], size=(400,200),
		orientation=:h, yaxis=false,yticks=nothing, c = :grey, alpha=.3, legend=false)	
	bar!([2], [sc.c], orientation=:h, c = :red, alpha=.3, legend=false)
	bar!([3], [sc.p], orientation=:h, c = :green, alpha=.3, legend=false)
	annotate!(0.02*sc.p, 3, "Unit Selling Price", :left)
	annotate!(0.02*sc.p, 2, "Unit Cost", :left)
	annotate!(0.02*sc.p, 1, "Unit Salvage Value", :left)
end;

# ╔═╡ 9909e1ea-76e3-4f6d-95c9-6203897851cc
# L(x) = ∫ₓᵘ (y - x)f(y)dy
function L(f, x, u)
	L, _ = quadgk(y -> (y - x) * f(y), x, u, rtol=1e-8)
	return L
end;

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
end; 

# ╔═╡ cfaa0a34-2218-4899-bb2d-ee1d7d068938
function my_round(x::Real; sigdigits::Int=3)
	x = round(x, sigdigits=sigdigits)
	if x >= 10^(sigdigits-1)
		Int(x)
	else
		x
	end
end; 

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
end; md""

# ╔═╡ e16cb65f-1083-420e-a0d0-3dcbf2faa41c
function show_scenario_data_1(scenario::Scenario)
	sc = scenario

	md"""
	#### Information Abouth The Demand	
	* Customer **demand is uncertain** and will be **between $(sc.l) and $(sc.u)** every day. 
	* Independent of the demand of the previous day, you **expect μ = $(my_round(sc.μ))** and face uncertainty captured by a standard deviation of **σ = $(my_round(sc.σ))**. The distribution is shown in the figure below.
	"""
end;

# ╔═╡ a6b5030b-b742-456c-b0ae-607b4bb58cd4
my_ID() = replace(replace(@__FILE__, r".jl.*" => ""), r".*/" => "");

# ╔═╡ af0c80a7-09b6-45f5-a379-a2a0cdea20a1
function data_table(table)
	d = Dict(
        "headers" => [Dict("text" => string(name), "value" => string(name)) for name in Tables.columnnames(table)],
        "data" => [Dict(string(name) => row[name] for name in Tables.columnnames(table)) for row in Tables.rows(table)]
    )
	djson = JSON3.write(d)
	
	return HTML("""
		<link href="https://cdn.jsdelivr.net/npm/@mdi/font@5.x/css/materialdesignicons.min.css" rel="stylesheet">


	  <div id="app">
		<v-app>
		  <v-data-table
		  :headers="headers"
		  :items="data"
		></v-data-table>
		</v-app>
	  </div>

	  <script src="https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js"></script>
	  <script src="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.js"></script>
	
	<script>
		new Vue({
		  el: '#app',
		  vuetify: new Vuetify(),
		  data () {
				return $djson
			}
		})
	</script>
	<style>
		.v-application--wrap {
			min-height: 10vh;
		}
		.v-data-footer__select {
			display: none;
		}
	</style>
	""")
end;

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
		data_table(T)
	else
		return md""
	end
end; md""

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
				sum(pdf(TruncatedNormal(90, 30, 0, 180), 1:180))  for x in 1:180]
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
		logfile = "simlog_" * my_ID()
	end
end;

# ╔═╡ 93501b5a-0862-4f34-9bc5-77589f7f0bdd
function update_submission_and_result_panel(sim_data)
	sd = sim_data
	
	if sd.days_played > 0 && sd.days_played < sd.scenario.max_num_days
md" ##### 👉 How much do you want to stock for day $(sd.days_played+1)?"
	elseif sd.days_played == sd.scenario.max_num_days 
				
md"""
!!! tip "You came to the end of the simulation." 
	👍 Great job!
	
	Scroll down to find a comparison of your result with alternative strategies.
 
	"""
	else
md" ##### 👉 How much do you want to stock for day $(sd.days_played+1)?"
	end
end; 

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
end; 

# ╔═╡ 0d2f0256-1e28-47e0-88bd-43a8e47e1f41
function show_scenario_data_2(scenario::Scenario)
	sc = scenario
	
	
	plt_dem = plot(left_margin = 15Plots.mm, label="cdf", xlabel="Daily Demand", 
				ylabel="Likelihood", yaxis=nothing, legend=false,
				xlims=(sc.l-(sc.u-sc.l)/6,sc.u+(sc.u-sc.l)/6))
	
	if typeof(sc.distr)==DiscreteNonParametric{Int64, Float64, Vector{Int64}, Vector{Float64}}
		xs = params(sc.distr)[1]
		bar!(plt_dem, sc.l:sc.u, pdf(sc.distr,sc.l:sc.u), c=1,  lw=0, bar_width=(xs[end]-xs[1])/20)
		plot!(plt_dem, yaxis=0:.1:1,ylims=(0,1), xaxis=xs)
	else
		plot!(plt_dem, sc.l:sc.u, pdf(sc.distr,sc.l:sc.u), fillrange=(x->0),c=1, fillalpha=0.81,lw=0)
		plot!(plt_dem, sc.l:sc.u, pdf(sc.distr,sc.l:sc.u), c=4,  lw=3)
		plot!(plt_dem, sc.l-(sc.u-sc.l)/5:sc.l, x->0, lw=3, c=4)
		plot!(plt_dem, sc.u:sc.u+(sc.u-sc.l)/5, x->0, lw=3, c=4)
		vline!([sc.μ], c=:white)
		annotate!(0.9*sc.μ, pdf(sc.distr,sc.μ)/10, Plots.text("μ = $(my_round(sc.μ))", 10, :white, :left, rotation = 90), size=(400,200))

	end
	
end;

# ╔═╡ 523e474d-2da8-4e20-855d-30690bbbad38
function compute_expected_values(qs::Vector{<:Number}, scenario::Scenario) 
	n_days = length(qs)
	if n_days == 0 return zeros(1,4) end

	expected_values = Matrix{Number}(undef, n_days, 4)

	for i in 1:n_days
		expected_values[i,:] = compute_expected_values(qs[i], scenario) 
	end

	return mean(expected_values, dims=1)
end; 

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
	
end; 

# ╔═╡ 627d4b10-6878-4631-843e-ab55de368815
function result_figures(sim_data::SimData) 

	sd = sim_data
	sc = sd.scenario
	
	sftsz = 11
	lftsz = 13
	
	plt = plot()
	
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
	results["The strategy\nthat maximizes\nexpected profit,\nie if Service Level\n= Critical Fractile"] = opt_data
	
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
	
	# descriptions
	description_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
			palette=:lightrainbow, ylabel = "Strategy")
	x_loc = 0
	for (description, _) in results
		bar!([x_loc], [1], alpha=.3)
		annotate!(x_loc, 0.5, text(description, sftsz))
		x_loc = x_loc + 1
	end	
	
	# comparing profits
	profit_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
			palette=:lightrainbow, ylabel = "Average Profit")
	x_loc = 0
	for (description, data) in results
		y = my_round(data.avg_profit)
		bar!([x_loc], [y], alpha=.3)	
		annotate!(x_loc, y, text("$(my_round(y))", lftsz,:bottom))
		x_loc = x_loc + 1
	end
	
	# comparing sales
	sale_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
			palette=:lightrainbow, ylabel = "Avg. Sales")
	x_loc = 0
	for (description, data) in results
		y = data.avg_sale
		bar!([x_loc], [y], alpha=.3)
		annotate!(x_loc, y, text("$(my_round(y))", lftsz,:bottom))
		x_loc = x_loc + 1
	end
	
	# comparing left over
	left_over_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
			palette=:lightrainbow, ylabel="Avg. Left Over")
	for (description, data) in results
		y =  my_round(data.avg_left_over)
		bar!([x_loc], [y], alpha=.3)
		annotate!(x_loc, y, text("$(my_round(y))", lftsz,:bottom))
		x_loc = x_loc + 1
	end	
	
	# comparing lost sales
	lost_sale_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
			palette=:lightrainbow, ylabel="Avg. Lost Sales")
	for (description, data) in results
			y =  data.avg_lost_sale
			bar!([x_loc], [y], alpha=.3)
		annotate!(x_loc, y, text("$(my_round(y))", lftsz,:bottom))
		x_loc = x_loc + 1
	end	
	
	# comparing expected profit
	exp_profit_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
		yguidefontcolor=:grey,	palette=:lightrainbow, ylabel="Expected Avg. Profit\n(if we play forever)")
	for (description, data) in results
		y = data.expected_profits
		bar!([x_loc], [y], alpha=.13)
		annotate!(x_loc, y, text("$(my_round(y))", :grey, lftsz,:bottom))
		x_loc = x_loc + 1
	end	
	
	# comparing expected sales
	exp_sales_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
		yguidefontcolor=:grey,	palette=:lightrainbow, ylabel="Expected Avg. Sales\n(if we play forever)")
	for (description, data) in results
		y = data.expected_sales
		bar!([x_loc], [y], alpha=.13)
		annotate!(x_loc, y, text("$(my_round(y))", :grey, lftsz,:bottom))
		x_loc = x_loc + 1
	end	
	
	# comparing expected leftover inventory
	exp_left_over_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
		yguidefontcolor=:grey,	palette=:lightrainbow, ylabel="Exp. Avg. Left Over \n(if we play forever)")
	for (description, data) in results
		y = data.expected_left_overs
		bar!([x_loc], [y], alpha=.13)
		annotate!(x_loc, y, text("$(my_round(y))", :grey, lftsz,:bottom))
		x_loc = x_loc + 1
	end	
	
	# comparing expected lost sales
	exp_lost_sale_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
		yguidefontcolor=:grey,	palette=:lightrainbow, ylabel="Exp. Avg. Lost Sales\n(if we play forever)")
	for (description, data) in results
		y = data.expected_lost_sales
		bar!([x_loc], [y], alpha=.13)
		annotate!(x_loc, y, text("$(my_round(y))", :grey, lftsz,:bottom))
		x_loc = x_loc + 1
	end	
		
	description_height = 0.06
	profit_height = 0.14
	other_height = 0.11
	heights = [description_height, profit_height,other_height,other_height,other_height, profit_height,other_height,other_height,other_height]
		
	plt = plot(description_plt, profit_plt, sale_plt, left_over_plt, lost_sale_plt,
		exp_profit_plt, exp_sales_plt, exp_left_over_plt, exp_lost_sale_plt, ylabelfontsize=13,	layout = grid(9, 1, heights=heights), size=(820, 2000), bottom_margin=3Plots.mm, top_margin=5Plots.mm, right_margin=-8Plots.mm, left_margin=12Plots.mm)
end;  

# ╔═╡ c0232e07-7fe9-4358-a162-3bf01939063e
function update_result_figures_panel(sd::SimData)
	if sd.days_played == sd.scenario.max_num_days
		result_figures(sd) 
	else
		md""
	end	
end; 

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
end;

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
end;

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
						max_num_days=30,
						allow_reset=true,
						title="Patisserie Cheers! (II)", 
						story_url="https://git.io/Jz5DB")
			
		cheers_3 = Scenario(name="cheers_3",
						u=180, σ=30, c=1.5, p=9, s=0.5, 
						delay=50, max_num_days=30,
						allow_reset=true,
						title="Patisserie Cheers! (III)", 
						story_url="https://git.io/J2yGL")
		
		cheers_4 = Scenario(name="cheers_4",
						l=0, u=2, c=10, p=42, 
						distr=DiscreteNonParametric([0, 1, 2], [.3, .5, .2]),
						μ = mean(DiscreteNonParametric([0, 1, 2], [.3, .5, .2])),
						σ = sqrt(var(DiscreteNonParametric([0, 1, 2], [.3, .5, .2]))),
						delay=50, max_num_days=30,
						allow_reset=true,
						title="Patisserie Cheers! (IV)", 
						story_url="https://git.io/JK8J7")


	
		available_scenarios = [cheers_1]
	end
		
	# save_available_scenario_conf()
	
end;

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
	
	scenarios_to_be_reset = resetables
	md"""
!!! warning "Note that the server will reset this DEMO site every 10 minutes."
	
	"""
# 	if length(resetables) > 0
# md"""
# ## Reset

# $(@bind reset CounterButton("Reset previous play"))
# """
# 	else
# 		md""
# 	end
end

# ╔═╡ eddefff7-b3e5-4361-ba6f-4a89dfd67cb3
# refer to predefined scenarios to offer a selection
begin 
	chosen_scenario = available_scenarios[1].name
	md""
# 	if length(available_scenarios) > 1
		
		
# md"""
# # ⏭ Continue with a Different Scenario
		
# You can choose among $(length(available_scenarios)) different scenarios: 
# $(@bind chosen_scenario HTML("<select>"*
# join(["<option value='"*scenario.name*"'>"*scenario.title*"</option>" for scenario in available_scenarios])* "</select>") )🚪🏃‍"""
# 	end
end

# ╔═╡ 68359905-a06b-4a40-959b-cfa7dbd3788b
# if isfile(get_logfile() * ".jld2")
	# sim_datas = load(get_logfile() * ".jld2", "sim_datas")		

# else
begin
	sim_datas = Dict{String, SimData}()		
		
	# initiate the simulation for each scenario	
	for scenario in available_scenarios
		sim_datas[scenario.name] =  SimData(scenario=scenario, 
									 		 demands=round.(Int, rand(scenario.distr, 
															scenario.max_num_days))
									)
	end
end; 	md""

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
	
end; 

# ╔═╡ 2c9271b2-c3e3-498a-9958-e4bc5d0faf2d
begin 
	reset;
	if typeof(chosen_scenario) == Missing
		sim_data = sim_datas[available_scenarios[1].name]
	else
		sim_data = sim_datas[chosen_scenario]
	end
	cluttered_history = [-1.0]; 
	md""
end

# ╔═╡ a7d494b4-8fb7-47f2-b06e-55ebf3f36690
if sim_data.scenario.story_url != ""	
	story_file = download(sim_data.scenario.story_url)
	Markdown.parse_file(story_file)
else
	Markdown.parse(sim_data.scenario.story)
end

# ╔═╡ 2b672651-530b-4337-87b3-a76e2fbe1de5
show_scenario_data_1(sim_data.scenario)

# ╔═╡ 2cfc08fe-3422-4d3b-86c6-38ad59be93a0
show_scenario_data_2(sim_data.scenario)

# ╔═╡ fea06a1c-6026-4169-baf4-889f9af42798
show_scenario_data_3(sim_data.scenario)

# ╔═╡ f7987a00-fcd2-4237-8812-573eb84c9913
show_scenario_data_4(sim_data.scenario)

# ╔═╡ c2bb52a3-6a8a-46f2-98df-af7cb9aecdfc
begin
	sim_data.days_played	
	md"""
	$(@bind q NumberField(0:500, default=0))
	$(@bind submit_counter_button CounterButton("Submit")) *(Please reload the webpage if the submit button does not work.)*
	"""
end

# ╔═╡ e7e4f425-f6b8-450e-92e6-a71ad0a2b904
sim_data.days_played; initial_difference = Vector{Int}();

# ╔═╡ 7a2e8ed8-24c8-41d9-a3ed-e38f96b0e172
if submit_counter_button == 1 && sim_data.days_played != 0
	initial_difference[1] = sim_data.days_played - 1
end

# ╔═╡ e4565d5b-3d19-4337-919e-d8fe27990f95
begin
	if typeof(submit_counter_button) != String
		push!(initial_difference, submit_counter_button-sim_data.days_played)
		submit_count = 	initial_difference[1] + submit_counter_button
	else
		submit_count = 0
	end
	md""
end

# ╔═╡ 4108e505-a66a-403d-ae5d-aadce5058a99
function simlog_to_simdata(simlog)
	sd = SimData(				
		scenario = scenariolog_to_scenario(simlog.scenario),
		demands = simlog.play.demands,
		qs =  simlog.play.qs,
	)
	update_sim_data!(sd)
	return sd
end;

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
						sum(pdf(sc.distr, sc.l:sc.u))  for i in 1:length(sc.l:sc.u)]
	
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
end;

# ╔═╡ 928e6d59-b54f-496f-adb7-a078ba9d68c3
function save_available_scenario_conf(available_scenarios=available_scenarios, path="")	
	d = Dict([sc.name => sc.name*"_conf.toml"  for sc in available_scenarios])
	
	open(path*"available_scenario_confs.toml", "w") do io
		TOML.print(to_toml, io, d)
	end
	
	for sc in available_scenarios
		to_toml(path*sc.name*"_conf.toml", sc |> scenario_to_scenariolog)
	end
end;

# ╔═╡ 1f1f72b4-abc8-443a-83db-578f797506e5
function simdata_to_simlog(simdata) 
	playlog = from_kwargs(PlayLog, qs = simdata.qs, demands = simdata.demands)
	scl = scenario_to_scenariolog(simdata.scenario)
	
	return SimLog(play = playlog, scenario = scl)
end;

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
	
end;

# ╔═╡ f93fe5d6-126c-48cf-9127-bb29849f3ae1
begin
	# This cell runs if a decision is submitted 
	# or if the content =q_new of the form was touched 
	# Then, the cluttered_history is enriched
	# If the content of is not empty we update qs
		
	# submit_decision
	
	# if typeof(q_new) == Int 
	# 	push!(cluttered_history, q_new)
	# else
	# 	push!(cluttered_history, NaN)
	# end
	
	# if typeof(q_new) == Int  && is_sim_running(sim_data.qs, sim_data.scenario)
		
	# # If q_new changes or a number is submitted, it's added to cluttered_history 
	# # => if user submits, the last two elements in cluttered_history are the same 
	# # Then, we notice the order
	# 	if cluttered_history[end] == cluttered_history[end-1]
	# 		push!(sim_data.qs, cluttered_history[end] )
	# 		update_sim_data!(sim_data)
	# 	end
	# end


	

	# Cell is triggered if player submits a quantity q
	# if sim is running, q is added to qs
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
	
end; md""

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
	save_simlogs(get_logfile(), my_ID(), sim_datas);	
end; precompile();

# ╔═╡ aaf76732-a964-4e0b-8ed9-d38bb0d985e5
if false
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
else
	html"""
	<style>

	@import url('https://fonts.googleapis.com/css2?family=Josefin+Sans:ital,wght@1,300&family=Lexend+Deca:wght@350&display=swap');



	pluto-output {
	font-family: 'Lexend Deca', sans-serif;
	}
	pluto-output h1, pluto-output h2, pluto-output h3, pluto-output h4, pluto-output h5, pluto-output h6 {                                                         font-family: 'Josefin Sans', sans-serif;
                   
	}
	</style>
	"""
end

# ╔═╡ 25c97465-989e-4ef4-9e42-4c4026be37bd
md"""*Did you know?* Using the the key combo ` ⊞ Win` + `.` in Windows (`⌘` + `Ctrl` + `Space` in Mac OS) opens the smiley keyboard and you can "make" as many 🎂🍰🧁 as you want."""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Configurations = "5218b696-f38b-4ac9-8b61-a12ec717816d"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
OrderedCollections = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
Pluto = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
QuadGK = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
TOML = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[compat]
Configurations = "~0.17.0"
Distributions = "~0.25.29"
JSON3 = "~1.9.2"
OrderedCollections = "~1.4.1"
Plots = "~1.23.6"
Pluto = "~0.14.2"
PlutoUI = "~0.7.19"
QuadGK = "~2.4.2"
Tables = "~1.6.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "0bc60e3006ad95b4bb7497698dd7c6d649b9bc06"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.1"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "f885e7e7c124f8c92650d61b9477b9ac2ee607dd"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.1"

[[ChangesOfVariables]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "9a1d594397670492219635b35a3d830b04730d62"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.1"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Configurations]]
deps = ["ExproniconLite", "OrderedCollections", "TOML"]
git-tree-sha1 = "b0dcafb34cfff977df79fc9927b70a9157a702ad"
uuid = "5218b696-f38b-4ac9-8b61-a12ec717816d"
version = "0.17.0"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[DensityInterface]]
deps = ["InverseFunctions", "Test"]
git-tree-sha1 = "794daf62dce7df839b8ed446fc59c68db4b5182f"
uuid = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
version = "0.3.3"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "DensityInterface", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns", "Test"]
git-tree-sha1 = "cce8159f0fee1281335a04bbf876572e46c921ba"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.29"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[ExproniconLite]]
git-tree-sha1 = "8b08cc88844e4d01db5a2405a08e9178e19e479e"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.6.13"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "8756f9935b7ccc9064c6eef0bff0ad643df733a3"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.12.7"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[FuzzyCompletions]]
deps = ["REPL"]
git-tree-sha1 = "2cc2791b324e8ed387a91d7226d17be754e9de61"
uuid = "fb4132e2-a121-4a70-b8a1-d5b831dcdcc2"
version = "0.4.3"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "30f2b340c2fff8410d89bfcdc9c0a6dd661ac5f7"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.62.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "fd75fa3a2080109a2c0ec9864a6e14c60cca3866"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.62.0+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "14eece7a3308b4d8be910e265c724a6ba51a9798"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.16"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "05110a2ab1fc5f932622ffea2a003221f4782c18"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.3.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JSON3]]
deps = ["Dates", "Mmap", "Parsers", "StructTypes", "UUIDs"]
git-tree-sha1 = "7d58534ffb62cd947950b3aa9b993e63307a6125"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "c9551dd26e31ab17b86cbd00c2ede019c08758eb"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+1"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "be9eef9f9d78cecb6f262f3c10da151a6c5ab827"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[MsgPack]]
deps = ["Serialization"]
git-tree-sha1 = "a8cbf066b54d793b9a48c5daa5d586cf2b5bd43d"
uuid = "99f44e22-a591-53d1-9472-aa23ef4bd671"
version = "1.1.0"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "86a37fba91f9fb5bbc5207e9458a5b831dfebb6b"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.4"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "b084324b4af5a438cd63619fd006614b3b20b87b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.15"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun"]
git-tree-sha1 = "0d185e8c33401084cab546a756b387b15f76720c"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.23.6"

[[Pluto]]
deps = ["Base64", "Dates", "Distributed", "FuzzyCompletions", "HTTP", "InteractiveUtils", "Logging", "Markdown", "MsgPack", "Pkg", "REPL", "Sockets", "TableIOInterface", "Tables", "UUIDs"]
git-tree-sha1 = "7764c0ad79718a5e5f684b68db7cb069fb60b909"
uuid = "c3e4b0f8-55cb-11ea-2926-15256bba5781"
version = "0.14.2"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "e071adf21e165ea0d904b595544a8e514c8bb42c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.19"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

[[QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "44a75aa7a527910ee3d1751d1f0e4148698add9e"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.1.2"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "bf3188feca147ce108c76ad82c2792c57abe7b1f"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.7.0"

[[Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "68db32dff12bb6127bac73c209881191bf0efbb7"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.3.0+0"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "f0bccf98e16759818ffc5d97ac3ebf87eb950150"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.1"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "1958272568dc176a1d881acb797beb909c785510"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.0.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "eb35dcc66558b2dda84079b9a1be17557d32091a"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.12"

[[StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "385ab64e64e79f0cd7cfcf897169b91ebbb2d6c8"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.13"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "d24a825a95a6d98c385001212dc9020d609f2d4f"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.8.1"

[[SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableIOInterface]]
git-tree-sha1 = "9a0d3ab8afd14f33a35af7391491ff3104401a35"
uuid = "d1efa939-5518-4425-949f-ab857e148477"
version = "0.1.6"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll"]
git-tree-sha1 = "2839f1c1296940218e35df0bbb220f2a79686670"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.18.0+4"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─a7d494b4-8fb7-47f2-b06e-55ebf3f36690
# ╟─dc1d2ab3-49bc-4692-ad57-670697459552
# ╟─2b672651-530b-4337-87b3-a76e2fbe1de5
# ╟─2cfc08fe-3422-4d3b-86c6-38ad59be93a0
# ╟─fea06a1c-6026-4169-baf4-889f9af42798
# ╟─f7987a00-fcd2-4237-8812-573eb84c9913
# ╟─9787d683-eb06-48d5-917b-96c51bfa37a7
# ╟─5950833a-9ece-4c0e-a603-f5ad165bcc6b
# ╟─1080cbab-e04f-4d2d-b6f3-33e8c5e7878f
# ╟─c2bb52a3-6a8a-46f2-98df-af7cb9aecdfc
# ╟─2d66e877-ddd9-41ef-b231-de6a41dc9eaa
# ╟─52902751-b61f-4d1a-9c25-ac219f538528
# ╟─5724d527-7160-46a7-8599-b8c970366ab7
# ╟─f408f533-e1d8-4d1d-a79a-976602c559f0
# ╟─b4f738e6-781a-4e80-9892-3a12680ddfbb
# ╟─90943ce5-bfdb-48b7-beb1-6e7d39222e48
# ╟─eddefff7-b3e5-4361-ba6f-4a89dfd67cb3
# ╟─b8bd59de-5ef5-4da8-99ac-96dcc36b7b0c
# ╟─b7f28c45-0434-4d88-88b5-c525c8ea037b
# ╟─e7e4f425-f6b8-450e-92e6-a71ad0a2b904
# ╟─7a2e8ed8-24c8-41d9-a3ed-e38f96b0e172
# ╟─e4565d5b-3d19-4337-919e-d8fe27990f95
# ╟─b84291fe-1432-4357-9d77-cab8e3229ee1
# ╟─a5331fcf-1463-44f4-9343-4cca0f14aee0
# ╟─928e6d59-b54f-496f-adb7-a078ba9d68c3
# ╟─b0df24a1-480b-4d1f-9272-68403f75bd07
# ╟─6d7a6303-55cb-4380-b044-e8503b257b47
# ╟─d4e98cf5-3a4b-4574-a582-9b44cf4c0e99
# ╟─9de794aa-3069-4ffc-9ebc-e655b4279a4b
# ╟─68359905-a06b-4a40-959b-cfa7dbd3788b
# ╟─2c9271b2-c3e3-498a-9958-e4bc5d0faf2d
# ╟─f93fe5d6-126c-48cf-9127-bb29849f3ae1
# ╟─08c4d7e6-85ae-4b53-80ed-3a64bb216551
# ╟─64fe5c24-2d87-4e95-9530-d18fd83049af
# ╟─2f0655ad-b3a6-4dd7-881b-998c511b5650
# ╟─93501b5a-0862-4f34-9bc5-77589f7f0bdd
# ╟─32736a2e-3af8-4447-b723-f461a0543cc3
# ╟─4e7d30ba-fb9e-4848-8fb6-8e388e8a8447
# ╟─7c186c55-dbd0-41d6-b2b6-1ab7552a18f1
# ╟─5c9ce442-0f58-4ce5-9742-fd1f98aa8a64
# ╟─8aa57969-9116-4eb3-a1cf-e54ddaa00162
# ╟─69f073e7-2d57-4539-ae5a-17b64b532906
# ╟─c0232e07-7fe9-4358-a162-3bf01939063e
# ╟─e16cb65f-1083-420e-a0d0-3dcbf2faa41c
# ╟─0d2f0256-1e28-47e0-88bd-43a8e47e1f41
# ╟─a3658128-3822-42c5-ab47-13338cef4f91
# ╟─4c51ede4-cb91-4b45-84cb-e629244c4ac3
# ╟─9ba19506-9cd0-4a6f-a966-db2e94845f72
# ╟─523e474d-2da8-4e20-855d-30690bbbad38
# ╟─9909e1ea-76e3-4f6d-95c9-6203897851cc
# ╟─cfaa0a34-2218-4899-bb2d-ee1d7d068938
# ╟─a6b5030b-b742-456c-b0ae-607b4bb58cd4
# ╟─af0c80a7-09b6-45f5-a379-a2a0cdea20a1
# ╟─627d4b10-6878-4631-843e-ab55de368815
# ╟─8989f06f-cff4-4294-98d6-536bb46ed246
# ╟─9bab1c8f-560c-4b03-acb1-e2ad478ed1ad
# ╟─bbb71ed6-f9ca-41b6-b626-8cc88d7dd518
# ╟─8eec208a-817f-4df6-bccb-44c6f03f7f67
# ╟─f0791331-7272-483f-b20c-42731acd7d1e
# ╟─5c70225e-711f-4af3-b483-92b534a9f296
# ╟─976c24ca-aceb-4ded-9a21-048994e356a9
# ╟─fed529bd-dfd6-4314-9035-00bd6f54fc20
# ╟─6e648e01-7b29-4d0e-a637-54c2a2bddef7
# ╟─4108e505-a66a-403d-ae5d-aadce5058a99
# ╟─1c9428db-b2ce-4069-a018-55a45cc8026f
# ╟─1f1f72b4-abc8-443a-83db-578f797506e5
# ╟─aaf76732-a964-4e0b-8ed9-d38bb0d985e5
# ╟─25c97465-989e-4ef4-9e42-4c4026be37bd
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
