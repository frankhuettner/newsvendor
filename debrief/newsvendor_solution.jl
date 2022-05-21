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

# ╔═╡ e0d09197-fc18-46e9-b0f9-b513ea32596a
begin
	using PlutoUI, Plots, Statistics, Images, LaTeXStrings, DataFrames,ShortCodes,TOML,QuadGK,Parameters,Configurations, JSON3
	
	md""
end

# ╔═╡ 1f4c415d-97ea-4d27-a205-d6e9b45a01ca
using NewsvendorModel, Distributions; md"`using NewsvendorModel,Distributions`"

# ╔═╡ 09161f05-8c44-4f88-b45a-f80d5da136d6




# ╔═╡ ba5fa42c-345e-4418-823f-b622febde2ee
md""" # I) Quantifying the Cost of Mismatch 
"""

# ╔═╡ f162d77a-9ee1-4a98-a4e9-a6441a89dbee


# ╔═╡ a71d9b77-0f3e-4b8a-8279-7fe9997f4c35
md"""
## What Contributes to Overerage Cost?

 Cₒ are rather well defined (money wasted)

> ** + Cost** of stocking a unit (production or procurement cost)

> ** -- Salvage** value (What is a unit worth after the selling period?)

>  ** +** Cost of **holding** inventory (capital, warehousing, administration, etc.)

"""

# ╔═╡ ec27255a-1f76-483d-8900-1ab1368e5a60


# ╔═╡ ebc29bbf-2f8f-461f-9dc0-899d0c771c62
md"""
## What Contributes to Underage Cost?

Cᵤ are less tangible (forgone profit)

> ** + Margin** of a unit (= Selling **Price** -- **Cost** of stocking of a unit) 

> ** -- Substitute** margin from replacing a unit with another product or with a delayed provision

>   +  **Badwill** or penalty from having customer unserved (backorder discount, lost goodwill, lost customer life time value, reputation loss, compensation claims...)






"""

# ╔═╡ 4dbc0052-81bc-4b81-bd0b-c536788ff6bf


# ╔═╡ b267ab57-05e4-494d-9ed4-54d968003e8a
md""" ## Critical Fractile (CF)

!!! tip "Definition "
    ``\qquad \text{CF} = \dfrac{\text{Cost of underage}}{\text{Cost of underage + Cost of overage}} = \dfrac{C_u}{C_u + C_o}``



"""

# ╔═╡ be019d95-a3b7-4b0b-a047-4100d48ae05f
md"""
The **critical fractile** tells us how costly it is to understock if we keep in mind that the alternative is to overstock, and that the underage cost must be seen in relation to the overage cost.
"""

# ╔═╡ 61300264-4844-4925-8c2a-38bec150a759


# ╔═╡ a93782c2-61b5-4ab5-a122-eda5a4d8d2c2


# ╔═╡ 4df81f21-d69b-4a2a-93b2-c476cfc80383
md"""
# II) Quantifying the Probabilities of Mismatch


!!! tip "Definition: Expected Service Level (SL)"
	The **Expected Service Level (SL)** for a chosen quantity is the probability of NOT running out of stock if we stock that quantity.

➡  Chance of running of out stock = 100% -- SL 

"""

# ╔═╡ b96affe0-c626-48b7-a9fd-7286636f0813


# ╔═╡ 366266d9-7cff-44b7-9f2e-8151b2d25f07


# ╔═╡ d5c0d931-92c7-4e62-806e-14bd52c0e9af
md"""
## Quantity Needed To Achieve A Targeted SL
👉 Move this slider to change the desired service level: $(@bind my_SL_percent Slider(1:99, default=50, show_value=true))%"""

# ╔═╡ 7772adfc-7748-4a6f-8cf1-6e33f935e9b7


# ╔═╡ f193e41d-5b06-46f2-b825-2727a84a12d3
md"""
## Service Level vs. [68-95-99.7-Rule](https://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule) 
👉 Select:  $(@bind SL_vs_68 Select([1 => "68%", 2 => "95%", 3 => "99.7%"]))
"""

# ╔═╡ 96b69341-1e89-4c23-afb9-651e6fd09e64


# ╔═╡ d9485017-6d38-45b0-a9ed-e32ea87e88e7
md"""
# III) Finding the Optimal Quantity

How much quantity should we stock? The answer combines:

##### Critical fractile (CF)
* How costly is understocking compared to overstocking?
* Computed from unit values; not computed from demand
* High CF ➡ you **want** to stock high quantity Q

##### Expected Service level (SL)
* Probability of satisfying all demand if we stock some chosen quantity Q
* Relates chosen quantity Q with demand
* Stocking high quantity Q ➡ you **get** a high SL
"""

# ╔═╡ a8f9c09c-93be-4a4f-9883-5432204f0ba8


# ╔═╡ c3001041-4c4a-4325-bff3-a4143c7c47df


# ╔═╡ baa48e2b-0ba2-4b5e-96e4-925d1c641a0c
md"""
👉 Change your quantity (Q): $(@bind q_impact Slider(1:180, default=90, show_value=true))🍰

"""

# ╔═╡ 933e018f-7229-4e29-b1ae-c07a19772213


# ╔═╡ 33f4e807-5329-4edc-8b5e-a1cd46c60594
md"""
# Optimality Condition and Recipe

!!! danger "Optimality Condition"
	**Critical Fractile (CF)  = Service Level (SL)**


	
!!! tip "Getting the optimal quantity"
	Step 0) Collect demand data and obtain mean μ and standard deviation σ.

	Step 1) **Compute** the cost of underage **Cᵤ** and the cost of overage **Cₒ**.

	Step 2) **Compute** the critical fracile **CF = Cᵤ / (Cᵤ + Cₒ)**.

	Step 3) Find the quantity so that the implied service level equals CF. Excel gives this quantity with the **Formula `=Norm.Inv(CF, μ, σ)`**

"""

# ╔═╡ 2b7fbb27-fb33-47cd-82aa-a93d8020cad3


# ╔═╡ 31109c8e-14a9-446b-a2ff-ac34dcc12ed1


# ╔═╡ 9a36dbb8-6e14-433c-a691-f61c9fc5b7d0
md"""
	## Solution Exercises (Original Case: Q* = 115)
	
	"""

# ╔═╡ 705ca167-c84c-4ecf-b812-afe5009339a5


# ╔═╡ 7535fbbe-763b-49d8-9e82-cc28ed69ef9d
md"""
## Excel `=Norm.Inv(probability, mean, standard_dev)` 
👉 Choose `probability`: $(@bind norm_inv_SL Slider(1:99, default=80, show_value=true))%

👉 Type in `mean`: $(@bind norm_inv_μ NumberField(50:1000, default=90)) ``~~~~~~~~~``
👉 Type in `standard_dev`: $(@bind norm_inv_σ NumberField(1:1000, default=30))


"""

