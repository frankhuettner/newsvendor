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

# ╔═╡ f4694b89-3cfb-4154-a0ae-f853c8e464ad
import Pkg; Pkg.add(url="https://github.com/lungben/PlutoGrid.jl"); Pkg.add(["PlutoUI","Plots","Statistics","Images","LaTeXStrings","DataFrames","ShortCodes","TOML","QuadGK","Parameters","Configurations","JSON3","Distributions","NewsvendorModel","PlotlyBase","ZipFile","PlutoTeachingTools","Tar","CodecZlib","Random"])

# ╔═╡ e0d09197-fc18-46e9-b0f9-b513ea32596a
begin
	using PlutoUI,Plots, Statistics, Images, LaTeXStrings, DataFrames,ShortCodes,TOML,QuadGK,Parameters,Configurations, JSON3, Distributions, NewsvendorModel,PlotlyBase, ZipFile,PlutoTeachingTools;
	import Tar, CodecZlib	, Random

	md""
end

# ╔═╡ 260482ce-3a2a-4b84-9e92-ce7bc218c51f
using PlutoGrid

# ╔═╡ 18cac7f8-9fc9-465b-8200-5e4ed6e51508
md"""
# ⚙️ Setup Appearance
"""

# ╔═╡ 3dbf73df-7c3f-4c3c-bac3-13f200908d70
md"# Data Selection"

# ╔═╡ 84017a5c-bb38-417b-96b3-fc0c3038ce7e
md"""### Getting the Data

1. Please enter a classname: $(@bind yourclassname TextField(; default="DREAMTEAM"))
 
"""

# ╔═╡ 0a65842b-ffdf-4b3f-92fc-56a3f586a811
md"""
2. You can upload a zip file containing the TOML-files (e.g. "Download All Files" from Canvas):  $(@bind submissions_zip FilePicker())
"""

# ╔═╡ 6cd866f3-2e0d-47c9-b585-e8bac0936f6d
md"""
3. After adding further data to above locations, please click $(@bind reload_stud_data CounterButton("Reload data"))
"""

# ╔═╡ 52658501-73e9-4015-80bf-bd8710dcb4e1
md"""### 
Alternatively, you can save the TOML files in one of the following two directories:
"""

# ╔═╡ 801c1a4c-9201-4e23-b745-5d3e1a9bb372
manual_data_paths = [
	joinpath(homedir(), "data", yourclassname, "simlog")
	joinpath(pwd(), "data", yourclassname, "simlog")
	
]; HTML(manual_data_paths[1]) 

# ╔═╡ 115a5ab1-6b84-4037-854f-3eff3992b7fe
HTML(manual_data_paths[2]) 

# ╔═╡ 96b45736-390e-4f39-b0cf-d643ab15e39d
begin
	# Standard data
	# This is what we'll download
    example_data_source_zipped = "https://github.com/frankhuettner/newsvendor/blob/b2566cb1ea28ba7a20614c9a4726bd7a59ed9579/debrief/data.tgz?raw=true"
	
    # Make temp dir
    dir = mktempdir()
 
    # Download example data 
	datatgz = download(example_data_source_zipped)
	
	open(CodecZlib.GzipDecompressorStream,datatgz) do io
	    Tar.extract(io, dir)
	end
    data_path = joinpath(dir, "data")
	
	md"Moreover, we downloaded some example data from github and temporarily store it in 
$(data_path)"
end

# ╔═╡ f2b876d0-4f90-4367-9416-52efbc924d2d


# ╔═╡ fe94c8b9-02ea-4613-b7ba-030b4587ac40
md"### Filter Class Data"

# ╔═╡ 2490515c-3d21-4a3b-b859-1dcc8b0f4ae6
md"""
`Show players who didn't play   = ` $(@bind show_no_play html"<input type=checkbox >")
`Show players who didn't 30 days play   = ` $(@bind show_no_30_play html"<input type=checkbox >")

"""

# ╔═╡ 776b35d7-72a2-4fb1-b3b4-d3ab3249a01b
md"""
`Filter specific players (separate by commas)  = ` $(@bind filter_players TextField(default="jqzFXGha,",))
"""

# ╔═╡ 92728155-fad1-4968-8e43-926f621728d4


# ╔═╡ 2924e14f-d466-4df4-9915-307b2c96c184


# ╔═╡ 74952e7e-23f4-451f-89df-049f95abe93f
md"### Summary Statistics"

# ╔═╡ c1e0238b-b0cd-4329-8e93-bf1326e817fc


# ╔═╡ b0919b66-42f8-47c8-926e-8f55ef2b764d
md"### Randomly Generated Demands by the Simulation"

# ╔═╡ fd3ba11b-aa62-4cb2-81de-3d33e3fc7c34


# ╔═╡ 4ecf50cb-3307-4fe2-acaf-da6e1392fff6
md"""### Anonymized Export of the Data of Selected Class as *.tgz-File

Standard export is anonymous. Select here if you want to keep the filenames and player IDs for export (not anonymized):  $(@bind not_anonymized html"<input type=checkbox >")
"""

# ╔═╡ 13870203-9d07-42fd-9ce9-885c8d632e2d
function replace_player_id(file, rndid)
	(tmppath, tmpio) = mktemp()
	open(file) do io
	    for line in eachline(io, keep=true) # keep so the new line isn't chomped
	        if occursin("player_id", line)
	            line = """player_id = "$(rndid)"\n"""
	        end
	        write(tmpio, line)
	    end
	end
	close(tmpio)
	mv(tmppath, file, force=true)
end;

# ╔═╡ cd4d57ed-0de6-4f0c-bb31-dc0605c64133
md"# 👩👨🧑 📈📉📈 Class Plots"

# ╔═╡ f6fedebe-0a24-4503-abfd-c0b37155bb6b
available_scenarios = ["cheers_1", "cheers_2", "cheers_3", "cheers_4", ]; md"""
Select a scenarios for class performance 👉 $(@bind selected_scenario_agg Select(available_scenarios))
"""

# ╔═╡ bc6f34b2-6909-4de0-8666-f80b04359061
md"""
## Ignorance is Bliss?

"""

# ╔═╡ 4ba5c1f0-60b2-47c9-8220-7836e84b9ce8


# ╔═╡ 71faa189-c00b-4092-939e-3f9b8013a8b2
md"""
## How to Win the Simulation? Being Lucky + ...

"""

# ╔═╡ 36fb274d-9923-4ae8-842e-ba8d6bdcaeaa
md"""
`Show linear regression line in decision vs. outcome graph  = ` $(@bind show_reg_outcome html"<input type=checkbox >")
"""

# ╔═╡ be3fe754-e633-45b1-bc0e-ab1cf3aec3ac


