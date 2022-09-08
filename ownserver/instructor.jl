### A Pluto.jl notebook ###
# v0.19.11

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

# ╔═╡ e233101c-2a6e-11ec-2309-35f99e3e140e
using HTTP, PlutoUI, CSV, DataFrames, TableIO, Parameters, Plots,QuadGK, Distributions, Random,DelimitedFiles

# ╔═╡ 928a981c-d807-43df-b0a6-a39315231b66
using JLD2 , JSON3, Tables

# ╔═╡ 8b473bf7-f952-4c4f-86b0-e852614de4c8
using Configurations

# ╔═╡ 4f772739-9bed-490e-b2fe-a8ccbbae9fec
TableOfContents()

# ╔═╡ 2c763f75-528d-42ec-8955-49af21799183
md""" # ⚙  Configure session

#### Enter the base of your current url
Specifically, the part of the url that is left of `/edit?=...` in your current browser window (without the slash `/`)

👉 $(@bind baseurl TextField(default="https://teaching.frankhuettner.de"))
"""

# ╔═╡ 6c5f22fa-c88b-468b-932a-cca755277fc5
if baseurl == "https://teaching.frankhuettner.de"
	md"""
	!!! warning "Are you sure this is your base url?"
	"""
elseif baseurl[end]  == '/'
	md"""
	!!! warning "No slash at the end, please"
	"""
end

# ╔═╡ 68ef64a2-1bce-4eed-bd79-bcd12d2c6bf8
md"""#### Enter a data folder name

You can enter a course name here. **Do NOT change this later**. The data folder name is needed if you want to resume a session 👉 $(@bind course_name TextField(default=randstring(5)))

"""

# ╔═╡ 16ec98e2-bb7b-4f25-a3bb-fee74f4a5ade
md"""
Check here 👉 $(@bind session_name_fixed CheckBox(default=false))  if you have specified the name of the data folder.
"""

# ╔═╡ 328912db-30b8-4e27-97e0-5f696c00ce33
if session_name_fixed
	md"""
	!!! danger "Do not change folder name anymore"
	"""
end

# ╔═╡ 91035449-f46c-4b6d-8495-e908d3275b90
begin
	course_path = homedir() * "/data/newsvendor_simulation/" * course_name
	simlog_path = course_path * "/simlog"
	nb_path = course_path * "/notebooks"
	
	if session_name_fixed == true	
			mkpath(simlog_path)
			mkpath(nb_path)
	end	

end;

# ╔═╡ ad7c82fb-15fa-4f67-91b1-5321d67f5f41
begin 
	
	if session_name_fixed == true	
	
	# sim_source_url = "https://raw.githubusercontent.com/frankhuettner/newsvendor/main/game/newsvendorgame.jl"
	# sim_file = download(sim_source_url, nb_path * "/sim_source.jl")

		
	# link_file = download("https://raw.githubusercontent.com/frankhuettner/newsvendor/main/.ownserver/linklist.jl", course_path * "/linklist.jl")

	sim_file = cp("../game/newsvendorgame.jl", nb_path * "/sim_source.jl")
	link_file = cp("linklist.jl", course_path * "/linklist.jl")
		
	end

end;

# ╔═╡ 482fe8aa-2e60-4a8f-8261-9cc6f5065725
md"# Manage participant names"

# ╔═╡ 76ea66a1-4984-4f32-abcf-5e500c35e20f
md""" ## 📝 Make a new list of names

You can upload a csv file with names or do this with fantasy names. 
"""

# ╔═╡ 2347ac25-6efb-4fad-941e-9af00c8cb518
md""" #### 2.1. CSV or random names?
"""

# ╔═╡ cb23a309-b3e6-40f1-a79f-3eb1f4633fc9
md"""
##### Random names?
If you want random names, please specify *how many* students or teams will play  
	
👉 $( @bind num_students NumberField(1:round(Int,  (Sys.total_memory() / 2^20 - 900) / 600)) )

	


#####  ...alternatively upload a csv file

Get a csv file with student names. (For example, in Canvas LMS, go to your *course > Grades > Actions > Export* to get a csv file that contains your students names.

👉 $(@bind f PlutoUI.FilePicker())
"""

# ╔═╡ 386113d0-de74-44f0-8c44-b60ed9c65c90
md"""
Please choose your preferred option 👉 $(@bind rand_or_csv Select(["rnd_names" => "Random names", "up_names" => "Names from uploaded cvs file"], default="rnd_names"))
"""