# ╔═╡ 317a6eff-8d57-46ff-9732-3298e9166141
let
	gr()
	μ = norm_inv_μ;	σ = norm_inv_σ; my_SL_percent = norm_inv_SL
	distr = Normal(μ, σ)
	
	xs = μ-3*σ:1:μ+3*σ
	p = plot(xlim=(μ-3*σ,μ+3*σ), ylabel=" \n How likely", yaxis=nothing)
	
	my_SL = my_SL_percent / 100
	x_lower = μ-3*σ
	x_upper = quantile(distr, my_SL)
	interval = x_lower:x_upper

	res = round(Int,x_upper)
	
	plot!(p, xs, pdf.(distr,xs), lw=5)
	plot!(p, interval, x->0, fillrange = pdf.(distr,interval),
		size = (700,300),
		fillalpha = 0.35, 
		 c = :purple,
		legend=:false )
	
	annotate!(p, 0.99*x_upper, 0.001, text("=Norm.Inv($my_SL_percent, $μ, $σ)\n= $(res)",15, :green, rotation = 90 , :navy, :left))
	vline!( [x_upper], lc=:navy, lw=3)
	

	annotate!(p, (res+μ+3*σ)/2, 0.1*pdf.(distr,μ), 
		text("$(100-my_SL_percent)% ",28, :grey))
	
	annotate!(p, (res+μ-3*σ)/2, 0.1*pdf.(distr,μ), 
		text("$(my_SL_percent)% ",28, :purple))
	
end

# ╔═╡ 292aa62b-a312-4292-8601-b90f3f98dc4f
md"`=Norm.Inv(probability, mean, standard_dev)` finds the quantity such that the curve is split, with $(norm_inv_SL)% of the area (i.e., probability) being to the left."

# ╔═╡ 1c5bbd84-5a75-4a72-9ce1-b60e87705ec7
md"""
## Solve the Newsvendor Model with [Julia Language](https://julialang.org/)

We use the [NewsvendorModel.jl package](https://www.huettner.io/NewsvendorModel.jl/dev/) and also load the Distributions package

"""

# ╔═╡ e4573f83-8a3e-4544-aed3-87a49ff7677b
md"""
First, specify the demand distribution (e.g. Poisson with λ = 20): `d = Poisson(20)`
"""

# ╔═╡ 77144dfb-312d-4458-83b4-1dda1f24cca4
d = Poisson(20)

# ╔═╡ 5bcbd57a-a3f6-4333-93d6-6cf111b43ee6
md"""
Next, define the model (we use the coffee beans example):

	model = NVModel(demand=d, price = 40, cost = 15, 
					salvage = 0.1 * 32 + 0.9 * 12, 
					holding = 0.1 * 5, 
					substitute = 0.5 * 10, 
					backorder = 0.4 * (40 - 15),
			)
"""

# ╔═╡ efcaebd0-0d23-468f-b637-c50f5ceda888
model = NVModel(demand=d, price = 40, cost = 15, 
					salvage = 0.1 * 32 + 0.9 * 12, 
					holding = 0.1 * 5, 
					substitute = 0.5 * 10, 
					backorder = 0.4 * (40 - 15),
			)

# ╔═╡ 2b565e17-c120-43a2-92b1-b29cc29e9da6
md""" Finally, solve the model:  `solve(model)`
"""

# ╔═╡ 12c1316d-f830-48e0-8823-585e7a11fe3e
solve(model)

# ╔═╡ 9b7657b1-0053-45c1-8d7b-5db69e42f7e1


# ╔═╡ 19975a48-0f5f-4f8b-903c-3d93181d81a1
md"""
## References

The origin of the Newsvendor model in its moder version
- K. J. Arrow, T. Harris, J. Marshak, Optimal Inventory Policy, Econometrica 1951

Books for diving deeper
- Cachon, G., and Terwiesch, C.  Matching Supply With Demand: An Introduction To Operations Management. McGraw Hill, 2012.
- Nahmias, S. and Olsen, T.L., 2015. Production and operations analysis. Waveland Press.
- $(DOI("10.1007/978-1-4939-9606-3"))

Empirics on stock-outs
- $(DOI("10.1287/mnsc.1060.0577"))

Decision biases
- $(DOI("10.1287/mnsc.1120.1617"))
- $(DOI("10.1287/mnsc.46.3.404.12070"))
- $(DOI("10.1037/0893-164X.13.4.339"))


"""

# ╔═╡ a6bf2500-0418-488c-a5ff-69cba2e9d1f7


# ╔═╡ 47bad2aa-051e-4ef0-97b6-2d94641b1a5d


# ╔═╡ c580aaae-7e6b-4a74-b360-d0e99322b82c


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
	
		@import url('https://fonts.googleapis.com/css2?family=Josefin+Sans:ital,wght@1,300&family=Lexend+Deca:wght@350&display=swap');
	
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
		pluto-output h1, pluto-output h2, pluto-output h3, pluto-output h4, pluto-output h5, pluto-output h6 {                                                         font-family: 'Josefin Sans', sans-serif;
		color: #042A60;
					   
		}
		.center {
		  display: block;
		  margin-left: auto;
		  margin-right: auto;
		  width: 80%;
		}
		</style>
	"""
end

# ╔═╡ 20f6d71e-d930-4cb6-9656-a355e2a25db1
TwoColumn(md"""
`Show Table of Contents  = ` $(@bind show_toc html"<input type=checkbox >")

`Reveal hints  = ` $(@bind reveal_hint html"<input type=checkbox >")
"""
, html" Click here to change to <button onclick='present()'>Presentation Mode</button>  (Tip: F11 puts the browser in fullscreen)")

# ╔═╡ c8a88597-c465-4509-82e1-4d38ed44cbee
if @isdefined show_toc 
	if show_toc 
		TableOfContents() 
	end
end

# ╔═╡ b89d8514-2b56-4da9-8f49-e464579c2293
begin
	# Some definitions and helper functions
	bigbreak(n = 4) = HTML("<br>" ^ n);
	
	hints_visible = reveal_hint
	
	
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
	function percentup(old, new; stringed = true)
		res = my_round(100 * (new - old)/old)
		if stringed
			return string(res) * "%"
		else
			return res
		end
	end

	md""
end

# ╔═╡ f26e4064-d08f-4b66-a006-632794ee378c
	hint(md"""Cₒ = 15 – 0.1 × (32 – 5) – 0.9 × 12 = 1.5
	
	""", """Example: Freshly roasted high-quality coffee beans cost € 15 per kg in production and sell for € 40 per kg. After 2 weeks, 10% of the packages will be sold at a discount for € 32 per kg; 90% of the leftover will be sold for € 12 per kg in a mixed bag. Placement in the shop for sales is estimated to cost € 5 per kg (cannibalisation and space). """)

# ╔═╡ 08a7c51d-f3f1-4faa-aee0-2a0e48e6351e
	hint(md"""Cᵤ = 40 -- 15 -- 0.5 × 10 + 0.4 × (40 -- 15) = 30
	
	""", """Example: Freshly roasted high-quality coffee beans cost € 15 per kg in production and sell for € 40 per kg. Half of the unsatisfied customers buy a lower quality blend (margin is € 10 per kg); the other half leave without a purchase. All unsatisfied customers are 40% less likely to make their next purchase at the roastery.""")

# ╔═╡ e2ae2c0d-3e73-48ea-9cea-b1df22801473
begin
	hint(md""" **SL** is about all area to the **left of the selected quantity**, i.e., the chance of demand **being smaller than some quantity**. 
	
	**68-95-99.7-rule** is about the area symmetrically **left and righ from the mean**, i.e., the chance of demand **being between a lower bound and an upper bound**.
	
	""", """What is the difference?""")
end

# ╔═╡ f5cbdf4d-1d80-42c5-bef1-609b6ce8c438
hint(md""" **SL will be different**, e.g., if we decide about going 139🍰 ➡ 140🍰, then the 140th cake will be left over with probability 95%, and sold with a chance of  5%. 
	At this point it could be profitable to reduce the stock quantity.
	
	""", """What changes if we ask this question for different stock quantities?""")

# ╔═╡ b2c19571-95b1-4b7f-9ec1-ed83ba7b8aef
begin # Default parameters
	μ = 90	 
	σ = 30
	# distr = TruncatedNormal(μ, σ, 0, μ+3*σ)
	distr = Normal(μ, σ)
	
	selling_p = 5
	wholesale_p = 1  
	salvage_val = 0

	nvm = NVModel(demand=distr, price = selling_p, cost = wholesale_p, salvage = salvage_val);
	
	Co = overage_cost(nvm)
	Cu = underage_cost(nvm)
	CF = critical_fractile(nvm)
	CF_percent = my_round(100*CF)	
	
	
	md""
end

# ╔═╡ 5b45b95e-77d8-4ff4-8b18-08638346013e
begin
# needed parameters
wholesale_p
Co
salvage_val
selling_p
Cu

md"""