# ╔═╡ 6f1a80c0-3ba3-42dd-9f35-135062b370e4
md"""
## Without the Influence of Luck: Expected Profit

"""

# ╔═╡ 041f4279-b7f3-495a-b036-24663f95c143
md"""
`Show expected profit (constant order) in decision vs. outcome graph  = ` $(@bind show_exp_profit html"<input type=checkbox >")

"""

# ╔═╡ cfb7ebea-9c49-4af3-90cb-90cfc8be6744


# ╔═╡ 934295c9-210d-4625-aaa7-5493cee738c9
md"Above we see a demand chaser with high loss from fluctuating order (the player with maximal Cor_Qₜ_Dₜ₋₁xFluctuationLoss)"

# ╔═╡ 0fe0d06e-0c7e-4acd-8630-634f00b3a520


# ╔═╡ 66025ac7-47d6-4c11-83fa-befff248e2ea
md"""
## Loss from Fluctuation
"""

# ╔═╡ 9f16663d-0fac-47eb-9706-be738fa5d5f5
md"""
👉 $(@bind no_variation html"<input type=checkbox>")

"""

# ╔═╡ a31d8f99-7487-4935-988b-9717c1ab9289


# ╔═╡ 6a9c9501-88c1-40c2-9eca-897a09df91c8
md"## Demand chaser (highest Cor_Qₜ_Dₜ₋₁)"

# ╔═╡ 47bad2aa-051e-4ef0-97b6-2d94641b1a5d


# ╔═╡ 85bbeaf7-9c14-420b-9a37-399895c6058a
md"# 🧑📈 Individual Play "

# ╔═╡ a6da3528-ab68-4695-ba3f-043443722a2a
	md"""
Select a scenarios 👉 $(@bind selected_scenario_ind Select(available_scenarios))
"""

# ╔═╡ b89d8514-2b56-4da9-8f49-e464579c2293
begin
	# Some definitions and helper functions
	bigbreak(n = 4) = HTML("<br>" ^ n);
	
	hints_visible = true
	
	
	function hint(text, headline = "Hint") 
		if hints_visible
			Markdown.MD(Markdown.Admonition("note", headline, [text]))
		else
			Markdown.MD(Markdown.Admonition("hint", headline, [text]))
		end
	end
	
	# example
	##  hint(md"""at this""", md"""look here""")
	
	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]))
	still_missing(text=md"Replace `missing` with your answer.") = Markdown.MD(Markdown.Admonition("warning", "Here we go!", [text]))
	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]))
	yays = [md"Fantastic!", md"Splendid!", md"Great!", md"Yay ❤", md"Great! 🎉", md"Well done!", md"Keep it up!", md"Good job!", md"Awesome!", md"You got the right answer!", md"Let's move on to the next section."]
	correct(text=rand(yays)) = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]))
	


	md""
end

# ╔═╡ c8618313-9982-44e0-a110-2d75c69c75e8
begin
	# Foldable
	struct Foldable{C}
		title::String
		content::C
	end

	function Base.show(io, mime::MIME"text/html", fld::Foldable)
		write(io,"<details><summary>$(fld.title)</summary><p>")
		show(io, mime, fld.content)
		write(io,"</p></details>")
	end
	
	# example
	# Foldable("What is the gravitational acceleration?", md"Correct, it's ``\pi^2``.")
	
	
	
	### Two column
	struct TwoColumn{L, R}
		left::L
		right::R
	end

	function Base.show(io, mime::MIME"text/html", tc::TwoColumn)
		write(io, """<div style="display: flex;"><div style="flex: 50%;">""")
		show(io, mime, tc.left)
		write(io, """</div><div style="flex: 50%;">""")
		show(io, mime, tc.right)
		write(io, """</div></div>""")
	end
	# example
	# 	TwoColumn(md"Note the kink at ``x=0``!", plot(-5:5, abs))

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
		pluto-output, pluto-output div.admonition .admonition-title {
		font-family: 'Lexend Deca', sans-serif;
		}
		pluto-output h1, pluto-output h2, pluto-output h3, pluto-output h4, pluto-output h5, pluto-output h6 {                                                  	font-family: 'Lexend Deca', sans-serif;
		    font-weight: 300    
					   
		}
		pluto-output h1  {                    
		    font-size: 2rem    
		}
		pluto-output h2  {                    
		    font-size: 1.6rem    
		}
		.center {
		  display: block;
		  margin-left: auto;
		  margin-right: auto;
		  width: 60%;
		}
		</style>
	"""
end

# ╔═╡ ce191084-2999-474f-aeb4-7677d7dd371d
TwoColumn(md"""
- Hide Table of Contents  $(@bind hide_toc html"<input type=checkbox >")
- Hide Pluto UI  $(@bind hide_ui html"<input type=checkbox >")
"""
,
ChooseDisplayMode()
	# html"
	# <b>For Presentation and Printing </b> 
	# <br>
	# <br>
	# Click here to change to <button onclick='present()'>Presentation Mode</button>  This is usefule (Tip: F11 puts the browser in fullscreen)"
	)

# ╔═╡ 9955626e-3103-4d83-918f-1020ed9ef0a2
if !hide_ui
md"# Source Code
## Packages
"
else
	md""
end

# ╔═╡ 1b686af7-ccc5-43e6-8da1-ab91373f3b63
if !hide_ui
	md"## Parameters"
else
	md""
end

# ╔═╡ e39911c7-22de-47ca-b442-441c0f1d2657
if !hide_ui
	md"## Styling and Pluto Sugur"
else
	md""
end

# ╔═╡ 760bcbea-484b-4c79-ac9b-458aaeb8a083
if hide_toc
	md""
else
	TableOfContents()
end

# ╔═╡ 375b5f20-ff08-4d9a-8d41-38214db962de
if hide_ui
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

# ╔═╡ f029b8ff-e8a0-4ae3-9fdf-29ffb7189903
if !hide_ui
md"## Functions
###  Helper
"
else
	md""
end

# ╔═╡ c36ee104-1d6d-40b8-b992-2d8ff6f29674
			"""
		my_round(x::Real; [sigdigits::Int=3])		
	Return x rounded with #sigdigits significiant digits.
	"""
	function my_round(x::Real; sigdigits::Int=3)
		x = round(x, sigdigits=sigdigits)
		if x >= 10^(sigdigits-1)
			Int(x)
		else
			x
		end
	end

# ╔═╡ b2c19571-95b1-4b7f-9ec1-ed83ba7b8aef
begin 	
	cheers_1 = NVModel(cost = 1, price = 5, demand = truncated(Normal(90, 30), 0, 180) )   
	cheers_2 = cheers_2 = NVModel(cost = 4, price = 5.5, demand =  Uniform(0, 60))	
	cheers_3 = NVModel(cost = 1.5, price = 9, demand = truncated(Normal(90, 30), 0, 180), salvage = .5 )   
	cheers_4 = NVModel(cost = 10, price = 42, demand = DiscreteNonParametric([0,1,2],[.3,.5,.2]))

	nvms = Dict("cheers_1" => cheers_1, "cheers_2" => cheers_2, "cheers_3" => cheers_3, "cheers_4" => cheers_4)
		
	selected_nvm = nvms[selected_scenario_agg]
	
	Qopt = q_opt(selected_nvm)
	Co = overage_cost(selected_nvm)
	Cu = underage_cost(selected_nvm)
	CF = critical_fractile(selected_nvm)
	CF_percent = my_round(100*CF)	
	μ = mean(selected_nvm.demand)
	
	md""
end

# ╔═╡ 1bb39671-cf79-4c29-a02e-f4250d5c06bc
md""" 👉 Guess some monthly fixed cost $(@bind fixcost NumberField(0:100:round(Int,30*profit(selected_nvm)), default = 0)) €  """

# ╔═╡ 7d6dfb80-5a6c-4559-a325-490af3da2263
Foldable("Click here to see the calculation",
	begin
	qs = [90.0, 100, q_opt(selected_nvm)]
	monthly_profits = [NewsvendorModel.profit(selected_nvm, q) * 30 for q in qs]
	
	# push!(qs, mean(df_res[:,:AvgStock]))
	# push!(monthly_profits, 30*mean(df_res[:,:ExpProfit]))
	monthly_incomes = monthly_profits .- fixcost 
	fixed = [ fixcost for i in monthly_incomes]
	df = DataFrame("# Cakes Made" => qs, "Expected Monthly Profit Contributon" => monthly_profits, "Fixed Cost (Rent + Staff)" => fixed, "Owners' Income" => monthly_incomes)
	end
)

# ╔═╡ c6951037-e666-43bf-8260-b489143a550a
function percentup(old, new; stringed = true)
		res = my_round(100 * (new - old)/old)
		if stringed
			return string(res) * "%"
		else
			return res
		end
	end

# ╔═╡ 58994e41-e952-42b8-9c44-3e59236dff93
begin
	potinc = percentup(30*profit(selected_nvm, μ)-fixcost, 30*profit(selected_nvm)-fixcost)
	gr()
	ignoring_uncertainty_plt = Plots.bar(qs, monthly_incomes, xlabel="Owners' Income per Month (Assuming Fixed Cost = $(fixcost))", legend = false, orientation = :h, title="  $(potinc) Higher Income Possible", yaxis = nothing,
	xformatter = :plain 
	)
	annotate!(500, Qopt, text("Optimal Quantity",14, :left, :white))
	annotate!(500, 100, text("Status Quo",14, :left, :white))
	annotate!(500, 90, text("Ignorant of Uncertainty",14, :left, :white))
end

# ╔═╡ b198752d-aecd-4c47-acdd-05818aa5c80c
function plt_download(plt, name, condition)
	if condition
	md"""Download Plot in high resolution (svg): 