# ╔═╡ 83c17304-b439-43ea-92c6-995993e5cfa7
md""" #### 2.2. Which column contains the names?
"""

# ╔═╡ fe15f413-03e0-4ea5-b95d-61feca21d60c
if isfile(course_path * "/df_clean.jld2")
md"""Continue with this new name list? (*Note: this will overwrite the existing name list in the $(course_name) folder*)
"""
	
else
md"""Continue with this new list?
"""
	
end

# ╔═╡ 9f98c0d7-1812-4eef-99f6-815def7a3301
begin
	make_new_df_names_gegen = [0]
	@bind make_new_df_names CounterButton("Yes, use new names")
end

# ╔═╡ 351df65f-5f2d-464d-97d0-ec085465bb91
if session_name_fixed
	if make_new_df_names > 0 || isfile(course_path * "/df_clean.jld2")
	md"""The following name list is available and will be used unless you make a new name list:
	"""

	else
	md"""No list found in this course folder. Please make a new list."""

	end
end

# ╔═╡ ccf3ce31-3948-4dd9-babf-8fc21b2662cd
md"# 🕹️ Manage simulation"

# ╔═╡ d4bd1bf9-5e22-4d29-b51b-71f20de37e01
@bind search_old_sims CounterButton("Search running or previous simulations in this class folder")

# ╔═╡ f72e5ab3-f7a4-4b33-90cc-8869ce26b14f
search_old_sims; if session_name_fixed
	if isfile(course_path * "/df_links.jld2")
	md"""The following simulations are available and will be used unless you make a new name list:
	"""

	else
	md"""No simulations found in this course folder. Please make new ones."""

	end
end

# ╔═╡ bc03ad04-d327-45ab-8fde-fa3a17bf2c3a
begin	
	if isfile(course_path * "/df_links.jld2") 
		df_links = load(course_path * "/df_links.jld2", "new_df_links")
		df_links[!,filter(x->x!="link",names(df_links))]
	end
end

# ╔═╡ 7b4bf101-f0b4-4a41-8119-5bbcfaedd489
md""" ## Choose: $(@bind old_sims Select(["yes" => "🛰️ Reconnect simulations", "no" => "🚀 Make new simulations"]))
"""

# ╔═╡ 0d17cdfd-6948-4be2-b1b7-1030e9f6b242
if old_sims == "no"

md"""You are about to start **NEW** simulations for the following players:"""
	
end

# ╔═╡ 5f491b0d-05a3-47cf-8762-65e13a336ee9
if old_sims == "yes" && isfile(course_path * "/df_links.jld2")

md"""Restart previous simulations 👉  $(@bind start_sims CheckBox(default=false))"""

elseif old_sims == "no"
	
md"""
Start new simulations (*Note: this will overwrite existing data with the same **data folder** name*): 👉  $(@bind start_sims CheckBox(default=false))
"""
	
end

# ╔═╡ 20390357-53c3-4ac9-9da7-0e541940be02
md"""# 🔗 Share links to simulation
$(@bind reload_links CounterButton("Reload links"))

Share the link below with your students. It contains the list of links to the simulations:
"""

# ╔═╡ 5652fe16-1eb8-4834-81ff-0bd6eca15c06
reload_links; if isfile(course_path * "/df_links.jld2") && @isdefined link_file
	
	loaded_df_links = load(course_path * "/df_links.jld2", "new_df_links")

	md_linklist = "##### Follow the link below to your simulation \n"
	for row in eachrow(loaded_df_links)
		global md_linklist = string(md_linklist, 
			"* ", row.name, ": \n\n   [", row.link, "](", row.link, ") \n",
						"##### ``~~``  \n"  )
	end	
	jldsave(course_path * "/md_linklist.jld2"; md_linklist)

	open_new_linklist_url = baseurl * "/open?path=" * link_file
	
	r_linklist = HTTP.request("GET", open_new_linklist_url; verbose=3)
	HTML("""
	<a href="$(baseurl * r_linklist.request.target
	)" target="_blank">$(baseurl * r_linklist.request.target
	)</a>
	""")
end

# ╔═╡ b4e41432-8ab9-4c85-b721-d0959505d51d
md"# 📊 Load student's sim data"

# ╔═╡ 475f9182-8b8e-414d-aa3c-b0ebb916265c
@bind reload_stud_data CounterButton("Reload data from students")

# ╔═╡ 42296e16-a1fa-4fbf-aaf2-575cb18f5b2a
md"""# Appendix

## Packages
"""

# ╔═╡ 8479288e-7c24-4e4a-afda-41e030bcab1e
md"## Fantasy names"