#####  Too Many: Cost of overage (Cₒ)
Money wasted from having stocked a unit more than demaned


"""
end

# ╔═╡ 90b4050f-84ef-42f5-9c77-e48b49bd997e
begin
	# needed parameters
	wholesale_p
	Co
	salvage_val
	hint(md""" ➡  Having a cake left over wastes €1: Cₒ =   $(wholesale_p)  --   $(salvage_val) =   $(Co)   $("😣"^Co)
	
	""", """You stocked for € $(wholesale_p), salvaged for  € $(salvage_val)  """)
end

# ╔═╡ a5689c64-3dd0-4bf4-b26b-5b91791e6d68
begin
# needed parameters
wholesale_p
Co
salvage_val
selling_p
Cu

md"""

##### Too Little: Cost of underage (Cᵤ) = Cost of under-stocking one unit

Forgone profit if demand ends up being one unit above the stocked quantity

"""
end

# ╔═╡ 604f54bd-c02f-4eed-8852-9e47172667fa
begin
	# needed parameters
	wholesale_p
	Co
	salvage_val
	hint(md"""➡ Missing a customer looses €4:  Cᵤ =    $(selling_p ) --   $(wholesale_p) =  $(Cu )   $("😣"^Cu)
	
	""", """You stocked for € $(wholesale_p) and sold for  € $(selling_p ) """)
end

# ╔═╡ 6258d6a2-3df6-46c5-a728-027a3d533e6f
let
	gr()
	xs = 0:1:μ+3*σ
	p = plot(xlim=(0,μ+3*σ), 
		ylabel=" \n How likely is this demand", yaxis=nothing)
	
	my_SL = my_SL_percent / 100
	x_lower = 0
	x_upper = quantile(distr, my_SL)
	interval = x_lower:x_upper
	
	plot!(p, xs, pdf.(distr,xs), lw=5)
	plot!(p, x_lower:x_upper, x->-0.00005, lw=5, c=:green)
	plot!(p, interval, x->0, fillrange = pdf.(distr,interval),
		size = (700,350),
		fillalpha = 0.35, 
		 c = :purple,
		legend=:false, 
			xlabel="Number of cakes", 
			label="Probability of \nsatisfying demand" )
	
	annotate!(p, x_upper, 0.0006, text("$(round(Int,x_upper))",10, :green))
	annotate!(p, x_upper, -0.000, text("|",10, :green))
	
	annotate!(p, 10, 0.95*pdf.(distr,μ), 
		text("Suppose you order $(round(Int,x_upper)): Then,\nyou satisfy all demand if\ndemand falls to the\nleft of $(round(Int,x_upper)) ",10, :green, :left))
	
	annotate!(p, μ+3.1*σ, 0.9*pdf.(distr,μ), 
		text("The purple area covers\n $(my_SL_percent)% of the area under\n the blue curve,\ni.e., demand\n is to the left of $(round(Int,x_upper))\n with prob. $(my_SL_percent)%",10, :purple, :right))
end

# ╔═╡ 04175c8b-fb50-4ad4-99c5-3b519a8b0da9
md"""
This means that if we stock $(round(Int,quantile(distr, my_SL_percent / 100))), the chance to not run out of stock is $(my_SL_percent)%

**➡  Stocking $(round(Int,quantile(distr, my_SL_percent / 100))) yields an Expected Service Level SL = $(my_SL_percent)%**

"""

# ╔═╡ 33f2cb73-abf7-49f0-b6a5-bf023cc79868
let
	gr()
	distr = Normal(μ, σ)
	xs = 0:1:μ+3*σ
	p = plot(xlim=(0,μ+3*σ), yaxis=nothing)
	
	my_SL = [.68,.95,.997][SL_vs_68]
	my_SL_percent = ["68%","95%","99.7%"][SL_vs_68]	
	
	x_lower = 0
	x_upper = quantile(distr, my_SL)
	interval = x_lower:x_upper
	
	plot!(p, xs, pdf.(distr,xs), lw=5)
	plot!(p, interval, x->0, fillrange = pdf.(distr,interval),
		fillalpha = 0.35, 
		 c = :purple,
		legend=:false, 
			title="SL = $(my_SL_percent) requires ordering $(round(Int,x_upper)) units " )
	annotate!(p, x_upper, 0.00051, text("$(round(Int,x_upper))",14, :green))
	plot!(p, x_lower:x_upper, x->-0.00005, lw=5, c=:green)
	annotate!(p, x_upper, -0.0002, text("|",14, :green))

	fac_689599 = SL_vs_68
	interval = μ-fac_689599*σ:μ+fac_689599*σ 
	x_default = μ-3*σ:1:μ+3*σ	
	q = plot(xlim=(μ-3*σ, μ+3*σ), 
		legend=:false,  yaxis=nothing)
	plot!(q, x_default, pdf.(distr ,xs), lw=5)
	plot!(q, interval, x->0, fillrange = pdf.(distr, interval),
		fillalpha = 0.35, 
		 c = :orange,
		legend=:false, 
		title="Demand is between $(interval[1]) and $(interval[end]) with prob. $(my_SL_percent)" )
	
	annotate!(q, interval[1], .00051, text("$(interval[1])",14, :orange))
	annotate!(q, interval[1], -0.0002, text("|",8, :orange))
	annotate!(q, interval[end], 0.00051, text("$(interval[end])",14, :orange))
	annotate!(q, interval[end], -0.0002, text("|",8, :orange))
	

			
			plot(p,q, size=(1000,350))
end

# ╔═╡ a8f7eb2e-e6b0-473d-b68c-85f173ebc62b
md"""
## Should We Go Up From 90🍰 ➡  91🍰?