$(DownloadButton(open(Plots.savefig(plt, joinpath(mktempdir(), name*".svg"))), name*".svg"))
"""
	else
		md""
	end
end

# ╔═╡ 1926fa40-3da7-4acc-a30c-b9b7da13d46b
if !hide_ui
	md"### Data Structs, Conversion, Standard Plots"
else
	md""
end

# ╔═╡ 5ea60b57-f735-41c2-86cf-de6601573719
begin
	@with_kw struct Scenario
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
	end
	
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
		
		sd.expected_lost_sales, sd.expected_sales, sd.expected_left_overs, sd.expected_profits = 	compute_expected_values(sd.qs, sd.scenario)
		
	end

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
	end

	function compute_expected_values(qs::Vector{<:Number}, scenario::Scenario) 
		n_days = length(qs)
		if n_days == 0 return zeros(1,4) end
	
		expected_values = Matrix{Number}(undef, n_days, 4)
	
		for i in 1:n_days
			expected_values[i,:] = compute_expected_values(qs[i], scenario) 
		end
	
		return mean(expected_values, dims=1)
	end	
	function L(f, x, u)
		L, _ = quadgk(y -> (y - x) * f(y), x, u, rtol=1e-8)
		return L
	end; md" L(f, x) = ∫ₓᵘ (y - x)f(y)dy"

	
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
	end


	function update_plot_panel_1(sim_data::SimData)
		sd = sim_data
		gr()
		plot()
		scatter!(sd.sales,  label="Sales", markerstrokewidth=3.5,c=:white, markersize=7,  markerstrokecolor = 3, bar_width=sd.days_played*0.01)	
	
		scatter!(sd.demands[1:sd.days_played], label = "Demanded", c = 1, msw = 0, 
			xlabel = "Day", xticks=1:sd.days_played, xrotation=60, size=(680, 420),
			right_margin=-8Plots.mm)
		plot!(sd.demands[1:sd.days_played], lw=1, ls=:dash, label="", c = 1)
	
		plot!([sd.avg_demand], seriestype="hline", 
			c=1,lw=2,ls=:dot,label="Observed\naverage\ndemand\n($(my_round(sd.avg_demand)))")
	
		scatter!(sd.qs, label = "You stocked", c = 2,  msw = 0)
		plot!(sd.qs, lw=1, ls=:dash, label="", c = 2, legend = :outertopright)
	
		plot!([sd.avg_q], seriestype="hline", 
			c=2,lw=2, ls=:dot,label="Your average\ndecision ($(my_round(sd.avg_q)))")
			
	
	end
	
	function update_plot_panel_2(sd::SimData)
		
		days = 1:sd.days_played
		Plots.bar(days, sd.revenues, label="Revenue", lw=0,  c = :green, fillalpha = 0.61, bar_width=0.17, 
			size=(750, 150), xticks=days, xrotation=60, legend=:outertopright)
		bar!(days.+0.17, sd.profits, label="Profit", lw=0,c = 5, fillalpha = 0.95, bar_width=0.17,)
		bar!(days, 0 .- sd.costs, label="Cost", lw=0,c = 2, fillalpha = 0.81, bar_width=0.17, )
		plot!(x->0, label="",  c = :black, left_margin=-2Plots.mm, right_margin=-6Plots.mm, bottom_margin=2Plots.mm)
	end
	
	@option struct PlayLog
		demands::Vector{<:Number} = round.(Int, rand(TruncatedNormal(90, 30, 0, 180), 30))
		qs::Vector{<:Number} = Vector{Int64}()
	end
	
	@option struct StoryLog
		title::String = "Patisserie Cheers!"
		url::String = "https://raw.githubusercontent.com/frankhuettner/newsvendor/main/scenarios/cheers_1_story.md"
	end
	
	@option struct UnitValueLog
		c::Real = 1 	# cost of creating one unit
		p::Real = 5  	# selling price
		s::Real = 0    # salvage value
	end
	
	@option struct DistributionLog
		typus = "Truncated Normal"
		l::Real = 0 	# lower bound
		u::Real = 180		# upper bound
		μ::Real = (u - l)/2	 # mean demand
		σ::Real = (u - l)/6 	# standard deviation of demand
		discrete_probs = [pdf(TruncatedNormal(90, 30, 0, 180), x) / 
					sum(pdf.(TruncatedNormal(90, 30, 0, 180), 1:180))  for x in 1:180]
	end
	
	@option struct SimConfLog
		max_num_days::Int = 30  # Maximal number of rounds to play
		delay::Int = 300    # ms it takes for demand to show after stocking decision 
		allow_reset::Bool = false
	end
	
	@option struct ScenarioLog
		name::String="cheers_1"
		unit_value::UnitValueLog = UnitValueLog()
		distribution::DistributionLog = DistributionLog()
		story::StoryLog = StoryLog()	
		sim_conf::SimConfLog = SimConfLog()
	end
	
	@option struct SimLog
		play::PlayLog = PlayLog()
		scenario::ScenarioLog = ScenarioLog()
	end
	
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
	end
	
	function simlog_to_simdata(simlog)
		sd = SimData(				
			scenario = scenariolog_to_scenario(simlog.scenario),
			demands = simlog.play.demands,
			qs =  simlog.play.qs,
		)
		update_sim_data!(sd)
		return sd
	end
	
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
	end
	
	function simdata_to_simlog(simdata) 
		playlog = from_kwargs(PlayLog, qs = simdata.qs, demands = simdata.demands)
		scl = scenario_to_scenariolog(simdata.scenario)
		
		return SimLog(player_id = my_ID(), play = playlog, scenario = scl)
	end
	
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
	end
	
	function save_available_scenario_conf(available_scenarios=available_scenarios, path="")	
		d = Dict([sc.name => sc.name*"_conf.toml"  for sc in available_scenarios])
		
		open(path*"available_scenario_confs.toml", "w") do io
			TOML.print(to_toml, io, d)
		end
		
		for sc in available_scenarios
			to_toml(path*sc.name*"_conf.toml", sc |> scenario_to_scenariolog)
		end
	end


	md""
	
	
end

# ╔═╡ 5f7cf638-cbf8-48f8-a8bb-b1ebf5ba88ab
begin
	function cor_Qₜ_Dₜ₋₁(sd)
		n = sd.days_played
		if n < 2
			return 0.0
		end	
		if var(sd.qs[2:n]) ≈ 0 || var(sd.demands[1:n-1]) ≈ 0 
			return 0.0
		end
		return	Statistics.cor(sd.qs[2:n], sd.demands[1:n-1])
	end; 
	
	function fluctuationloss(logfile, scenario)
		dict_simlogs_ind = TOML.parsefile(logfile)
		simlog_ind = from_dict(SimLog, dict_simlogs_ind["log"][scenario])
		sim_data_ind = simlog_to_simdata(simlog_ind)
		sim_data_ind_const = simlog_to_simdata(simlog_ind)
		update_sim_data!(sim_data_ind)
		sim_data_ind_const.qs = ones(length(sim_data_ind.qs)) * round(Int,sim_data_ind.avg_q)
		update_sim_data!(sim_data_ind_const)
		return percentup(sim_data_ind.avg_profit, sim_data_ind_const.avg_profit, stringed=false)
	end; 
	md"### Selected data"
end

# ╔═╡ 38d42a2a-1f93-4c92-87c4-2cbe69d1e927
function unzip(file,exdir="")
    fileFullPath = isabspath(file) ?  file : joinpath(pwd(),file)
    basePath = dirname(fileFullPath)
    outPath = (exdir == "" ? basePath : (isabspath(exdir) ? exdir : joinpath(pwd(),exdir)))
    isdir(outPath) ? "" : mkpath(outPath)
    zarchive = ZipFile.Reader(fileFullPath)
    for f in zarchive.files
        fullFilePath = joinpath(outPath,f.name)
        if (endswith(f.name,"/") || endswith(f.name,"\\"))
            mkdir(fullFilePath)
        else
            write(fullFilePath, read(f))
        end
    end
    close(zarchive)
end

# ╔═╡ 88c52658-3c0c-4aad-aaff-242fd4b85a93
function unzip(io::IOBuffer,exdir="")
    outPath = (exdir == "" ? pwd() : (isabspath(exdir) ? exdir : joinpath(pwd(),exdir)))
    isdir(outPath) ? "" : mkpath(outPath)
    zarchive = ZipFile.Reader(io)
    for f in zarchive.files
        fullFilePath = joinpath(outPath,f.name)
        if (endswith(f.name,"/") || endswith(f.name,"\\"))
            mkdir(fullFilePath)
        else
            write(fullFilePath, read(f))
        end
    end
    close(zarchive)
end

# ╔═╡ 97826684-aeb4-4f54-8230-722104acbbaf
begin
	reload_stud_data
	classes = readdir(data_path, join=true) .=> readdir(data_path)
	if isdir(joinpath(manual_data_paths[1]))
		append!(classes,  
			readdir(joinpath(manual_data_paths[1], "..", ".."), join=true) .=> readdir(joinpath(manual_data_paths[1], "..", ".."))
		)
	end
	if isdir(joinpath(manual_data_paths[2]))
		append!(classes,  
			readdir(joinpath(manual_data_paths[2], "..", ".."), join=true) .=> readdir(joinpath(manual_data_paths[2], "..", ".."))
		)
	end
	if typeof(submissions_zip) == Dict{Any, Any}
		uploaddir = mktempdir()
		uploadclass = joinpath(uploaddir, yourclassname)
		uploadsimlogs = joinpath(uploadclass, "data", "simlog")
		unzip(IOBuffer(submissions_zip["data"]), uploadsimlogs)
		append!(classes, readdir(uploadclass, join=true) .=> readdir(uploaddir))
	end
	dataexists = length(classes) > 0
	if dataexists
		md"""4. Select you class 👉 $(@bind selected_class_path Select(classes)) """
	else
		selected_class_path = ""
		md""
	end
end

# ╔═╡ d04db0f4-1e2d-4c60-ace7-df4500ff6a79
if selected_class_path != ""
	simlog_path = joinpath(selected_class_path, "simlog")
	simlog_dir = readdir(simlog_path)
	simlogs = simlog_dir[occursin.(r".*\.toml", simlog_dir)]


	df_res = DataFrame(:FileName => simlogs)
	insertcols!(df_res, 		:ID => "", 
								:DaysPlayed => 0, 
								:ExpProfit => 0.0,
								:AvgStock => 0.0, 
								:AvgDemand => 0.0, 
								:TotalProfit => 0.0, 
								:Cor_Qₜ_Dₜ₋₁ => 0.0, 
								:FluctuationLoss => 0.0, 
								:Std_Q => 0.0, 
								:Cor_Qₜ_Dₜ₋₁xFluctuationLoss => 0.0, 
								)
	for row in eachrow(df_res)
		logfile = joinpath(simlog_path, string(row.FileName)) 
		if isfile(logfile)
			dict_simlogs = TOML.parsefile(logfile)
			simlog = from_dict(SimLog, dict_simlogs["log"][selected_scenario_agg])
			row.ID = dict_simlogs["player_id"]	
			if length(simlog.play.qs) > 0
				sd = simlog_to_simdata(simlog)
				update_sim_data!(sd)				
				row.DaysPlayed = sd.days_played
				row.ExpProfit = sd.expected_profits |> my_round
				row.AvgStock = sd.avg_q |> my_round
				row.AvgDemand = sd.avg_demand |> my_round
				row.TotalProfit = sd.total_profit	
				row.Cor_Qₜ_Dₜ₋₁ = cor_Qₜ_Dₜ₋₁(sd) |> my_round
				row.FluctuationLoss = fluctuationloss(logfile, selected_scenario_agg)
				row.Std_Q = Statistics.std(sd.qs) |> my_round
				row.Cor_Qₜ_Dₜ₋₁xFluctuationLoss = row.Cor_Qₜ_Dₜ₋₁ .* row.FluctuationLoss   |> my_round
			end
		end
	end
	
	if !show_no_play # filter players who didn't play 
		df_res = df_res[df_res[!, :DaysPlayed].!=0,:] 
	end
	if !show_no_30_play # filter players who didn't play 30 days
		df_res = df_res[df_res[!, :DaysPlayed].==30,:]
	end
	df_res = df_res[.!occursin.(df_res[!, :ID], filter_players)	,:]  # filter specific player
	
	
	# df_res[!, filter(x->x !="link" , names(df_res))]
	df_res[!, filter(x->x !="link" , names(df_res))]  |> readonly_table
end

# ╔═╡ 53b86fb2-3fe6-4670-b56e-a67dade1d0a4
describe(df_res)

# ╔═╡ e61008ce-f581-413b-8c0b-feb4d12e1212
begin
	players_exist = @isdefined df_res
	players_exist = players_exist && size(df_res, 1) > 0
	md"We have players playing this scenario = $(players_exist)"
end

# ╔═╡ c2cb2967-6033-418d-9707-f0875d592cdf
plt_download(ignoring_uncertainty_plt, "ignoring_uncertainty_plt", players_exist )

# ╔═╡ dc1a6bf7-8275-41ac-ac16-b3449da55239
TwoColumn(
begin
if players_exist
	function make_outcome_plot(df_res, show_reg_outcome)
		gr()
		ymax = 1.1 * maximum(df_res[!,:TotalProfit])
		outcome_plot = plot(xlabel="Decision (Average Stock)", ylabel="Outcome (Total Profit)",legend=false,
			xlims=(minimum(selected_nvm.demand),maximum(selected_nvm.demand)), 
			ylims=(0,ymax),
			size = (450,300)
		)
		vline!(outcome_plot, [mean(selected_nvm.demand)], lw=1)
		# vline!(outcome_plot, [q_opt(selected_nvm)], lw=1)
		outcome_xs = df_res[!,:AvgStock]
		outcome_ys = df_res[!,:TotalProfit]
		outcome_ones = ones(length(outcome_xs))
		linreg(x, y) = hcat(fill!(similar(x), 1), x) \ y
		outcome_a, outcome_b = linreg(outcome_xs, outcome_ys) 
		scatter!(outcome_plot, outcome_xs, outcome_ys, markersize = 8, marker_z=df_res[!,:AvgDemand])	
		if show_reg_outcome == true
			plot!(collect(1:1:180),   outcome_a .+ outcome_b .* collect(1:1:180) , ls=:dash)
		end
		return outcome_plot
	end	
		
	if nrow(df_res) > 0
		outcome_plot = make_outcome_plot(df_res, show_reg_outcome)
	end
else
	
md"""
$(Resource("https://github.com/frankhuettner/newsvendor/blob/main/debrief/img/avg_order_vs_realized_profit_students.png?raw=true",  :class => "center"))
"""
end
end	

,
	md"""