# ╔═╡ 31d9ff4f-c5eb-4d07-929c-46c86464f04e
begin
	fantasy_names =["Astra","Aura","Auris","Blissia","Blossom","Celestia","Cosmic","Crystal","Dark Rain","Diamond","Electra","Gold Horn","Golden Moon","Jewel","Luna","Majesty","Midnight","Milky Way","Mystique","Night Moon","Nightshade","Nightwind","Onnyx","Pearl Moon","Rainbow","Sapphire","Silver Star","Snowflake","Solstice","Star Light","Starburst","Stardust","Sterling","Sunshine","Twilight","Twinkle","Usha","Wilda","Wynstar","Zinnia"]
	fantasy_names = vec([n1*" "*n2 for n1 in fantasy_names, n2 in fantasy_names])
end

# ╔═╡ 1bf9f96f-4288-421e-936d-2bbdfbd7a4f8
if rand_or_csv=="up_names" && typeof(f) != Nothing
	df_students = DataFrame(CSV.File(f["data"]))
elseif rand_or_csv=="rnd_names" 
	df_students = DataFrame( names = sample(fantasy_names,num_students, 
											replace=false,ordered=true), 
								ID = 1:num_students
					)
end

# ╔═╡ 49c8ba1c-c76f-4ea2-be50-1ab081c216c8
if @isdefined df_students
	md"""
Which **col**umn contains the **names**?  $(@bind name_col_nr NumberField(1:ncol(df_students); default=1))

Which **col**umn contains an ID, email, or other informtion you want to keep track of as well?  $(@bind id_col_nr NumberField(1:10; default=ncol(df_students)
)) (Note that this can be the name as well but sometimes it is nice to have an id number as well.)
"""
end

# ╔═╡ 2ee713ac-2c68-4bbd-85fc-1ebe287b81b9
if @isdefined df_students
	if name_col_nr == id_col_nr
		new_df_clean = copy(df_students[!, [name_col_nr]])
		new_df_clean = DataFrame(name=new_df_clean[!, 1])		
	else
		new_df_clean = copy(df_students[!, [name_col_nr, id_col_nr]])
		new_df_clean = DataFrame(name=new_df_clean[!, 1], ID=new_df_clean[!, 2])
	end
	new_df_clean = new_df_clean[completecases(new_df_clean), :]
	if new_df_clean[1,1] == "    Points Possible"
		delete!(new_df_clean, 1)
	end
	new_df_clean
end

# ╔═╡ b6a84dfe-3da0-456f-820d-afc3c9d1d065
begin
	if make_new_df_names > make_new_df_names_gegen[end]
		jldsave(course_path * "/df_clean.jld2"; new_df_clean)
		push!(make_new_df_names_gegen, make_new_df_names)
	end
	
	if isfile(course_path * "/df_clean.jld2")
		df_clean = load(course_path * "/df_clean.jld2", "new_df_clean")
	end
end

# ╔═╡ 88c50897-2236-4637-ae16-987b34184155
if  @isdefined start_sims
	
	
if session_name_fixed && start_sims && old_sims=="no" && @isdefined df_clean

	new_df_links = copy(df_clean)
	insertcols!(new_df_links, :link => "")
	insertcols!(new_df_links, :token => "")

	for row in eachrow(new_df_links)
		sleep(.1)

		row.token = randstring(8)
		cp(nb_path * "/sim_source.jl", nb_path * "/" * row.token * ".jl", force=true)

		r = HTTP.request("GET",
						baseurl * "/open?path=" * nb_path * "/" * row.token * ".jl"; 
						verbose=3)
		row.link = baseurl * r.request.target
	end
	new_df_links[!,filter(x->x!="link",names(new_df_links))]
	jldsave(course_path * "/df_links.jld2"; new_df_links)



elseif session_name_fixed && start_sims && old_sims=="yes"

	new_df_links = load(course_path * "/df_links.jld2", "new_df_links")
	for row in eachrow(new_df_links)
		sleep(.1)

		r = HTTP.request("GET",
						baseurl * "/open?path=" * nb_path * "/" * row.token * ".jl"; 
						verbose=3)
		row.link = baseurl * r.request.target
	end
	new_df_links[!,filter(x->x!="link",names(new_df_links))]
	jldsave(course_path * "/df_links.jld2"; new_df_links)

end
	
	
end

# ╔═╡ 7b7864b5-eeba-43ec-aabb-42b43618ea22
if @isdefined new_df_links
	new_df_links