➡ Additional cake will be left over (if we do NOT run out of stock) *or* sells (if we run out of stock)

| What could happen                   | Probability           | Implication        | Expected Impact        |
|----------------------------|-----------------------|--------------------|----------------------|
|91st cake is left over          | 50%         | lose -Cₒ |  0.5 × (-€$(Co))       |
| 91st cake is sold | 50%  | gain Cᵤ | 0.5 × €$(Cu) |
| | | |------------------------------------------------------------|
|                     |                      |                    |       Total:            - 0.5 × $(Co)€ + 0.5 × $(Cu)€ = € $(- 0.5 * Co + 0.5 * Cu) |


➡ Yes, making 91🍰 is better than 90🍰

"""

# ╔═╡ 46b0db4f-a5e3-4e61-b212-c57e60b8114b
let
	q_impact
	SL_impact = cdf(distr, q_impact)
	SL_impact_percent = round(100*SL_impact, sigdigits=2) 
	
	md"""
	## Should We Make 1 More Cake?
	
	
	If we originally planned to make **Q** 🍰, and now consider to go up to **Q+1** 🍰.  
	
	| What could happen                   | Probability           | Implication        | Expected Impact        |
	|----------------------------|-----------------------|--------------------|----------------------|
	| Cake is left over          | SL at Q        | -Cₒ |  SL × (-Cₒ)       |
	| Cake is sold | 100% - SL at  Q |  Cᵤ | (1 - SL) × Cᵤ |
	| | | |----------------------------------------------------|
	|                     |                      |                |             Total:      - SL × Cₒ + (1 - SL) × Cᵤ |
	
	
	➡ Total **impact** of extra cake **depends on SL, which depends on order quantity**: 
	
		
	###### Q = $q_impact ``~``  ➡``~``  SL = $SL_impact_percent% ``~`` ➡ ``~`` Extra cake gives - $SL_impact_percent% × € $(Co) + (1 - $SL_impact_percent%) × € $(Cu) = $(round(- SL_impact * Co + (1 - SL_impact) * Cu; digits=2))
	
	
	"""
end

# ╔═╡ e8c17ee2-7a0c-457b-8d5c-077b11652340
hint(md""" 115🍰 ➡ 116🍰 still promises more profit, but when going 116🍰 ➡ 117🍰, we would expect to loose money. Thus, 115 or 116 is optimal (theoretically, it's $(my_round( (NewsvendorModel.q_opt(NewsvendorModel.solve(nvm, rounded=false))), sigdigits=4)))
	""", """When should we no more increase the number of cakes?""")

# ╔═╡ 0cfedd8f-c04f-40eb-bab9-7fcc79f8ab85
begin
	nvm1 = NewsvendorModel.NVModel(demand=Truncated(Normal(90, 30), 0, 180), price = 5, cost = 1, salvage = .5)
	nvm2 = NewsvendorModel.NVModel(demand=Truncated(Normal(90, 30), 0, 180), cost = 1, price = 5, substitute = 1) 
	nvm3 = NewsvendorModel.NVModel(demand=Truncated(Normal(90, 20), 0, 180), price = 5, cost = 1)
	nvm4 = NewsvendorModel.NVModel(demand=Truncated(Normal(90, 20), 0, 180), price = 5, cost = 1, salvage = .5, substitute = 1)
	dprofit = my_round(NewsvendorModel.profit(nvm) )
	dprofit1 = my_round(NewsvendorModel.profit(nvm1) )
	dprofit2 = my_round(NewsvendorModel.profit(nvm2) )
	dprofit3 = my_round(NewsvendorModel.profit(nvm3) )
	dprofit4 = my_round(NewsvendorModel.profit(nvm4) )
		

	mprofit90 = my_round(30 * NewsvendorModel.profit(nvm, 90) - 5000 )
	mprofit100 = my_round(30 * NewsvendorModel.profit(nvm, 100) - 5000 )
	mprofitopt = my_round(30 * NewsvendorModel.profit(nvm) - 5000 )
	mprofit4 = my_round(30 * NewsvendorModel.profit(nvm4) - 5000 )

	lo90 = round(Int, leftover(nvm, 90))
	lo100 = round(Int, leftover(nvm, 100))
	loopt = round(Int, leftover(nvm, q_opt(nvm)))
	lo4 = round(Int, leftover(nvm4, q_opt(nvm4)))
	
	md"""
	## Exercises (Original Case: Q* = 115)

	Should we stock more or less? What would be the optimal quantity? If...
	
	1. ... we can sell leftover cakes to a bar for € 0.5 per piece, i.e., for a **salvage value = € 0.5**.  All else as in the orginal case.
	
	2. ... customers buy durable pralines if we stock-out. These only yield a margin of  € 1 but do not perish, i.e., **substitute margin = € 1**.  All else as in the case.

	3. ... we improve forecast: **standard dev.** ↘️ **σ = 20**. All else as in the case.

	4. ... a **combination of the above**: standard deviation is only σ = 20, salvage value = € 0.5, and substitue margin = € 1. All else as in the case.
	
	
	"""
end

# ╔═╡ 159a7ab5-5216-47c8-8bd4-56db4765afe6
begin

	
Markdown.MD(Markdown.Admonition("tip", "♻️ More Waste?", [
	
md""" 
Leftover increases with profit  **➡ Requires active management of mismatch**

from daily $lo90 🍰 (when ignoring risk and stocking the forecasted **90** cakes) 

↗️ $(percentup(lo90, lo100)) to $lo100 🍰 (when stocking **100** cakes) 

↗️ $(percentup(lo100, loopt)) to $loopt 🍰 (when stocking **profit-optimal** quantity 115) 

↘️ 0 🍰 (when **selling** $lo4 🍰 leftover to a bar as in question 1)
"""

]))
end

# ╔═╡ 942f3e3d-8eee-46bf-a919-7f8c3ef2d85a
gr();TwoColumn(md"""Our example with 
	* Cᵤ = € $(Cu) and 
	* Cₒ = € $(Co), we get 
	➡ CF = ``\frac{\qquad}{\qquad + \qquad}``  = $(CF_percent)%. 
	
	➡ A Critical Fractile greater than 50% indicates: Missing a customer hurts more than having a unit left over. 
	
	
	""",	
	pie(["Cost of Overage","Cost of Underage"], [1-CF, CF ],  legend=:outertop, size=(260,260))
	)

# ╔═╡ 48d8b970-94bb-4f21-a10a-a96df248fdcb
Foldable("We reach optimality if - SL × Cₒ + (1 - SL) × Cᵤ
 = 0. Show that this means SL = CF",
	
md""" 0 = - SL × Cₒ + (1 - SL) × Cᵤ 

➡ 0 = - SL × Cₒ + Cᵤ - SL × Cᵤ 

➡ SL × Cₒ + SL × Cᵤ =  Cᵤ  

➡  SL × (Cₒ + Cᵤ) = Cᵤ 

➡ SL = Cᵤ/(Cₒ + Cᵤ) 

➡ SL = CF
	""")

# ╔═╡ ac888d85-cb85-44da-94b3-bf7095d1714b
TwoColumn(md"""
**Example Patisserie Cheers!**
- We learn mean μ = $μ and standard deviation σ = $σ from the case.
- **Cᵤ** = \$$(selling_p)--\$$(wholesale_p) = **\$$(Cu)**;  **Cₒ** = \$$(wholesale_p)--\$$(salvage_val) = **\$$(Co)**.


""",
	md"""
	

- This gives   **CF = \$$(Cu) / (\$$(Cu) + \$$(Co)) = $CF**.
- We target a service level of $(CF). Excel: `=Norm.Inv(0.8, 90, 30)` =  **115.2**. 
	"""
)

# ╔═╡ 42dc3b20-2778-48b1-8c8f-f88eb90b3083
TwoColumn(
hint(md"""More. Having left over hurts less than before. Cₒ = 1 - 0.5 = 0.5, Cᵤ = 4, CF =  0.89; Q* `=Norm.Inv(0.89, 90, 30)` = **127** (expected profit  increases $(dprofit) ↗️ $(dprofit1))""", """Answer Exercise 1""")
	,

hint(md"""Less. Not having enough cake hurts less than before. Cₒ = 1, Cᵤ = 5 - 2 = 3, CF =  0.75; Q* `=Norm.Inv(0.75, 90, 30)` = **110** (exp. profit increases $(dprofit)↗️ $(dprofit2))""", """Answer Exercise 2""")
)

# ╔═╡ 0c1fb50f-4b75-4449-93b6-f1163af266a5
TwoColumn(
hint(md"""Better forecast ➡ optimal quantity gets closer to expected demand, i.e., we need less safety stock in our case. CF =  0.8; Q* `=Norm.Inv(0.8, 90, 20)` = **107** (exp. profit increases $(dprofit) ↗️ $(dprofit3))""", """Answer Exercise 3""")
	,
hint(md"""Cₒ = 0.5, Cᵤ = 3, CF =  0.86; Q* `=Norm.Inv(0.86, 90, 20)` = **114**  (expected profit increases $(dprofit) ↗️ $(dprofit4)). 

""", """Answer Exercise 4""")	
)

# ╔═╡ f3efb8b3-8788-49e8-862d-5fc8fb85f115
Foldable( "$(percentup(4020, 5320)) Higher Income from Reducing Mismatch Cost (Q = 90 in original vs. Ex. 4)",
	
md""" 
Assuming 30 days a month and € 5000 fixed cost, the owners' income increases
from monthly € $(mprofit90) (when ignoring risk and stocking the forecasted **90** cakes) 

↗️ $(percentup(mprofit90, mprofit100)) to € $(mprofit100) (when stocking **100** cakes with insufficient safety stock) 

↗️ $(percentup(mprofit100, mprofitopt)) to € $(mprofitopt) (when stocking **optimal** quantity) 

↗️ $(percentup(mprofitopt, mprofit4)) to € $(mprofit4) (when **improving** situation as in Ex. 4 **and** stocking **optimally**)
"""

)

# ╔═╡ 3b829741-c74b-43d7-9759-d362c688c7ff
TwoColumn(md""" Optimal quantity: `q_opt(nvm4)`""",
	md"`111`")

# ╔═╡ bcddfc3d-c3f3-4b1d-b145-a183a814217a
TwoColumn(md""" Exp. leftover if q = 90:
`leftover(nvm4, 90)`
""",
	md"`7.978580150421218`")

# ╔═╡ b56b1541-b8c4-4a19-b28d-8b49a9899389
TwoColumn(md"""
E Profit at qopt:
`profit(nvm4, q_opt(nvm4))`
""",
	md"`344.20322393520746`")

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
		plotly()
		
		scatter(sd.sales,  label="Sales", markerstrokewidth=3.5,c=:white, markersize=7,  markerstrokecolor = 3, bar_width=sd.days_played*0.01)	
	
		scatter!(sd.demands[1:sd.days_played], label = "Demanded", c = 1, msw = 0, 
			xlabel = "Day", xticks=1:sd.days_played, xrotation=60, size=(850, 450),
			right_margin=-8Plots.mm)
		plot!(sd.demands[1:sd.days_played], lw=1, ls=:dash, label="", c = 1)
	
		plot!([sd.avg_demand], seriestype="hline", 
			c=1,lw=2,ls=:dot,label="Observed\naverage\ndemand\n($(my_round(sd.avg_demand)))")
	
		scatter!(sd.qs, label = "You stocked", c = 2,  msw = 0)
		plot!(sd.qs, lw=1, ls=:dash, label="", c = 2, legend = :outerright)
	
		plot!([sd.avg_q], seriestype="hline", 
			c=2,lw=2, ls=:dot,label="Your average\ndecision ($(my_round(sd.avg_q)))")
			
	
	end
	
	function update_plot_panel_2(sd::SimData)
		
		days = 1:sd.days_played
		bar(days, sd.revenues, label="Revenue", lw=0,  c = :green, fillalpha = 0.61, bar_width=0.17, 
			size=(750, 150), xticks=days, xrotation=60, legend=:outerright)
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
	
	function fluctuationloss(logfile)
		dict_simlogs_ind = TOML.parsefile(logfile)
		simlog_ind = from_dict(SimLog, dict_simlogs_ind["log"][selected_scenario_ind])
		sim_data_ind = simlog_to_simdata(simlog_ind)
		sim_data_ind_const = simlog_to_simdata(simlog_ind)
		update_sim_data!(sim_data_ind)
		sim_data_ind_const.qs = ones(length(sim_data_ind.qs)) * round(Int,sim_data_ind.avg_q)
		update_sim_data!(sim_data_ind_const)
		return percentup(sim_data_ind.avg_profit, sim_data_ind_const.avg_profit, stringed=false)
	end; 
	md""
end

# ╔═╡ ad6ffaf5-4cfe-4926-88f9-e36ffe10ef44
md"""
`Show code  = ` $(@bind show_ui html"<input type=checkbox >")
"""

# ╔═╡ 375b5f20-ff08-4d9a-8d41-38214db962de
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

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Configurations = "5218b696-f38b-4ac9-8b61-a12ec717816d"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
NewsvendorModel = "63d3702b-073a-45e6-b43c-f47e8b08b809"
Parameters = "d96e819e-fc66-5662-9728-84c9c7592b0a"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
QuadGK = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
ShortCodes = "f62ebe17-55c5-4640-972f-b59c0dd11ccf"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
TOML = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[compat]
Configurations = "~0.17.3"
DataFrames = "~1.3.3"
Distributions = "~0.25.53"
Images = "~0.25.2"
JSON3 = "~1.9.4"
LaTeXStrings = "~1.3.0"
NewsvendorModel = "~0.2.1"
Parameters = "~0.12.3"
Plots = "~1.27.6"
PlutoUI = "~0.7.38"
QuadGK = "~2.4.2"
ShortCodes = "~0.3.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.2"
manifest_format = "2.0"

[[deps.AbstractFFTs]]
deps = ["ChainRulesCore", "LinearAlgebra"]
git-tree-sha1 = "6f1d9bc1c08f9f4a8fa92e3ea3cb50153a1b40d4"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.1.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "af92965fb30777147966f58acb05da51c5616b5f"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

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
git-tree-sha1 = "cf6875678085aed97f52bfc493baaebeb6d40bcb"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.5"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[deps.CEnum]]
git-tree-sha1 = "eb4cb44a499229b3b8426dcfb5dd85333951ff90"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.4.2"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "4b859a208b2397a7a623a03449e4636bdb17bcf2"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+1"

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

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "9950387274246d08af38f6eef8cb5480862a435f"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.14.0"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "bf98fa45a0a4cee295de98d4c1462be26345b9a1"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.2"

[[deps.Clustering]]
deps = ["Distances", "LinearAlgebra", "NearestNeighbors", "Printf", "SparseArrays", "Statistics", "StatsBase"]
git-tree-sha1 = "75479b7df4167267d75294d14b58244695beb2ac"
uuid = "aaaa29a8-35af-508c-8bc3-b662a17a0fe5"
version = "0.14.2"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "12fc73e5e0af68ad3137b886e3f7c1eacfca2640"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.17.1"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "SpecialFunctions", "Statistics", "TensorCore"]
git-tree-sha1 = "3f1f500312161f1ae067abe07d13b40f78f32e07"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.9.8"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[deps.Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "b153278a25dd42c65abbf4e62344f9d22e59191b"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.43.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[deps.Configurations]]
deps = ["ExproniconLite", "OrderedCollections", "TOML"]
git-tree-sha1 = "ab9b7c51e8acdd20c769bccde050b5615921c533"
uuid = "5218b696-f38b-4ac9-8b61-a12ec717816d"
version = "0.17.3"

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

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.CustomUnitRanges]]
git-tree-sha1 = "1a3f97f907e6dd8983b744d2642651bb162a3f7a"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.2"

[[deps.DataAPI]]
git-tree-sha1 = "fb5f5316dd3fd4c5e7c30a24d50643b73e37cd40"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.10.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Reexport", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "6c19003824cbebd804a51211fd3bbd81bf1ecad5"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.3.3"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3daef5523dd2e769dad2365274f760ff5f282c7d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.11"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

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
git-tree-sha1 = "5a4168170ede913a2cd679e53c2123cb4b889795"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.53"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[deps.Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bad72f730e9e91c08d9427d5e8db95478a3c323d"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.4.8+0"

[[deps.ExproniconLite]]
git-tree-sha1 = "8b08cc88844e4d01db5a2405a08e9178e19e479e"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.6.13"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[deps.FFTViews]]
deps = ["CustomUnitRanges", "FFTW"]
git-tree-sha1 = "cbdf14d1e8c7c8aacbe8b19862e0179fd08321c2"
uuid = "4f61f5a4-77b1-5117-aa51-3ab5ef4ef0cd"
version = "0.3.2"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "505876577b5481e50d089c1c68899dfb6faebc62"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.4.6"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c6033cc3892d0ef5bb9cd29b7f2f0331ea5184ea"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.10+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "80ced645013a5dbdc52cf70329399c35ce007fae"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.13.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "Statistics"]
git-tree-sha1 = "246621d23d1f43e3b9c368bf3b72b2331a27c286"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "0.13.2"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "51d2dfe8e590fbd74e7a842cf6d13d8a2f45dc01"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.6+0"

[[deps.GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "RelocatableFolders", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "af237c08bda486b74318c8070adb96efa6952530"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.64.2"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "cd6efcf9dc746b06709df14e462f0a3fe0786b1e"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.64.2+0"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "83ea630384a13fc4f002b77690bc0afeb4255ac9"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.2"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "a32d672ac2c967f3deb8a81d828afc739c838a06"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+2"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "1c5a84319923bea76fa145d49e93aa4394c73fc2"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.1"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "57c021de207e234108a6f1454003120a1bf350c4"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.6.0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

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
git-tree-sha1 = "9a5c62f231e5bba35695a20988fc7cd6de7eeb5a"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.9.3"

[[deps.ImageDistances]]
deps = ["Distances", "ImageCore", "ImageMorphology", "LinearAlgebra", "Statistics"]
git-tree-sha1 = "7a20463713d239a19cbad3f6991e404aca876bda"
uuid = "51556ac3-7006-55f5-8cb3-34580c88182d"
version = "0.2.15"

[[deps.ImageFiltering]]
deps = ["CatIndices", "ComputationalResources", "DataStructures", "FFTViews", "FFTW", "ImageBase", "ImageCore", "LinearAlgebra", "OffsetArrays", "Reexport", "SparseArrays", "StaticArrays", "Statistics", "TiledIteration"]
git-tree-sha1 = "15bd05c1c0d5dbb32a9a3d7e0ad2d50dd6167189"
uuid = "6a3955dd-da59-5b1f-98d4-e7296123deb5"
version = "0.7.1"

[[deps.ImageIO]]
deps = ["FileIO", "JpegTurbo", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs"]
git-tree-sha1 = "464bdef044df52e6436f8c018bea2d48c40bb27b"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.1"

[[deps.ImageMagick]]
deps = ["FileIO", "ImageCore", "ImageMagick_jll", "InteractiveUtils"]
git-tree-sha1 = "ca8d917903e7a1126b6583a097c5cb7a0bedeac1"
uuid = "6218d12a-5da1-5696-b52f-db25d2ecc6d1"
version = "1.2.2"

[[deps.ImageMagick_jll]]
deps = ["JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pkg", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "1c0a2295cca535fabaf2029062912591e9b61987"
uuid = "c73af94c-d91f-53ed-93a7-00f77d67a9d7"
version = "6.9.10-12+3"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "36cbaebed194b292590cba2593da27b34763804a"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.8"

[[deps.ImageMorphology]]
deps = ["ImageCore", "LinearAlgebra", "Requires", "TiledIteration"]
git-tree-sha1 = "7668b123ecfd39a6ae3fc31c532b588999bdc166"
uuid = "787d08f9-d448-5407-9aad-5290dd7ab264"
version = "0.3.1"

[[deps.ImageQualityIndexes]]
deps = ["ImageContrastAdjustment", "ImageCore", "ImageDistances", "ImageFiltering", "OffsetArrays", "Statistics"]
git-tree-sha1 = "1d2d73b14198d10f7f12bf7f8481fd4b3ff5cd61"
uuid = "2996bd0c-7a13-11e9-2da2-2f5ce47296a9"
version = "0.3.0"

[[deps.ImageSegmentation]]
deps = ["Clustering", "DataStructures", "Distances", "Graphs", "ImageCore", "ImageFiltering", "ImageMorphology", "LinearAlgebra", "MetaGraphs", "RegionTrees", "SimpleWeightedGraphs", "StaticArrays", "Statistics"]
git-tree-sha1 = "36832067ea220818d105d718527d6ed02385bf22"
uuid = "80713f31-8817-5129-9cf8-209ff8fb23e1"
version = "1.7.0"

[[deps.ImageShow]]
deps = ["Base64", "FileIO", "ImageBase", "ImageCore", "OffsetArrays", "StackViews"]
git-tree-sha1 = "d0ac64c9bee0aed6fdbb2bc0e5dfa9a3a78e3acc"
uuid = "4e3cecfd-b093-5904-9786-8bbb286a6a31"
version = "0.3.3"

[[deps.ImageTransformations]]
deps = ["AxisAlgorithms", "ColorVectorSpace", "CoordinateTransformations", "ImageBase", "ImageCore", "Interpolations", "OffsetArrays", "Rotations", "StaticArrays"]
git-tree-sha1 = "42fe8de1fe1f80dab37a39d391b6301f7aeaa7b8"
uuid = "02fcd773-0e25-5acc-982a-7f6622650795"
version = "0.9.4"

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
git-tree-sha1 = "f5fc07d4e706b84f72d54eedcc1c13d92fb0871c"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.2"

[[deps.IniFile]]
git-tree-sha1 = "f550e6e32074c939295eb5ea6de31849ac2c9625"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.1"

[[deps.IntegralArrays]]
deps = ["ColorTypes", "FixedPointNumbers", "IntervalSets"]
git-tree-sha1 = "509075560b9fce23fdb3ccb4cc97935f11a43aa0"
uuid = "1d092043-8f09-5a30-832f-7509e371ab51"
version = "0.1.4"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d979e54b71da82f3a65b62553da4fc3d18c9004c"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2018.0.3+2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.Interpolations]]
deps = ["AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "b7bc05649af456efc75d178846f47006c2c4c3c7"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.13.6"

[[deps.IntervalSets]]
deps = ["Dates", "Statistics"]
git-tree-sha1 = "eb381d885e30ef859068fce929371a8a5d06a914"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.6.1"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "91b5dcf362c5add98049e6c29ee756910b03051d"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.3"

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
git-tree-sha1 = "81b9477b49402b47fbe7f7ae0b252077f53e4a08"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.22"

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
git-tree-sha1 = "8c1f668b24d999fb47baf80436194fdccec65ad2"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.9.4"

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

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "6f14549f7760d84b2db7a9b10b88cd3cc3025730"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.14"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[deps.Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[deps.Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "c9551dd26e31ab17b86cbd00c2ede019c08758eb"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+1"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "a970d55c2ad8084ca317a4658ba6ce99b7523571"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.12"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "Pkg"]
git-tree-sha1 = "e595b205efd49508358f7dc670a940c790204629"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2022.0.0+0"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[deps.MappedArrays]]
git-tree-sha1 = "e8b359ef06ec72e8c030463fe02efe5527ee5142"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.1"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

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

[[deps.NaNMath]]
git-tree-sha1 = "b086b7ea07f8e38cf122f5016af580881ac914fe"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.7"

[[deps.NearestNeighbors]]
deps = ["Distances", "StaticArrays"]
git-tree-sha1 = "ded92de95031d4a8c61dfb6ba9adb6f1d8016ddd"
uuid = "b8a86587-4115-5ab1-83bc-aa920d37bbce"
version = "0.4.10"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore"]
git-tree-sha1 = "18efc06f6ec36a8b801b23f076e3c6ac7c3bf153"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.0.2"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.NewsvendorModel]]
deps = ["Distributions", "Printf", "QuadGK"]
git-tree-sha1 = "03ddf70f3231ed38f89ae8933971809f36b18662"
uuid = "63d3702b-073a-45e6-b43c-f47e8b08b809"
version = "0.2.1"

[[deps.OffsetArrays]]
deps = ["Adapt"]
git-tree-sha1 = "043017e0bdeff61cfbb7afeb558ab29536bbb5ed"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.10.8"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

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

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ab05aa4cc89736e95915b01e7279e61b1bfe33b8"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.14+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "3114946c67ef9925204cc024a73c9e679cebe0d7"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.8"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "eb4dbb8139f6125471aa3da98fb70f02dc58e49c"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.3.14"

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
deps = ["Dates"]
git-tree-sha1 = "1285416549ccfcdf0c50d4997a94331e88d68413"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.3.1"

[[deps.Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "a7a7e1a88853564e551e4eba8650f8c38df79b37"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.1.1"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "8162b2f8547bc23876edd0c5181b27702ae58dce"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.0.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "bb16469fd5224100e422f0b027d26c5a25de1200"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.2.0"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "6f2dd1cf7a4bbf4f305a0d8750e351cb46dfbe80"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.27.6"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "670e559e5c8e191ded66fa9ea89c97f10376bb4c"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.38"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "28ef6c7ce353f0b35d0df0d5930e0d072c1f5b9b"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "Markdown", "Reexport", "Tables"]
git-tree-sha1 = "dfb54c4e414caa595a1f2ed759b160f5a3ddcba5"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "1.3.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

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

[[deps.Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "c6c0f690d0cc7caddb74cef7aa847b824a16b256"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "78aadffb3efd2155af139781b8a8df1ef279ea39"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.4.2"

[[deps.Quaternions]]
deps = ["DualNumbers", "LinearAlgebra", "Random"]
git-tree-sha1 = "b327e4db3f2202a4efafe7569fcbe409106a1f75"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.5.6"

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

[[deps.RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "dc1e451e15d90347a7decc4221842a022b011714"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.5.2"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RegionTrees]]
deps = ["IterTools", "LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "4618ed0da7a251c7f92e869ae1a19c74a7d2a7f9"
uuid = "dee08c22-ab7f-5625-9660-a9af2021b33f"
version = "0.3.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "cdbd3b1338c72ce29d9584fdbe9e9b70eeb5adca"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "0.1.3"

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
git-tree-sha1 = "3177100077c68060d63dd71aec209373c3ec339b"
uuid = "6038ab10-8711-5258-84ad-4b1120ba62dc"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

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
git-tree-sha1 = "5ba658aeecaaf96923dce0da9e703bd1fe7666f9"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.4"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "46e589465204cd0c08b4bd97385e4fa79a0c770c"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.1"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "cd56bf18ed715e8b09f06ef8c6b781e6cdc49911"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.4.4"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c82aaa13b44ea00134f8c9c89819477bd3986ecd"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.3.0"

[[deps.StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "8977b17906b0a1cc74ab2e3a05faa16cf08a8291"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.16"

[[deps.StatsFuns]]
deps = ["ChainRulesCore", "InverseFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "5950925ff997ed6fb3e985dcce8eb1ba42a0bbe7"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "0.9.18"

[[deps.StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "57617b34fa34f91d536eb265df67c2d4519b8b98"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.5"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "d24a825a95a6d98c385001212dc9020d609f2d4f"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.8.1"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "5ce79ce186cc678bbb5c5681ca3379d1ddae11a1"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.7.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "OffsetArrays", "PkgVersion", "ProgressMeter", "UUIDs"]
git-tree-sha1 = "aaa19086bc282630d82f818456bc40b4d314307d"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.5.4"

[[deps.TiledIteration]]
deps = ["OffsetArrays"]
git-tree-sha1 = "5683455224ba92ef59db72d10690690f4a8dc297"
uuid = "06e1c1a7-607b-532d-9fad-de7d9aa2abac"
version = "0.3.1"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "216b95ea110b5972db65aa90f88d8d89dcb8851c"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.6"

[[deps.URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "34db80951901073501137bdbc3d5a8e7bbd06670"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.1.2"

[[deps.Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[deps.Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4528479aa01ee1b3b4cd0e6faef0e04cf16466da"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.25.0+0"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "de67fa59e33ad156a590055375a30b23c40299d3"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "0.5.5"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[deps.XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[deps.Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e45044cd873ded54b6a5bac0eb5c971392cf1927"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.2+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "78736dab31ae7a53540a6b752efc61f77b304c5b"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.8.6+1"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "b910cb81ef3fe6e78bf6acee440bda86fd6ae00c"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─20f6d71e-d930-4cb6-9656-a355e2a25db1
# ╟─c8a88597-c465-4509-82e1-4d38ed44cbee
# ╟─09161f05-8c44-4f88-b45a-f80d5da136d6
# ╟─ba5fa42c-345e-4418-823f-b622febde2ee
# ╟─5b45b95e-77d8-4ff4-8b18-08638346013e
# ╟─90b4050f-84ef-42f5-9c77-e48b49bd997e
# ╟─a5689c64-3dd0-4bf4-b26b-5b91791e6d68
# ╟─604f54bd-c02f-4eed-8852-9e47172667fa
# ╟─f162d77a-9ee1-4a98-a4e9-a6441a89dbee
# ╟─a71d9b77-0f3e-4b8a-8279-7fe9997f4c35
# ╟─f26e4064-d08f-4b66-a006-632794ee378c
# ╟─ec27255a-1f76-483d-8900-1ab1368e5a60
# ╟─ebc29bbf-2f8f-461f-9dc0-899d0c771c62
# ╟─08a7c51d-f3f1-4faa-aee0-2a0e48e6351e
# ╟─4dbc0052-81bc-4b81-bd0b-c536788ff6bf
# ╟─b267ab57-05e4-494d-9ed4-54d968003e8a
# ╟─be019d95-a3b7-4b0b-a047-4100d48ae05f
# ╟─942f3e3d-8eee-46bf-a919-7f8c3ef2d85a
# ╟─61300264-4844-4925-8c2a-38bec150a759
# ╟─a93782c2-61b5-4ab5-a122-eda5a4d8d2c2
# ╟─4df81f21-d69b-4a2a-93b2-c476cfc80383
# ╟─b96affe0-c626-48b7-a9fd-7286636f0813
# ╟─366266d9-7cff-44b7-9f2e-8151b2d25f07
# ╟─d5c0d931-92c7-4e62-806e-14bd52c0e9af
# ╟─6258d6a2-3df6-46c5-a728-027a3d533e6f
# ╟─04175c8b-fb50-4ad4-99c5-3b519a8b0da9
# ╟─7772adfc-7748-4a6f-8cf1-6e33f935e9b7
# ╟─f193e41d-5b06-46f2-b825-2727a84a12d3
# ╟─33f2cb73-abf7-49f0-b6a5-bf023cc79868
# ╟─e2ae2c0d-3e73-48ea-9cea-b1df22801473
# ╟─96b69341-1e89-4c23-afb9-651e6fd09e64
# ╟─d9485017-6d38-45b0-a9ed-e32ea87e88e7
# ╟─a8f9c09c-93be-4a4f-9883-5432204f0ba8
# ╟─a8f7eb2e-e6b0-473d-b68c-85f173ebc62b
# ╟─f5cbdf4d-1d80-42c5-bef1-609b6ce8c438
# ╟─c3001041-4c4a-4325-bff3-a4143c7c47df
# ╟─46b0db4f-a5e3-4e61-b212-c57e60b8114b
# ╟─baa48e2b-0ba2-4b5e-96e4-925d1c641a0c
# ╟─e8c17ee2-7a0c-457b-8d5c-077b11652340
# ╟─48d8b970-94bb-4f21-a10a-a96df248fdcb
# ╟─933e018f-7229-4e29-b1ae-c07a19772213
# ╟─33f4e807-5329-4edc-8b5e-a1cd46c60594
# ╟─ac888d85-cb85-44da-94b3-bf7095d1714b
# ╟─2b7fbb27-fb33-47cd-82aa-a93d8020cad3
# ╟─0cfedd8f-c04f-40eb-bab9-7fcc79f8ab85
# ╟─159a7ab5-5216-47c8-8bd4-56db4765afe6
# ╟─31109c8e-14a9-446b-a2ff-ac34dcc12ed1
# ╟─9a36dbb8-6e14-433c-a691-f61c9fc5b7d0
# ╟─42dc3b20-2778-48b1-8c8f-f88eb90b3083
# ╟─0c1fb50f-4b75-4449-93b6-f1163af266a5
# ╟─f3efb8b3-8788-49e8-862d-5fc8fb85f115
# ╟─705ca167-c84c-4ecf-b812-afe5009339a5
# ╟─7535fbbe-763b-49d8-9e82-cc28ed69ef9d
# ╟─317a6eff-8d57-46ff-9732-3298e9166141
# ╟─292aa62b-a312-4292-8601-b90f3f98dc4f
# ╟─1c5bbd84-5a75-4a72-9ce1-b60e87705ec7
# ╟─1f4c415d-97ea-4d27-a205-d6e9b45a01ca
# ╟─e4573f83-8a3e-4544-aed3-87a49ff7677b
# ╟─77144dfb-312d-4458-83b4-1dda1f24cca4
# ╟─5bcbd57a-a3f6-4333-93d6-6cf111b43ee6
# ╟─efcaebd0-0d23-468f-b637-c50f5ceda888
# ╟─2b565e17-c120-43a2-92b1-b29cc29e9da6
# ╟─12c1316d-f830-48e0-8823-585e7a11fe3e
# ╟─3b829741-c74b-43d7-9759-d362c688c7ff
# ╟─bcddfc3d-c3f3-4b1d-b145-a183a814217a
# ╟─b56b1541-b8c4-4a19-b28d-8b49a9899389
# ╟─9b7657b1-0053-45c1-8d7b-5db69e42f7e1
# ╟─19975a48-0f5f-4f8b-903c-3d93181d81a1
# ╟─5f7cf638-cbf8-48f8-a8bb-b1ebf5ba88ab
# ╟─a6bf2500-0418-488c-a5ff-69cba2e9d1f7
# ╟─47bad2aa-051e-4ef0-97b6-2d94641b1a5d
# ╟─c580aaae-7e6b-4a74-b360-d0e99322b82c
# ╟─e0d09197-fc18-46e9-b0f9-b513ea32596a
# ╟─b2c19571-95b1-4b7f-9ec1-ed83ba7b8aef
# ╟─375b5f20-ff08-4d9a-8d41-38214db962de
# ╟─b89d8514-2b56-4da9-8f49-e464579c2293
# ╟─c8618313-9982-44e0-a110-2d75c69c75e8
# ╟─5ea60b57-f735-41c2-86cf-de6601573719
# ╟─ad6ffaf5-4cfe-4926-88f9-e36ffe10ef44
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