- Each point represents a student
- The luckier you were => The higher the demand in your play => The brighter your color


""")

# ╔═╡ a8bcbb70-b778-46ee-b0ab-e0846c7391c9
plt_download(outcome_plot, "outcome_plot", players_exist )

# ╔═╡ e0d39e75-7064-42b3-b42f-55e4eafb3c6c
TwoColumn(
begin

if players_exist
	function make_exp_profit_plot(df_res, show_exp_profit)
		gr()
		ymaxexp = 1.1 * maximum(df_res[!,:ExpProfit])
		exp_profit_plot = plot(
			xlabel="Decision (Average Stock)", ylabel="Decision Quality (Expected Profit)",legend=false,
			xlims=(minimum(selected_nvm.demand),maximum(selected_nvm.demand)), ylims=(0,ymaxexp),
			size = (450,310)
		)
		vline!(exp_profit_plot, [mean(selected_nvm.demand)], lw=1)
		vline!(exp_profit_plot, [q_opt(selected_nvm)], lw=1)
		scatter!(exp_profit_plot, df_res[!,:AvgStock], df_res[!,:ExpProfit], markersize = 8, marker_z=df_res[!,:AvgDemand])
		
		if show_exp_profit == true
			qs = collect(1:1:180)
			plot!(exp_profit_plot, qs, [profit(cheers_1, q) for q in qs] , ls=:dash)
		end
		return exp_profit_plot
	end	
		
	if nrow(df_res) > 0
		exp_profit_plot = make_exp_profit_plot(df_res, show_exp_profit)
	end
else
	md"""