end

# ╔═╡ f379eb78-8c81-4b4e-bd22-a10d42c81cbc
if old_sims == "no"

	new_df_clean
end

# ╔═╡ 1b275f91-7f88-4cc7-bc2a-1a1bc8424782


# ╔═╡ e69851f1-ac85-41f4-b14a-3dcecca3df5a
md"## Data structs"

# ╔═╡ 9d997283-f418-4027-93cf-0086fda84498
struct TwoColumn{L, R}
    left::L
    right::R
end; md"TwoColumn"

# ╔═╡ b359302b-50b1-4b51-b4c4-23a772dd5949
struct Foldable{C}
    title::String
    content::C
end; md"Foldable"

# ╔═╡ 59a318dc-34e5-4f04-ae8b-dfa06ccc87b4
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

# ╔═╡ a6c5660e-b166-4705-9419-a5117fd6ce6a
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

# ╔═╡ f607bbcd-978f-44bf-ac16-92436bdd2599
md"## Functions"

# ╔═╡ 879a6143-adf3-4a84-b077-11590f3f878d
function compute_expected_values(qs::Vector{<:Number}, scenario::Scenario) 
	n_days = length(qs)
	if n_days == 0 return zeros(1,4) end

	expected_values = Matrix{Number}(undef, n_days, 4)

	for i in 1:n_days
		expected_values[i,:] = compute_expected_values(qs[i], scenario) 
	end

	return mean(expected_values, dims=1)
end

# ╔═╡ d0869f0d-ad56-4933-9382-1ec377efa972
function L(f, x, u)
	L, _ = quadgk(y -> (y - x) * f(y), x, u, rtol=1e-8)
	return L
end; md" L(x) = ∫ₓᵘ (y - x)f(y)dy"

# ╔═╡ 252cc44e-303f-47cd-a0c8-8d2510d055c6
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

# ╔═╡ 7e102ea4-96b9-41c4-9a10-1cca93a92d07
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

# ╔═╡ 859cceef-c4cb-4287-a8f9-52309c90f98d
function my_round(x::Real; sigdigits::Int=3)
	x = round(x, sigdigits=sigdigits)
	if x >= 10^(sigdigits-1)
		Int(x)
	else
		x
	end
end

# ╔═╡ b9e86627-861f-496e-870a-f894f400465b
function Base.show(io, mime::MIME"text/html", tc::TwoColumn)
    write(io, """<div style="display: flex;"><div style="flex: 50%;">""")
    show(io, mime, tc.left)
    write(io, """</div><div style="flex: 50%;">""")
    show(io, mime, tc.right)
    write(io, """</div></div>""")
end; md"""Displaying TwoColumns, e.g. `TwoColumn(md"Note the kink at x=0!", plot(-5:5, abs))` """

# ╔═╡ 9d29630a-1188-40b3-a32e-1716add04e8e
function mem_available() 
	run(pipeline(`grep MemAvailable /proc/meminfo`, simlog_path*"/MemAvailable.txt"))
	parse(Int,(strip(chop(readdlm(simlog_path*"/MemAvailable.txt", ':')[1,2],tail=2))))
end

# ╔═╡ ae87a8dc-9dcc-48f4-a812-aea527381d78
if !isfile(course_path * "/df_links.jld2") && old_sims=="yes"
	md"""
	!!! warning "Wait, there are no simulations in this course folder!"
	"""
elseif !start_sims && @isdefined df_clean
	if Int(floor(mem_available() / 2^10 / 550)) >= nrow(df_clean)
		md"""
		You have enough memory for **$(Int(floor(mem_available() / 2^10 / 550)))** independent simulations; you are about to lauch **$(nrow(df_clean))** simulations.
		!!! tip "Let do it!"
		"""
	else
		md"""
		You have enough memory for $(Int(floor(mem_available() / 2^10 / 550))) parallel simulations; you are about to lauch $(nrow(df_clean)) simulations.
		!!! danger "Not enough memory, 🤔 server might freeze!"
		"""
	end
elseif start_sims
	md"""
	!!! danger "Simulation started. Do not change parameters above"
	"""
end

# ╔═╡ dd013efb-b807-4156-9db7-10c6a086b01e
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