$(Resource("https://github.com/frankhuettner/newsvendor/blob/main/debrief/img/avg_order_vs_expected_profit_students.png?raw=true", :class => "center"))
"""
end
end

,
	md"""
- Each point represents a student
- The luckier you were => The higher the demand in your play => The brighter your color


""")

# ╔═╡ 35d6d326-258f-4041-874b-cce3dc82b437
plt_download(exp_profit_plot, "exp_profit_plot", players_exist )

# ╔═╡ 7f5c31e6-a362-46ec-abc5-0ef459d17d3b
let
if players_exist
	demand_chaser = findfirst(==(maximum(df_res.Cor_Qₜ_Dₜ₋₁xFluctuationLoss)), df_res.Cor_Qₜ_Dₜ₋₁xFluctuationLoss)
	demand_chaser_file = df_res[findmax(df_res.Cor_Qₜ_Dₜ₋₁xFluctuationLoss)[2], :FileName]
	profit = df_res[findall(df_res.FileName .== demand_chaser_file) , :TotalProfit][1]
	logfile_toml_chaser = joinpath(simlog_path, string(demand_chaser_file)) 
	if isfile(logfile_toml_chaser)
		dict_simlogs_chaser = TOML.parsefile(logfile_toml_chaser)
		simlog_chaser = from_dict(SimLog, dict_simlogs_chaser["log"][selected_scenario_agg])
		sim_demand_chaser_const = simlog_to_simdata(simlog_chaser)
		update_sim_data!(sim_demand_chaser_const)
		demand_chaser_avg_q = sim_demand_chaser_const.avg_q
		
		for i in 1:length(sim_demand_chaser_const.qs)
			sim_demand_chaser_const.qs[i] = round(Int, demand_chaser_avg_q)
			# sim_demand_chaser_const.qs[i] = round(Int, 90)
		end
		update_sim_data!(sim_demand_chaser_const)
		const_profit = sim_demand_chaser_const.total_profit        
		for i in 1:length(sim_demand_chaser_const.qs)
			sim_demand_chaser_const.qs[i] = Qopt
		end
		update_sim_data!(sim_demand_chaser_const)
		opt_profit = sim_demand_chaser_const.total_profit        

md"""
## Chasing Demand Did Not Work
Here, simply ordering the average $(round(Int,demand_chaser_avg_q)) had resulted in $(percentup(profit, const_profit)) more profit


"""
# (ordering Qopt would have given $(percentup(profit, opt_profit)) higher profit)
	end
end
end

# ╔═╡ 7fa8651e-4db4-4809-9c1c-4586a66c9e50
begin
if players_exist
	demand_chaser_loser = findfirst(==(maximum(df_res.Cor_Qₜ_Dₜ₋₁xFluctuationLoss)), df_res.Cor_Qₜ_Dₜ₋₁xFluctuationLoss)
	demand_chaser_file_loser = df_res[findmax(df_res.Cor_Qₜ_Dₜ₋₁xFluctuationLoss)[2], :FileName]
	logfile_toml_chaser_loser = joinpath(simlog_path, string(demand_chaser_file_loser)) 
	if isfile(logfile_toml_chaser_loser)
		dict_simlogs_chaser_loser = TOML.parsefile(logfile_toml_chaser_loser)
		simlog_chaser_loser = from_dict(SimLog, dict_simlogs_chaser_loser["log"][selected_scenario_agg])
		sim_demand_chaser_loser = simlog_to_simdata(simlog_chaser_loser)
		update_sim_data!(sim_demand_chaser_loser)
		demand_chaser_loser_plt = update_plot_panel_1(sim_demand_chaser_loser)
	end

end
end

# ╔═╡ f40fe0b7-9705-43b0-ae05-d3e3f069ffa9
plt_download(demand_chaser_loser_plt, "demand_chaser_loser_plt", players_exist )

# ╔═╡ bbaff929-0f20-4e58-8930-430be3f03d71
if players_exist
	no_variation
	qss = copy(qs)
	push!(qss, mean(df_res[:,:AvgStock]))
	monthly_incomess = copy(monthly_incomes)
	gr()
	if no_variation
		push!(monthly_incomess, 30*profit(selected_nvm, qss[end])-fixcost)
	else
		push!(monthly_incomess, 30*mean(df_res[:,:ExpProfit])-fixcost)
	end
	potential =percentup(monthly_incomess[end],monthly_incomess[3])
	fluctuation_loss_plt = Plots.bar(qss, monthly_incomess, ylabel="# Cakes Made", xlabel="Owners' Income per Month (Assuming Fixed Cost = $fixcost)", legend = false, orientation = :h, title="$(potential) Higher Income Possible",
	)
	
	annotate!(200, qss[end], text("Your Class Average",14, :white, :left))
	annotate!(200, Qopt, text("Optimal Quantity",14, :white, :left))
	annotate!(200, 100, text("Status Quo",14, :white, :left))
	annotate!(200, 90, text("Ignorant of Uncertainty",14, :white, :left))
end

# ╔═╡ e13c5e0b-8c9c-43a6-908d-5f5ab815933e
plt_download(fluctuation_loss_plt, "fluctuation_loss_plt", players_exist )

# ╔═╡ cea3f4ee-5ba2-4317-ab62-8a949abf7a33
md"""
Want to see the expected result had you always ordered $(round(Int,mean(df_res[:,:AvgStock])))?