# ╔═╡ 30a74ff2-a837-4712-90e4-3b6a80017e0d
reload_stud_data; if isfile(course_path * "/df_links.jld2")
	
	df_res = load(course_path * "/df_links.jld2", "new_df_links")
	insertcols!(df_res, :DaysPlayed => 0, 
						:ExpProfit => 0.0,
						:AvgStock => 0.0, 
						:AvgDemand => 0.0, 
						:TotalProfit => 0.0, 
						)
	profit_opt = 0
	
	for row in eachrow(df_res)
		logfile_name = "simlog_" * string(row.token) * ".jld2"
		if isfile(simlog_path * "/" * logfile_name)
			sim_datas = load(simlog_path * "/" * logfile_name, "sim_datas")

			sd = sim_datas["cheers_1"]
			
			row.DaysPlayed = sd.days_played
			
			row.ExpProfit = sd.expected_profits
			
			row.AvgStock = sd.avg_q
			row.AvgDemand = sd.avg_demand
			row.TotalProfit = sd.total_profit
		
			q_opt = sd.scenario.q_opt
			profit_opt = compute_expected_values(sd.scenario.q_opt, sd.scenario )[4]    
		end
	end
	df_res = df_res[df_res[!, :DaysPlayed].!=0,:]
	# df_res[!, filter(x->x !="link" , names(df_res))]
	df_res[!, filter(x->x !="" , names(df_res))] |> data_table
end

# ╔═╡ 277830f6-ff48-4c5b-ac81-97088bff16df
if @isdefined df_res 
	if nrow(df_res) > 0
		plt_dem_vs_q = histogram(df_res[!,:AvgDemand], label="Average Demand", dpi=300)
		histogram!(df_res[!,:AvgStock], label="Average Stock")
		savefig(course_path * "/Demand_vs_Order.png")
		plt_dem_vs_q
	end
end

# ╔═╡ 25b293e4-04fc-4936-95b7-c41c83230c92
if @isdefined df_res 
	if nrow(df_res) > 0
		df_profit = copy(df_res)
		sort!(df_profit, [order(:ExpProfit, rev=true)])



		ticklabel = string.(df_profit[!,:name])
		plt_profit = bar(df_profit[!,:ExpProfit],  size=(750,800), dpi=300,
							yticks=(1:length(ticklabel), ticklabel),
			orientation=:h, legend=false, title="Expected profit", yflip=true)

		vline!([profit_opt], lw=1)

		savefig(course_path * "/ExpProfits.png")
		plt_profit
	end
end

# ╔═╡ 9684edcc-c28f-4704-bc45-fd9680122353
md"## System Data"

# ╔═╡ 354a12c8-7557-4365-b09c-4f6a167f54eb
read("/proc/meminfo", String)

# ╔═╡ 795fffb5-093e-49ac-9186-8a23e2287ea2
with_terminal() do
	run(`egrep --color 'Mem|Cache|Swap' /proc/meminfo`)
end

# ╔═╡ 6c07755b-4aaf-44ee-95b5-3f974d03c1da
length(Sys.cpu_info())

# ╔═╡ 84279cdc-12fb-4af8-b31c-ad2ddbdb4514
Threads.nthreads()

# ╔═╡ 277be6ad-0b96-48fd-ab9f-179041725b65
md"## Configurations"

# ╔═╡ 4bd8bb71-122e-4232-a043-28831249311a
md"### Options"

# ╔═╡ 4434e3c2-1526-4453-beb6-bd21acfb4748
@option struct SimLog
	player_id::String = "Frank Huettner"
	play::PlayLog = PlayLog()
	scenario::ScenarioLog = ScenarioLog()
end

# ╔═╡ 66fa1042-496b-4bc8-b48f-d4535730a2d7
@option struct PlayLog
	demands::Vector{<:Number} = round.(Int, rand(TruncatedNormal(90, 30, 0, 180), 30))
	qs::Vector{<:Number} = Vector{Int64}()
end

# ╔═╡ e278947e-3f7d-404a-bf99-1d0720de1a99
@option struct ScenarioLog
	name::String="cheers_1"
	unit_value::UnitValueLog = UnitValueLog()
	distribution::DistributionLog = DistributionLog()
	story::StoryLog = StoryLog()	
	sim_conf::SimConfLog = SimConfLog()
end

# ╔═╡ 9da71e91-12a1-4c61-bb49-92fafe74cedc
@option struct StoryLog
	title::String = "Patisserie Cheers!"
	url::String = "https://raw.githubusercontent.com/frankhuettner/newsvendor/main/scenarios/cheers_1_story.md"
end

# ╔═╡ a04d62f1-0e5c-40d3-bf0d-b251f3983313
@option struct UnitValueLog
	c::Real = 1 	# cost of creating one unit
	p::Real = 5  	# selling price
	s::Real = 0    # salvage value
end

# ╔═╡ e3dac4fc-1c3f-42e7-9bfe-f6741a38a789
@option struct DistributionLog
	typus = "Truncated Normal"
	l::Real = 0 	# lower bound
	u::Real = 180		# upper bound
	μ::Real = (u - l)/2	 # mean demand
	σ::Real = (u - l)/6 	# standard deviation of demand
	discrete_probs = [pdf(TruncatedNormal(90, 30, 0, 180), x) / 
				sum(pdf(TruncatedNormal(90, 30, 0, 180), 1:180))  for x in 1:180]
end

# ╔═╡ 328895a7-7d6e-471b-a3c1-37e2c056c5c0
@option struct SimConfLog
	max_num_days::Int = 30  # Maximal number of rounds to play
	delay::Int = 300    # ms it takes for demand to show after stocking decision 
	allow_reset::Bool = false
end

# ╔═╡ 2e732623-1df4-4f52-8719-a094bfd82be1
md"### Helper functions"

# ╔═╡ 22f48fe6-ec00-4d28-8ecf-ccdab51b4689
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

# ╔═╡ 396780ba-305e-4c13-8041-213718faefb0
function simlog_to_simdata(simlog)
	sd = SimData(				
		scenario = scenariolog_to_scenario(simlog.scenario),
		demands = simlog.play.demands,
		qs =  simlog.play.qs,
	)
	update_sim_data!(sd)
	return sd
end

# ╔═╡ 740ddc5b-7ac0-42e0-a21e-b911b05f163b
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
end

# ╔═╡ 7210cdee-152c-413c-9d52-76557dd3d4f7
function simdata_to_simlog(simdata) 
	player = my_ID()
	playlog = from_kwargs(PlayLog, qs = simdata.qs, demands = simdata.demands)
	scl = scenario_to_scenariolog(simdata.scenario)
	
	return SimLog(player_id = my_ID(), play = playlog, scenario = scl)
end

# ╔═╡ d5267335-cd8f-43f9-8c14-e2bcdfa2c12a
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

# ╔═╡ 0a47f159-cce0-4535-a709-16fc24a16398
function save_available_scenario_conf(available_scenarios=available_scenarios, path="")	
	d = Dict([sc.name => sc.name*"_conf.toml"  for sc in available_scenarios])
	
	open(path*"available_scenario_confs.toml", "w") do io
		TOML.print(to_toml, io, d)
	end
	
	for sc in available_scenarios
		to_toml(path*sc.name*"_conf.toml", sc |> scenario_to_scenariolog)
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
Configurations = "5218b696-f38b-4ac9-8b61-a12ec717816d"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
DelimitedFiles = "8bb1440f-4735-579b-a4ab-409b98df4dab"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"
JLD2 = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
Parameters = "d96e819e-fc66-5662-9728-84c9c7592b0a"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
QuadGK = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
TableIO = "8545f849-0b94-433a-9b3f-37e40367303d"
Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[compat]
CSV = "~0.9.8"
Configurations = "~0.17.0"
DataFrames = "~1.2.2"
Distributions = "~0.25.20"
HTTP = "~0.9.16"
JLD2 = "~0.4.15"
JSON3 = "~1.9.2"
Parameters = "~0.12.3"
Plots = "~1.22.6"
PlutoUI = "~0.7.16"
QuadGK = "~2.4.2"
TableIO = "~0.3.4"
Tables = "~1.6.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

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