"""


# ╔═╡ 83f177a7-a07f-492d-a283-252e5b9f4966
begin
if players_exist
	demand_chaser = findfirst(==(maximum(df_res.Cor_Qₜ_Dₜ₋₁)), df_res.Cor_Qₜ_Dₜ₋₁)
	demand_chaser_file = df_res[findmax(df_res.Cor_Qₜ_Dₜ₋₁)[2], :FileName]
	logfile_toml_chaser = joinpath(simlog_path, string(demand_chaser_file)) 
	if isfile(logfile_toml_chaser)
		dict_simlogs_chaser = TOML.parsefile(logfile_toml_chaser)
		simlog_chaser = from_dict(SimLog, dict_simlogs_chaser["log"][selected_scenario_agg])
		sim_demand_chaser = simlog_to_simdata(simlog_chaser)
		update_sim_data!(sim_demand_chaser)
		demand_chaser_plt = update_plot_panel_1(sim_demand_chaser)
	end

end
end

# ╔═╡ a6bf2500-0418-488c-a5ff-69cba2e9d1f7
plt_download(demand_chaser_plt, "demand_chaser_plt", players_exist )

# ╔═╡ 6b0a8e5b-b86e-4dfe-9333-f50141053287
begin
if selected_class_path !=  ""
	alldemands = []
	for row in eachrow(df_res)
		logfile = joinpath(simlog_path, string(row.FileName)) 
		if isfile(logfile)
			dict_simlogs = TOML.parsefile(logfile)
			simlog = from_dict(SimLog, dict_simlogs["log"]["cheers_1"])
			row.ID = dict_simlogs["player_id"]	
			if length(simlog.play.qs) > 0
				sd = simlog_to_simdata(simlog)
				append!(alldemands, sd.demands)
			end
		end
	end	
	n = length(alldemands)
	emp_mean = my_round(mean(alldemands))
	emp_std = my_round(std(alldemands))
	x_ticks = [emp_mean-emp_std, emp_mean-2*emp_std, emp_mean, emp_mean+emp_std, emp_mean+2*emp_std]
	gr()
	gen_demands_hist = Plots.histogram(alldemands, ylabel = "Frequency", legend = false, title = " (n = $(n))", size = (410, 350), xticks = x_ticks)
	vline!([emp_mean], lw = 3, c = :orange)
	annotate!(emp_mean, 0.99, text("Average = $(emp_mean)",15, :orange, rotation = 90 , :left, :bottom))
	vline!([emp_mean-emp_std], lw = 1, c = :green)
	vline!([emp_mean+emp_std], lw = 1, c = :green)
	annotate!(emp_mean, - n / 90, text("Std Dev = $(emp_std)",10, :green,  :center, :top), )

else
	md"No data loaded."
end
end

# ╔═╡ 7dffeb50-e6c3-417d-9d6b-fae25515993a
plt_download(gen_demands_hist, "gen_demands_hist", players_exist )

# ╔═╡ cb53a24e-fe3d-488f-aac9-ac18deaca9dc
function create_data_for_export(source_folder, not_anonymized=true)
	classfolder = joinpath(selected_class_path,  "..")
	simlogfolder = joinpath(source_folder, "simlog")
	
	if !not_anonymized
		t = mktempdir() 
		tsimlog = mkpath(joinpath(t, Dict(classes)[selected_class_path], "simlog"))
		
		files = readdir(simlogfolder, join=true)
		for file in files
			rndid = Random.randstring(4)
			rndfn = rndid * ".toml"
			replace_player_id(file, rndid)
			cp(file, joinpath(tsimlog, rndfn), force=true)
		end
		tdata = joinpath(tsimlog, "..")
	else
		tdata = classfolder		
	end
	
	tdir = mktempdir()
	tar_gz = open(joinpath(tdir, "classdata.tgz"), write=true)
	tar = CodecZlib.GzipCompressorStream(tar_gz)
	Tar.create(tdata, tar)
	close(tar)
	return joinpath(tdir, "classdata.tgz")
end;

# ╔═╡ 909c9f8b-8c27-4279-ba89-afe0d7180ac8
DownloadButton(open(create_data_for_export(selected_class_path, not_anonymized)), yourclassname*"_classdata.tgz")

# ╔═╡ ae6065cc-4729-4084-abc5-68fc75500888
if selected_class_path != "" 
	df_res_ind = DataFrame(:FileName => simlogs)
	insertcols!(df_res_ind, 		:ID => "", 
								:DaysPlayed => 0, 
								:ExpProfit => 0.0,
								:AvgStock => 0.0, 
								:AvgDemand => 0.0, 
								:TotalProfit => 0.0, 
								)
	for row in eachrow(df_res_ind)
		logfile = joinpath(simlog_path, string(row.FileName)) 
		if isfile(logfile)
			dict_simlogs = TOML.parsefile(logfile)
			simlog = from_dict(SimLog, dict_simlogs["log"][selected_scenario_ind])
			row.ID = dict_simlogs["player_id"]	
			if length(simlog.play.qs) > 0
				sd = simlog_to_simdata(simlog)
				update_sim_data!(sd)				
				row.DaysPlayed = sd.days_played
				row.ExpProfit = sd.expected_profits				
				row.AvgStock = sd.avg_q
				row.AvgDemand = sd.avg_demand
				row.TotalProfit = sd.total_profit	
			end
		end
	end	
	df_res_ind = df_res_ind[df_res_ind[!, :DaysPlayed].!=0,:]  # filter players who didn't play 
	# df_res_ind = df_res_ind[df_res_ind[!, :DaysPlayed].==30,:]  # filter players who didn't play 30 days
	# df_res_ind = df_res_ind[df_res_ind[!, :token].!="4sGdqu1U",:]  # filter specific player
	
	
	# df_res_ind[!, filter(x->x !="link" , names(df_res_ind))]
	df_res_ind[!, filter(x->x !="link" , names(df_res_ind))] |> data_table
	students = [  row.FileName => row.ID for row in eachrow(df_res_ind)  ]

	ind_players_exist = false
	if size(df_res_ind, 1) > 0
		ind_players_exist = true
		md"""Select a student 👉 $(@bind selected_file Select(students))"""
	else
		"Nobody played this scenario"
	end
end

# ╔═╡ 03d902b7-13fc-430c-ab9b-c1842f3cb004
if ind_players_exist
	logfile_toml_ind = joinpath(simlog_path, string(selected_file) )   
	if isfile(logfile_toml_ind)
		dict_simlogs_ind = TOML.parsefile(logfile_toml_ind)
		simlog_ind = from_dict(SimLog, dict_simlogs_ind["log"][selected_scenario_ind])
		sim_data_ind = simlog_to_simdata(simlog_ind)
		update_sim_data!(sim_data_ind)
		md"Expected profit = $(my_round(sim_data_ind.expected_profits))"
	end
end

# ╔═╡ c11abe2f-2304-4014-aeff-0d79827e6d48
if @isdefined sim_data_ind 
	individual_play_plt = update_plot_panel_1(sim_data_ind)
end

# ╔═╡ d28a19fa-9b9d-4163-9364-c1e632dc6216
plt_download(individual_play_plt, "individual_play_plt", @isdefined sim_data_ind )

# ╔═╡ 6c9d5065-c174-4763-a535-b9aacf4d4edc
if @isdefined sim_data_ind
	individual_bar_plt = update_plot_panel_2(sim_data_ind)
end

# ╔═╡ 9d012a60-6983-4431-99ee-1f071235486b
plt_download(individual_bar_plt, "individual_bar_plt", @isdefined sim_data_ind )

# ╔═╡ Cell order:
# ╟─18cac7f8-9fc9-465b-8200-5e4ed6e51508
# ╟─ce191084-2999-474f-aeb4-7677d7dd371d
# ╟─3dbf73df-7c3f-4c3c-bac3-13f200908d70
# ╟─84017a5c-bb38-417b-96b3-fc0c3038ce7e
# ╟─0a65842b-ffdf-4b3f-92fc-56a3f586a811
# ╟─6cd866f3-2e0d-47c9-b585-e8bac0936f6d
# ╟─97826684-aeb4-4f54-8230-722104acbbaf
# ╟─52658501-73e9-4015-80bf-bd8710dcb4e1
# ╟─801c1a4c-9201-4e23-b745-5d3e1a9bb372
# ╟─115a5ab1-6b84-4037-854f-3eff3992b7fe
# ╟─96b45736-390e-4f39-b0cf-d643ab15e39d
# ╟─f2b876d0-4f90-4367-9416-52efbc924d2d
# ╟─fe94c8b9-02ea-4613-b7ba-030b4587ac40
# ╟─2490515c-3d21-4a3b-b859-1dcc8b0f4ae6
# ╟─776b35d7-72a2-4fb1-b3b4-d3ab3249a01b
# ╟─92728155-fad1-4968-8e43-926f621728d4
# ╟─5f7cf638-cbf8-48f8-a8bb-b1ebf5ba88ab
# ╟─d04db0f4-1e2d-4c60-ace7-df4500ff6a79
# ╟─2924e14f-d466-4df4-9915-307b2c96c184
# ╟─74952e7e-23f4-451f-89df-049f95abe93f
# ╟─53b86fb2-3fe6-4670-b56e-a67dade1d0a4
# ╟─c1e0238b-b0cd-4329-8e93-bf1326e817fc
# ╟─b0919b66-42f8-47c8-926e-8f55ef2b764d
# ╟─6b0a8e5b-b86e-4dfe-9333-f50141053287
# ╟─7dffeb50-e6c3-417d-9d6b-fae25515993a
# ╟─fd3ba11b-aa62-4cb2-81de-3d33e3fc7c34
# ╟─4ecf50cb-3307-4fe2-acaf-da6e1392fff6
# ╟─909c9f8b-8c27-4279-ba89-afe0d7180ac8
# ╟─13870203-9d07-42fd-9ce9-885c8d632e2d
# ╟─cb53a24e-fe3d-488f-aac9-ac18deaca9dc
# ╟─cd4d57ed-0de6-4f0c-bb31-dc0605c64133
# ╟─f6fedebe-0a24-4503-abfd-c0b37155bb6b
# ╟─e61008ce-f581-413b-8c0b-feb4d12e1212
# ╟─bc6f34b2-6909-4de0-8666-f80b04359061
# ╟─1bb39671-cf79-4c29-a02e-f4250d5c06bc
# ╟─58994e41-e952-42b8-9c44-3e59236dff93
# ╟─c2cb2967-6033-418d-9707-f0875d592cdf
# ╟─7d6dfb80-5a6c-4559-a325-490af3da2263
# ╟─4ba5c1f0-60b2-47c9-8220-7836e84b9ce8
# ╟─71faa189-c00b-4092-939e-3f9b8013a8b2
# ╟─dc1a6bf7-8275-41ac-ac16-b3449da55239
# ╟─36fb274d-9923-4ae8-842e-ba8d6bdcaeaa
# ╟─a8bcbb70-b778-46ee-b0ab-e0846c7391c9
# ╟─be3fe754-e633-45b1-bc0e-ab1cf3aec3ac
# ╟─6f1a80c0-3ba3-42dd-9f35-135062b370e4
# ╟─e0d39e75-7064-42b3-b42f-55e4eafb3c6c
# ╟─041f4279-b7f3-495a-b036-24663f95c143
# ╟─35d6d326-258f-4041-874b-cce3dc82b437
# ╟─cfb7ebea-9c49-4af3-90cb-90cfc8be6744
# ╟─7f5c31e6-a362-46ec-abc5-0ef459d17d3b
# ╟─7fa8651e-4db4-4809-9c1c-4586a66c9e50
# ╟─f40fe0b7-9705-43b0-ae05-d3e3f069ffa9
# ╟─934295c9-210d-4625-aaa7-5493cee738c9
# ╟─0fe0d06e-0c7e-4acd-8630-634f00b3a520
# ╟─66025ac7-47d6-4c11-83fa-befff248e2ea
# ╟─bbaff929-0f20-4e58-8930-430be3f03d71
# ╟─e13c5e0b-8c9c-43a6-908d-5f5ab815933e
# ╟─cea3f4ee-5ba2-4317-ab62-8a949abf7a33
# ╟─9f16663d-0fac-47eb-9706-be738fa5d5f5
# ╟─a31d8f99-7487-4935-988b-9717c1ab9289
# ╟─6a9c9501-88c1-40c2-9eca-897a09df91c8
# ╟─83f177a7-a07f-492d-a283-252e5b9f4966
# ╟─a6bf2500-0418-488c-a5ff-69cba2e9d1f7
# ╟─47bad2aa-051e-4ef0-97b6-2d94641b1a5d
# ╟─85bbeaf7-9c14-420b-9a37-399895c6058a
# ╟─a6da3528-ab68-4695-ba3f-043443722a2a
# ╟─ae6065cc-4729-4084-abc5-68fc75500888
# ╟─03d902b7-13fc-430c-ab9b-c1842f3cb004
# ╟─c11abe2f-2304-4014-aeff-0d79827e6d48
# ╟─d28a19fa-9b9d-4163-9364-c1e632dc6216
# ╟─6c9d5065-c174-4763-a535-b9aacf4d4edc
# ╟─9d012a60-6983-4431-99ee-1f071235486b
# ╟─9955626e-3103-4d83-918f-1020ed9ef0a2
# ╟─e0d09197-fc18-46e9-b0f9-b513ea32596a
# ╟─f4694b89-3cfb-4154-a0ae-f853c8e464ad
# ╟─260482ce-3a2a-4b84-9e92-ce7bc218c51f
# ╟─1b686af7-ccc5-43e6-8da1-ab91373f3b63
# ╟─b2c19571-95b1-4b7f-9ec1-ed83ba7b8aef
# ╟─e39911c7-22de-47ca-b442-441c0f1d2657
# ╟─760bcbea-484b-4c79-ac9b-458aaeb8a083
# ╟─375b5f20-ff08-4d9a-8d41-38214db962de
# ╟─b89d8514-2b56-4da9-8f49-e464579c2293
# ╟─c8618313-9982-44e0-a110-2d75c69c75e8
# ╟─f029b8ff-e8a0-4ae3-9fdf-29ffb7189903
# ╟─c36ee104-1d6d-40b8-b992-2d8ff6f29674
# ╟─c6951037-e666-43bf-8260-b489143a550a
# ╟─b198752d-aecd-4c47-acdd-05818aa5c80c
# ╟─38d42a2a-1f93-4c92-87c4-2cbe69d1e927
# ╟─88c52658-3c0c-4aad-aaff-242fd4b85a93
# ╟─1926fa40-3da7-4acc-a30c-b9b7da13d46b
# ╟─5ea60b57-f735-41c2-86cf-de6601573719