[[CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "29728b5bf89047611c189f412f3325fff993711b"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.9.8"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "d9e40e3e370ee56c5b57e0db651d8f92bce98fea"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.10.1"

[[CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

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
git-tree-sha1 = "31d0151f5716b655421d9d75b7fa74cc4e744df2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.39.0"

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

[[Crayons]]
git-tree-sha1 = "3f71217b538d7aaee0b69ab47d9b7724ca8afa0d"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.0.4"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "d785f42445b63fc86caa08bb9a9351008be9b765"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.2.2"

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

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[Distributions]]
deps = ["ChainRulesCore", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SparseArrays", "SpecialFunctions", "Statistics", "StatsBase", "StatsFuns"]
git-tree-sha1 = "9809cf6871ca006d5a4669136c09e77ba08bf51a"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.20"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "a32185f5428d3986f47c2ab78b1f216d5e6cc96f"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.5"

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

[[FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "3c041d2ac0a52a12a27af2782b34900d9c3ee68c"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.11.1"

[[FilePathsBase]]
deps = ["Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "7fb0eaac190a7a68a56d2407a6beff1142daf844"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.12"

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

[[Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "d189c6d2004f63fd3c91748c458b09f26de0efaa"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.61.0"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "cafe0823979a5c9bff86224b3b8de29ea5a44b2e"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.61.0+0"

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
git-tree-sha1 = "f6532909bf3d40b308a0f360b6a0e626c0e263a8"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.1"

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

[[InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "19cb49649f8c41de7fea32d089d37de917b553da"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.0.1"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "f0c6489b12d28fb4c2103073ec7452f3423bd308"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.1"

[[InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

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

[[JLD2]]
deps = ["DataStructures", "FileIO", "MacroTools", "Mmap", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "46b7834ec8165c541b0b5d1c8ba63ec940723ffb"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.15"

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
git-tree-sha1 = "c7f1c695e06c01b95a67f0cd1d34994f3e7db104"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.2.1"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "669315d963863322302137c4591ffce3cb5b8e68"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.8"

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
deps = ["ChainRulesCore", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "6193c3815f13ba1b78a51ce391db8be016ae9214"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.4"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "5a5bc6bf062f0f95e62d0fe0a2d99699fed82dd9"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.8"

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
git-tree-sha1 = "4dd403333bcf0909341cfe57ec115152f937d7d8"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.1"

[[Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "f19e978f81eca5fd7620650d7dbea58f825802ee"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.0"

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
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs"]
git-tree-sha1 = "ba43b248a1f04a9667ca4a9f782321d9211aa68e"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.22.6"

[[PlutoUI]]
deps = ["Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "4c8a7d080daca18545c56f1cac28710c362478f3"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.16"

[[PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a193d6ad9c45ada72c14b731a318bedd3c2f00cf"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.3.0"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "d940010be611ee9d67064fe559edbb305f8cc0eb"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.2.3"

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

[[SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "54f37736d8934a12a200edea2f9206b03bdf3159"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.7"

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
git-tree-sha1 = "2d57e14cd614083f132b6224874296287bfa3979"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "1.8.0"

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
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "95072ef1a22b057b1e80f73c2a89ad238ae4cfff"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.12"

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

[[TableIO]]
deps = ["DataFrames", "Requires", "TableIOInterface", "Tables"]
git-tree-sha1 = "57ced5fc739318cdff9e561c403cacb494beb982"
uuid = "8545f849-0b94-433a-9b3f-37e40367303d"
version = "0.3.4"

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

[[TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

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

[[WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "c69f9da3ff2f4f02e811c3323c22e5dfcb584cfa"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.1"

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
# ╟─4f772739-9bed-490e-b2fe-a8ccbbae9fec
# ╟─2c763f75-528d-42ec-8955-49af21799183
# ╟─6c5f22fa-c88b-468b-932a-cca755277fc5
# ╟─68ef64a2-1bce-4eed-bd79-bcd12d2c6bf8
# ╟─328912db-30b8-4e27-97e0-5f696c00ce33
# ╟─16ec98e2-bb7b-4f25-a3bb-fee74f4a5ade
# ╟─91035449-f46c-4b6d-8495-e908d3275b90
# ╟─ad7c82fb-15fa-4f67-91b1-5321d67f5f41
# ╟─482fe8aa-2e60-4a8f-8261-9cc6f5065725
# ╟─351df65f-5f2d-464d-97d0-ec085465bb91
# ╟─b6a84dfe-3da0-456f-820d-afc3c9d1d065
# ╟─76ea66a1-4984-4f32-abcf-5e500c35e20f
# ╟─2347ac25-6efb-4fad-941e-9af00c8cb518
# ╟─cb23a309-b3e6-40f1-a79f-3eb1f4633fc9
# ╟─386113d0-de74-44f0-8c44-b60ed9c65c90
# ╟─1bf9f96f-4288-421e-936d-2bbdfbd7a4f8
# ╟─83c17304-b439-43ea-92c6-995993e5cfa7
# ╟─49c8ba1c-c76f-4ea2-be50-1ab081c216c8
# ╟─2ee713ac-2c68-4bbd-85fc-1ebe287b81b9
# ╟─fe15f413-03e0-4ea5-b95d-61feca21d60c
# ╟─9f98c0d7-1812-4eef-99f6-815def7a3301
# ╟─ccf3ce31-3948-4dd9-babf-8fc21b2662cd
# ╟─d4bd1bf9-5e22-4d29-b51b-71f20de37e01
# ╟─f72e5ab3-f7a4-4b33-90cc-8869ce26b14f
# ╟─bc03ad04-d327-45ab-8fde-fa3a17bf2c3a
# ╟─7b4bf101-f0b4-4a41-8119-5bbcfaedd489
# ╟─0d17cdfd-6948-4be2-b1b7-1030e9f6b242
# ╟─f379eb78-8c81-4b4e-bd22-a10d42c81cbc
# ╟─ae87a8dc-9dcc-48f4-a812-aea527381d78
# ╟─5f491b0d-05a3-47cf-8762-65e13a336ee9
# ╟─88c50897-2236-4637-ae16-987b34184155
# ╟─7b7864b5-eeba-43ec-aabb-42b43618ea22
# ╟─20390357-53c3-4ac9-9da7-0e541940be02
# ╟─5652fe16-1eb8-4834-81ff-0bd6eca15c06
# ╟─b4e41432-8ab9-4c85-b721-d0959505d51d
# ╟─475f9182-8b8e-414d-aa3c-b0ebb916265c
# ╟─30a74ff2-a837-4712-90e4-3b6a80017e0d
# ╟─277830f6-ff48-4c5b-ac81-97088bff16df
# ╟─25b293e4-04fc-4936-95b7-c41c83230c92
# ╟─42296e16-a1fa-4fbf-aaf2-575cb18f5b2a
# ╠═e233101c-2a6e-11ec-2309-35f99e3e140e
# ╠═928a981c-d807-43df-b0a6-a39315231b66
# ╟─8479288e-7c24-4e4a-afda-41e030bcab1e
# ╟─31d9ff4f-c5eb-4d07-929c-46c86464f04e
# ╠═1b275f91-7f88-4cc7-bc2a-1a1bc8424782
# ╟─e69851f1-ac85-41f4-b14a-3dcecca3df5a
# ╟─9d997283-f418-4027-93cf-0086fda84498
# ╟─b359302b-50b1-4b51-b4c4-23a772dd5949
# ╟─59a318dc-34e5-4f04-ae8b-dfa06ccc87b4
# ╟─a6c5660e-b166-4705-9419-a5117fd6ce6a
# ╟─f607bbcd-978f-44bf-ac16-92436bdd2599
# ╟─7e102ea4-96b9-41c4-9a10-1cca93a92d07
# ╟─252cc44e-303f-47cd-a0c8-8d2510d055c6
# ╟─879a6143-adf3-4a84-b077-11590f3f878d
# ╟─d0869f0d-ad56-4933-9382-1ec377efa972
# ╟─859cceef-c4cb-4287-a8f9-52309c90f98d
# ╟─b9e86627-861f-496e-870a-f894f400465b
# ╟─9d29630a-1188-40b3-a32e-1716add04e8e
# ╟─dd013efb-b807-4156-9db7-10c6a086b01e
# ╟─9684edcc-c28f-4704-bc45-fd9680122353
# ╠═354a12c8-7557-4365-b09c-4f6a167f54eb
# ╠═795fffb5-093e-49ac-9186-8a23e2287ea2
# ╠═6c07755b-4aaf-44ee-95b5-3f974d03c1da
# ╠═84279cdc-12fb-4af8-b31c-ad2ddbdb4514
# ╠═277be6ad-0b96-48fd-ab9f-179041725b65
# ╠═8b473bf7-f952-4c4f-86b0-e852614de4c8
# ╟─4bd8bb71-122e-4232-a043-28831249311a
# ╟─4434e3c2-1526-4453-beb6-bd21acfb4748
# ╟─66fa1042-496b-4bc8-b48f-d4535730a2d7
# ╟─e278947e-3f7d-404a-bf99-1d0720de1a99
# ╟─9da71e91-12a1-4c61-bb49-92fafe74cedc
# ╟─a04d62f1-0e5c-40d3-bf0d-b251f3983313
# ╟─e3dac4fc-1c3f-42e7-9bfe-f6741a38a789
# ╟─328895a7-7d6e-471b-a3c1-37e2c056c5c0
# ╟─2e732623-1df4-4f52-8719-a094bfd82be1
# ╟─22f48fe6-ec00-4d28-8ecf-ccdab51b4689
# ╟─396780ba-305e-4c13-8041-213718faefb0
# ╟─740ddc5b-7ac0-42e0-a21e-b911b05f163b
# ╟─7210cdee-152c-413c-9d52-76557dd3d4f7
# ╟─d5267335-cd8f-43f9-8c14-e2bcdfa2c12a
# ╟─0a47f159-cce0-4535-a709-16fc24a16398
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002