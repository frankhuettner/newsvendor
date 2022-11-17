### A Pluto.jl notebook ###
# v0.19.15

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
	using  Images,  ShortCodes,     PlutoTeachingTools, Distributions, NewsvendorModel
	md""
end

# ╔═╡ e44321cc-abd9-45ad-b106-e141a7fa086e
using PlutoUI

# ╔═╡ 933e018f-7229-4e29-b1ae-c07a19772213
md"""
# Derivation of the Optimality Condition of the Newsvendor Model, SL = CF

In this document, we tackle the question: 

**Why is it optimal to set SL = CF?**

To this end, we will start with a low quantity and wonder why we should increase the quantity. We will see that the argument in favor of increasing the quantity will stop once we reached the optimal quantity. 

The arguement is illustrated for the case of _Cheers!_ (Scenario I):


"""

# ╔═╡ 94d60dee-eb01-458c-88fa-567d2111c225


# ╔═╡ b96b3b5b-d88b-402f-8471-86446a42235a
md"""


Let's restate the optimality condition.
"""

# ╔═╡ fd5ac52c-e5e8-4603-a835-6abd8e4331a1


# ╔═╡ 33f4e807-5329-4edc-8b5e-a1cd46c60594
md"""
# Recall: Finding the Optimal Quantity

!!! danger "Optimality Condition"
	**Service Level (SL) = Critical Fractile (CF)**


	
!!! tip "Recipe: Getting the optimal quantity"
	Step 0) Collect demand data and obtain mean μ and standard deviation σ.

	Step 1) **Compute** the cost of underage **Cᵤ** and the cost of overage **Cₒ**.

	Step 2) **Compute** the critical fractile **CF = Cᵤ / (Cᵤ + Cₒ)**.

	Step 3) Find the quantity so that the implied service level equals CF. Excel gives this quantity with the **Formula `=Norm.Inv(CF, μ, σ)`**

"""

# ╔═╡ 49dbe76a-af43-4026-82ef-cf934954efe9


# ╔═╡ cfd852f3-1e53-476f-b646-743dde2c6481
md"""
## Rounding Up or Down?
**Slight deviation from the optimal quantity is still very good**
"""

# ╔═╡ 59a24e9b-24f6-4b5b-b41d-88da790b1b02
let
	# qopt = NewsvendorModel.q_opt(nvm) 
	# xs = range(qopt-std(nvm.demand), qopt+std(nvm.demand), 100)
	# plt = plot(xs, [NewsvendorModel.profit(nvm, x) for x in xs], lw=4,
	# 	xlabel="Quantity Stocked",
	# 	ylabel="Expected Profit",
	# 	legend=false,
	# 	size=(520,250),
	# 	title="Robust Optimum: Similar Profits Q=110...120"
	# )
	# savefig(plt,"img/q-vs-exp_profit.png")
    Resource("https://github.com/frankhuettner/newsvendor/raw/main/debrief/img/q-vs-exp_profit.png")
end

# ╔═╡ 94f0412b-6c34-4b64-8365-9d11dfebd055
md"""
Thus, rounding up or down barely matters; but here are some further thoughts on the matter: 
1. If you have a continuous distribution, rounding to the next integer is mostly best from a purely mathematical point of view
2. Pragmatically, *rounding up* seems better because what really matters is: 
   - The **input data** is tends to be wrong: Cᵤ and σ are usually underestimated
   - There is a tendency to pull to the center
   ➡ Better have some more safety stock
3. Align your action: If your boss is more likely disturbed by massive leftovers and cares little about nontangible forgone profit, then round down; if your company suffers from complaints about stock-outs, then go up with the quantity
"""

# ╔═╡ d7768d12-a3ad-48d7-acb9-2bdd46cc8586


# ╔═╡ 85b982ae-6cc2-4b9f-bc38-28c1d91f0c8a
md"Now, let's understand where the optimality condition is coming from. Intuitively, it is not sufficient to just stock the expected quantity, i.e., to stock 90 cakes. Missing a customer lost €4, wheras a leftover cake comes at a loss of €1. Thus, we rather want to err on the side of having too much and add some safety stock."

# ╔═╡ f7433a6b-35bc-4d2a-ae3e-a109fcef8960


# ╔═╡ 0de1569c-dae5-4a49-b37d-6acaf89c268f


# ╔═╡ 1b412983-074d-4b93-9444-88b92a2dd070
md"""
👉 Change your quantity (Q): $(@bind q_impact Slider(1:180, default=115, show_value=true))🍰

"""

# ╔═╡ bf2e12f5-09fe-44a1-aaaf-a11611666b1c


# ╔═╡ 4c283bff-24ec-419a-b6f8-c81c2803e167
md"""# We Reach Optimality if 1 More Unit Has No Benefit


- Adding another unit is beneficial as long as -- SL × Cₒ + (1 -- SL) × Cᵤ > 0
- Assuming Cₒ + Cᵤ > 0, this is equivalent to SL < CF





"""

# ╔═╡ ad76e90c-2964-4d46-98ee-d0a5200dd490
md"""


Next, we distinguish 
- Continuous distributions (e.g., Normal distribution or Uniform distribution)
- Discrete distribution (e.g., Three-point distribution with a worst/most-likely/best case or Poisson distribution) and 




"""

# ╔═╡ 49be1a24-02e4-4244-a61e-78113a2b655f


# ╔═╡ c7937922-ea60-41b7-8e26-0bdc0b910ad5


# ╔═╡ 5c20ba81-7d54-4f2b-9cfd-7d6c815e693f


# ╔═╡ 365c61d5-9d5d-4c69-a79b-02d3abff9af8


# ╔═╡ ebe661ef-8a2a-4380-a085-ed91c52eb97f


# ╔═╡ db80883f-d378-4ec1-a9c2-8e3666176941


# ╔═╡ 5f3d33b5-c600-452e-a1b6-ffe3953e33e5
md"""# Appendix

> **License** 
> - The mini case Patisserie Cheers (Parts 1-4) and the Newsvendor game as well as the game result survey are subject to [MIT license](https://www.newsvendor.games/license/).

"""

# ╔═╡ 19975a48-0f5f-4f8b-903c-3d93181d81a1
md"""
## Literature
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

Calibrate your utility function to maximize expected utility 
- Kreps, David, Microeconomics for Managers, 2019, [Appendix 4](https://gsb-sites.stanford.edu/micro4managers/wp-content/uploads/sites/33/2021/08/appendix_4-expected_utility_as_a_normative_decision_aide.pdf)
"""

# ╔═╡ 435db58d-1ee9-45d2-89e0-5b7c3d75e9ac


# ╔═╡ 9a2f3b3d-5932-49f9-a775-004b79da899f


# ╔═╡ 82968dd3-b9a4-42c6-bea1-c31285c39f64
md"## ⚙ Setup Appearance"

# ╔═╡ c6d7574b-18b2-49f6-aa22-59b7b7e47247
ChooseDisplayMode()

# ╔═╡ 41ac0852-3555-48b9-a369-3b617adba62b
md"""
- Hide Table of Contents  $(@bind hide_toc html"<input type=checkbox >")
- Reveal hints    $(@bind reveal_hint html"<input type=checkbox >")
- Show code  $(@bind show_ui html"<input type=checkbox >")
"""	


# ╔═╡ c8a88597-c465-4509-82e1-4d38ed44cbee
if @isdefined hide_toc 
	if !hide_toc 
		TableOfContents() 
	end
end

# ╔═╡ 47bad2aa-051e-4ef0-97b6-2d94641b1a5d
if show_ui
md"# Source Code
## Packages
"
else
	md""
end

# ╔═╡ 9955422e-769d-442a-b7d7-edea3156e8f1
if show_ui
	md"## Parameters"
else
	md""
end

# ╔═╡ ecc6cd29-8cbb-4b61-87c1-a7d825f46943
begin
	# nvm1 = NewsvendorModel.NVModel(demand=Truncated(Normal(90, 30), 0, 180), price = 5, cost = 1, salvage = .5)
	# nvm2 = NewsvendorModel.NVModel(demand=Truncated(Normal(90, 30), 0, 180), cost = 1, price = 5, substitute = 1) 
	# nvm3 = NewsvendorModel.NVModel(demand=Truncated(Normal(90, 20), 0, 180), price = 5, cost = 1)
	# nvm4 = NewsvendorModel.NVModel(demand=Truncated(Normal(90, 20), 0, 180), price = 5, cost = 1, salvage = .5, substitute = 1)
	# dprofit = my_round(NewsvendorModel.profit(nvm) )
	# dprofit1 = my_round(NewsvendorModel.profit(nvm1) )
	# dprofit2 = my_round(NewsvendorModel.profit(nvm2) )
	# dprofit3 = my_round(NewsvendorModel.profit(nvm3) )
	# dprofit4 = my_round(NewsvendorModel.profit(nvm4) )
		
	
	# mprofit90 = my_round(30 * NewsvendorModel.profit(nvm, 90) - 5000 )
	# mprofit100 = my_round(30 * NewsvendorModel.profit(nvm, 100) - 5000 )
	# mprofitopt = my_round(30 * NewsvendorModel.profit(nvm) - 5000 )
	# mprofit4 = my_round(30 * NewsvendorModel.profit(nvm4) - 5000 )
	
	# lo90 = round(Int, leftover(nvm, 90))
	# lo100 = round(Int, leftover(nvm, 100))
	# loopt = round(Int, leftover(nvm, q_opt(nvm)))
	# lo4 = round(Int, leftover(nvm4, q_opt(nvm4)))
	# 	md""
end

# ╔═╡ b76aecc2-b80e-446d-958c-9c32c030a085
if show_ui
	md"## Styling and Pluto Sugur"
else
	md""
end

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
	


	md""
end

# ╔═╡ f4036bac-aae8-49bd-905b-548610e4ae75
hint(md""" **SL will be different**, e.g., if we decide about going 149🍰 ➡ 150🍰, then the 150th cake will be left over with probability 95%, and sold with a chance of  5%. (This suggests that adding the 150th cakes is not profitable; instead, we should consider reducting the quantity below 149).
	
	""", """What changes if we ask this question for different stock quantities?""")

# ╔═╡ 2cd86a70-ec86-48e4-8ca3-7f5593380fc1
hint(md""" 

0 < – SL × Cₒ + (1 –  SL) × Cᵤ 

⇔ 0 < – SL × Cₒ + Cᵤ –  SL × Cᵤ 

⇔ SL × Cₒ + SL × Cᵤ < Cᵤ  

⇔ SL × (Cₒ + Cᵤ) < Cᵤ 

⇔ SL < Cᵤ / (Cₒ + Cᵤ) 

⇔ SL < CF

Remark: We assume Cₒ + Cᵤ > 0 when dividing by it in the 2nd to the last step.
	""", """Show that 0 < – SL × Cₒ + (1 – SL) × Cᵤ is equivalent to SL < CF""")

# ╔═╡ c8618313-9982-44e0-a110-2d75c69c75e8
begin
	# # Foldable
	# struct Foldable{C}
	# 	title::String
	# 	content::C
	# end

	# function Base.show(io, mime::MIME"text/html", fld::Foldable)
	# 	write(io,"<details><summary>$(fld.title)</summary><p>")
	# 	show(io, mime, fld.content)
	# 	write(io,"</p></details>")
	# end
	
	# # example
	# # Foldable("What is the gravitational acceleration?", md"Correct, it's ``\pi^2``.")
	
	
	
	# ### Two column
	# struct TwoColumn{L, R}
	# 	left::L
	# 	right::R
	# end

	# function Base.show(io, mime::MIME"text/html", tc::TwoColumn)
	# 	write(io, """<div style="display: flex;"><div style="flex: 50%;">""")
	# 	show(io, mime, tc.left)
	# 	write(io, """</div><div style="flex: 50%;">""")
	# 	show(io, mime, tc.right)
	# 	write(io, """</div></div>""")
	# end
	# # example
	# # 	TwoColumn(md"Note the kink at ``x=0``!", plot(-5:5, abs))

	
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
		pluto-output h3  {                    
		    font-size: 1.2rem    
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

# ╔═╡ d700218c-605d-47c2-b3f2-fcebfad8d633
if show_ui
md"## Functions
###  Computation Helper
"
else
	md""
end

# ╔═╡ ca7a33bf-7198-4161-a3f8-39e432db2623
begin
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

	fixed_cost  = 0

		cheers_1 = NVModel(cost = 1, price = 5, demand = truncated(Normal(90, 30), 0, 180) )   
	cheers_2 = cheers_2 = NVModel(cost = 4, price = 5.5, demand =  Uniform(0, 60))	
	cheers_3 = NVModel(cost = 1.5, price = 9, demand = truncated(Normal(90, 30), 0, 180), salvage = .5 )   
	cheers_4 = NVModel(cost = 10, price = 42, demand = DiscreteNonParametric([0,1,2],[.3,.5,.2]))
	
	md""
end

# ╔═╡ 3f0edfe3-77a2-4e7a-a995-b9548c1130b0
begin		
	
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
	

	
	function show_scenario_data(nvm)
		
		p = nvm.price
		c = nvm.cost
		s = nvm.salvage
		μ = mean(nvm.demand)
		σ = std(nvm.demand)
		u = minimum(nvm.demand)
		l = maximum(nvm.demand)
		distr = nvm.demand
		text = md"""
		* You **pay $(c)** for each unit that you stock.
		* You **get $(p)** for each unit that you sell to your customer.
		* Customer **demand is uncertain** and will be **between $l and $u** every day. 
		* Independent of the demand of the previous day, you **expect μ = $(my_round(μ))** and face uncertainty captured by a standard deviation of **σ = $(my_round(σ, sigdigits=2))**. The distribution is shown in the figure to the right).
		* At the end of each round, unsold units are discarded at a **salvage value** of **$(s)**.
		"""
		
		return TwoColumn(text, Resource("https://github.com/frankhuettner/newsvendor/raw/main/preparation/img/handout_data_viz.png"))
	end; 
	
	show_scenario_data(cheers_1)
end

# ╔═╡ ac888d85-cb85-44da-94b3-bf7095d1714b
TwoColumn(md"""
**Example Patisserie Cheers!**

We learn mean μ = $μ and standard deviation σ = $σ from the case.


""",
	md"""
	

1. **Cᵤ** = $(selling_p) -- $(wholesale_p) = $(Cu);  **Cₒ** = $(wholesale_p) -- $(salvage_val) = $(Co).
2. This gives   CF = $(Cu) / ( $(Cu) + $(Co) ) = $(CF).
3. We target a service level of $(CF). Excel: `=Norm.Inv(0.8, 90, 30)` =  **115.2**. 
	"""
)

# ╔═╡ d1e0bb3d-e84c-41fb-89f7-5af19de47fca
md"""

# Should We Go Up From 90🍰 to  91🍰?



➡ Additional cake will be left over (if we do NOT run out of stock) *or* sells (if we run out of stock); this gives the following calculation:

| What could happen                   | Probability           | Implication        | Expected Impact of 1 More 🍰        |
|----------------------------|-----------------------|--------------------|----------------------|
|91st cake is left over          | 50%         | lose -Cₒ |  0.5 × (-€$(Co))       |
| 91st cake is sold | 50%  | gain Cᵤ | 0.5 × €$(Cu) |
| | | |------------------------------------------------------------|
|                     |                      |                    |       Total:            - 0.5 × $(Co)€ + 0.5 × $(Cu)€ = € $(- 0.5 * Co + 0.5 * Cu) |


➡ Yes, making 91🍰 is better than 90🍰

"""

# ╔═╡ af2769e2-7c52-4a0e-a38e-220f0dee25ab
let
	q_impact
	SL_impact = cdf(distr, q_impact)
	SL_impact_percent = round(100*SL_impact, sigdigits=2) 
	
	md"""
	# More General: Should We Add More 🍰?
	
	
	If we originally planned to make **Q** 🍰, and now consider to go up to **Q+1** 🍰, we get the following calculation:

	
	| What could happen                   | Probability           | Implication        | Expected Impact of 1 More 🍰     |
	|---------------------|-----------------------------|--------------------|---------------------------------------|
	| Q+1th 🍰 is left over          | SL at Q        | -Cₒ |  SL × (-Cₒ)       |
	| Q+1th 🍰 is sold | 100% - SL at  Q |  Cᵤ | (1 - SL) × Cᵤ |
	| | | |----------------------------------------------------------|
	|                     |                      |                |             Total:      - SL × Cₒ + (1 - SL) × Cᵤ |
	
	
	➡ Total **impact** of extra cake **depends on SL, which depends on order quantity**: 
	
		
	###### Q = $q_impact   ➡ SL = $SL_impact_percent%  ➡ Extra cake gives - $SL_impact_percent% × € $(Co) + (1 - $SL_impact_percent%) × € $(Cu) = $(round(- SL_impact * Co + (1 - SL_impact) * Cu; digits=2))


	
	"""
end

# ╔═╡ 1265fc5c-6891-4172-9a38-62c7a56b1371
hint(md""" Adding a tiny unit to 115🍰 still promises more profit, but when going 116🍰 ➡ 117🍰, we would expect to loose money. Thus, 115 or 116 is optimal (theoretically, it's $(my_round( (NewsvendorModel.q_opt(NewsvendorModel.solve(nvm, rounded=false))), sigdigits=4)))
	""", """When should we no more increase the number of cakes?""")

# ╔═╡ f1b55f68-be80-4cd4-a3b8-7f959515ff3c

md"""## Continuous Demand Distributions

**We increase until SL = CF; this gives the optimum**, which typically involves fractions of units
(then check the nearest integers, or simply round, or round up for a pragmatic result)

Consider the [Scenario II of *Cheers!*](https://qz.com/951055/a-new-generation-of-even-faster-fashion-is-leaving-hm-and-zara-in-the-dust), where demand is uniformly distributed between 0 and 60 cakes; selling price is $(cheers_2.price), production cost is $(cheers_2.cost), and the salvage value is again $(cheers_2.salvage). This gives Cu = $(underage_cost(cheers_2)), Co = $(overage_cost(cheers_2)), hence CF = $(critical_fractile(cheers_2) |> my_round).
"""

# ╔═╡ 23caa103-6585-495c-b60a-ead90b280d4d
TwoColumnWideRight(let
	cf = critical_fractile(cheers_2)  |> my_round
	q = q_opt(cheers_2, rounded=false)  |> my_round
	q2 = -1 * 10 + (1 - 1) *32  |> my_round

md"""


- SL(Q*) = $(cf) is true for Q* = $(q), because the fraction of the demand to the left of $(q) is $(q)/60 = 0.273 
- We cannot make 16.4 cakes; rounding gives 16, but 17 is close

"""
end
	,
md"""


$(Resource("https://raw.githubusercontent.com/frankhuettner/newsvendor/main/preparation/img/CheersII_uniform_hint.png"))
""")

# ╔═╡ 05272770-2e4c-48cd-abb4-f5ba1ca327f5
md"""
If we evaluate the expected profit at q, we get 

- q = 16 gives the expected profit = $(profit(cheers_2, 16))
- q = 17 gives the expected profit = $(profit(cheers_2, 17))
- q = 16.4 gives the  expected profit = $(profit(cheers_2, 16.4))

Indeed, 16 seems better than 17, but it's very close and the difference should not matter for practical reasons.
"""

# ╔═╡ b1aef98c-7c87-4192-9de9-7b4fdd4d9cae
let
	q0 = -.3 * 10 + (1 - .3) *32  |> my_round
	q1 = -.8 * 10 + (1 - .8) *32  |> my_round
	q2 = -1 * 10 + (1 - 1) *32  |> my_round

md"""## Discrete Demand Distributions

**We increase as long as SL < CF, and stop if SL ≥ CF**

Example *Cheers!* IV
- CF = 0.76
- Demand outcome and probabilities $(cheers_4.demand |> params)
- This gives SL(0) = 0.3; SL(1) = 0.8; SL(0) = 1
- Hence, we should increase from 0 to 1 cake (because 0.3 < 0.76); but not from 1 cake to 2 cakes  (because 0.8 is not smaller than 0.76)

Remark: Does it work the other way around, i.e., starting with 2 cakes, calculating the incremental profit – SL × Cₒ + (1 – SL) × Cᵤ and go down as long as it's negative? Let's evaluate the expression for our example (Cₒ = 10, Cᵤ = 32) 
- q = 0: $(q0)
- q = 1: $(q1)
- q = 2: $(q2)

It seems we should go down to 0 cakes. The devil is in the detail: – SL × Cₒ + (1 – SL) × Cᵤ evaluates the expected profit of another unit; not of a unit less. The reason is that the definition of SL is about the probability of covering all demand: 

SL(q) = Pr(Demand ≤ q)

With an additional unit, i.e., q + 1 units, we have a chance of SL(q) to have this extra unit left over, paying Cₒ; and chance of 1 – SL(q), paying Cᵤ.



"""
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
Images = "916415d5-f1e6-5110-898d-aaa5f9f070e0"
NewsvendorModel = "63d3702b-073a-45e6-b43c-f47e8b08b809"
PlutoTeachingTools = "661c6b06-c737-4d37-b85c-46df65de6f69"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
ShortCodes = "f62ebe17-55c5-4640-972f-b59c0dd11ccf"

[compat]
Distributions = "~0.25.78"
Images = "~0.25.2"
NewsvendorModel = "~0.2.2"
PlutoTeachingTools = "~0.2.3"
PlutoUI = "~0.7.38"
ShortCodes = "~0.3.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "4043c2db87a7197ee5149b517575a76d31395c7f"

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

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "cc4bd91eba9cdbbb4df4746124c22c0832a460d6"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.1.1"

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

[[deps.ComputationalResources]]
git-tree-sha1 = "52cb3ec90e8a8bea0e62e275ba577ad0f74821f7"
uuid = "ed09eef8-17a6-5b46-8889-db040fac31e3"
version = "0.3.2"

[[deps.CoordinateTransformations]]
deps = ["LinearAlgebra", "StaticArrays"]
git-tree-sha1 = "681ea870b918e7cff7111da58791d7f718067a19"
uuid = "150eb455-5306-5404-9cee-2592286d6298"
version = "0.6.2"

[[deps.CustomUnitRanges]]
git-tree-sha1 = "1a3f97f907e6dd8983b744d2642651bb162a3f7a"
uuid = "dc8bdbbb-1ca9-579f-8c36-e416f6a65cce"
version = "1.0.2"

[[deps.DataAPI]]
git-tree-sha1 = "46d2680e618f8abd007bce0c3026cb0c4a8f2032"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.12.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

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
git-tree-sha1 = "7fe1eff48e18a91946ff753baf834ff4d5c03744"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.78"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DualNumbers]]
deps = ["Calculus", "NaNMath", "SpecialFunctions"]
git-tree-sha1 = "5837a837389fccf076445fce071c8ddaea35a566"
uuid = "fa6b7ba4-c1ee-5f82-b5fc-ecf0adba8f74"
version = "0.6.8"

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

[[deps.HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

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

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[deps.JLD2]]
deps = ["FileIO", "MacroTools", "Mmap", "OrderedCollections", "Pkg", "Printf", "Reexport", "TranscodingStreams", "UUIDs"]
git-tree-sha1 = "1c3ff7416cb727ebf4bab0491a56a296d7b8cf1d"
uuid = "033835bb-8acc-5ee8-8aae-3f567f8a3819"
version = "0.4.25"

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

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "0f960b1404abb0b244c1ece579a0ec78d056a5d1"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.15"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "bf36f528eec6634efc60d7ec062008f171071434"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "3.0.0+1"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Printf", "Requires"]
git-tree-sha1 = "ab9aa169d2160129beb241cb2750ca499b4e90e9"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.17"

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

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "dedbebe234e06e1ddad435f5c6f4b85cd8ce55f7"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "2.2.2"

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
deps = ["Dates"]
git-tree-sha1 = "6c01a9b494f6d2a9fc180a08b182fcb06f0958a0"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.4.2"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f6cf8e7944e50901594838951729a1861e668cb8"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.2"

[[deps.PlutoHooks]]
deps = ["InteractiveUtils", "Markdown", "UUIDs"]
git-tree-sha1 = "072cdf20c9b0507fdd977d7d246d90030609674b"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0774"
version = "0.0.5"

[[deps.PlutoLinks]]
deps = ["FileWatching", "InteractiveUtils", "Markdown", "PlutoHooks", "Revise", "UUIDs"]
git-tree-sha1 = "0e8bcc235ec8367a8e9648d48325ff00e4b0a545"
uuid = "0ff47ea0-7a50-410d-8455-4348d5de0420"
version = "0.1.5"

[[deps.PlutoTeachingTools]]
deps = ["Downloads", "HypertextLiteral", "LaTeXStrings", "Latexify", "Markdown", "PlutoLinks", "PlutoUI", "Random"]
git-tree-sha1 = "d8be3432505c2febcea02f44e5f4396fae017503"
uuid = "661c6b06-c737-4d37-b85c-46df65de6f69"
version = "0.2.3"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

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

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "97aa253e65b784fd13e83774cadc95b38011d734"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.6.0"

[[deps.Quaternions]]
deps = ["LinearAlgebra", "Random"]
git-tree-sha1 = "fd78cbfa5f5be5f81a482908f8ccfad611dca9a9"
uuid = "94ee1d12-ae83-5a48-8b1c-48b8ff168ae0"
version = "0.6.0"

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

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "Pkg", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "dad726963ecea2d8a81e26286f625aee09a91b7c"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.4.0"

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
# ╟─933e018f-7229-4e29-b1ae-c07a19772213
# ╟─3f0edfe3-77a2-4e7a-a995-b9548c1130b0
# ╟─94d60dee-eb01-458c-88fa-567d2111c225
# ╟─b96b3b5b-d88b-402f-8471-86446a42235a
# ╟─fd5ac52c-e5e8-4603-a835-6abd8e4331a1
# ╟─33f4e807-5329-4edc-8b5e-a1cd46c60594
# ╟─ac888d85-cb85-44da-94b3-bf7095d1714b
# ╟─49dbe76a-af43-4026-82ef-cf934954efe9
# ╟─cfd852f3-1e53-476f-b646-743dde2c6481
# ╟─59a24e9b-24f6-4b5b-b41d-88da790b1b02
# ╟─94f0412b-6c34-4b64-8365-9d11dfebd055
# ╟─d7768d12-a3ad-48d7-acb9-2bdd46cc8586
# ╟─85b982ae-6cc2-4b9f-bc38-28c1d91f0c8a
# ╟─f7433a6b-35bc-4d2a-ae3e-a109fcef8960
# ╟─d1e0bb3d-e84c-41fb-89f7-5af19de47fca
# ╟─f4036bac-aae8-49bd-905b-548610e4ae75
# ╟─0de1569c-dae5-4a49-b37d-6acaf89c268f
# ╟─af2769e2-7c52-4a0e-a38e-220f0dee25ab
# ╟─1b412983-074d-4b93-9444-88b92a2dd070
# ╟─1265fc5c-6891-4172-9a38-62c7a56b1371
# ╟─bf2e12f5-09fe-44a1-aaaf-a11611666b1c
# ╟─4c283bff-24ec-419a-b6f8-c81c2803e167
# ╟─2cd86a70-ec86-48e4-8ca3-7f5593380fc1
# ╟─ad76e90c-2964-4d46-98ee-d0a5200dd490
# ╟─49be1a24-02e4-4244-a61e-78113a2b655f
# ╟─f1b55f68-be80-4cd4-a3b8-7f959515ff3c
# ╟─23caa103-6585-495c-b60a-ead90b280d4d
# ╟─05272770-2e4c-48cd-abb4-f5ba1ca327f5
# ╟─c7937922-ea60-41b7-8e26-0bdc0b910ad5
# ╟─b1aef98c-7c87-4192-9de9-7b4fdd4d9cae
# ╟─5c20ba81-7d54-4f2b-9cfd-7d6c815e693f
# ╟─365c61d5-9d5d-4c69-a79b-02d3abff9af8
# ╟─ebe661ef-8a2a-4380-a085-ed91c52eb97f
# ╟─db80883f-d378-4ec1-a9c2-8e3666176941
# ╟─5f3d33b5-c600-452e-a1b6-ffe3953e33e5
# ╟─19975a48-0f5f-4f8b-903c-3d93181d81a1
# ╟─435db58d-1ee9-45d2-89e0-5b7c3d75e9ac
# ╟─9a2f3b3d-5932-49f9-a775-004b79da899f
# ╟─82968dd3-b9a4-42c6-bea1-c31285c39f64
# ╟─c6d7574b-18b2-49f6-aa22-59b7b7e47247
# ╟─41ac0852-3555-48b9-a369-3b617adba62b
# ╟─c8a88597-c465-4509-82e1-4d38ed44cbee
# ╟─47bad2aa-051e-4ef0-97b6-2d94641b1a5d
# ╟─e0d09197-fc18-46e9-b0f9-b513ea32596a
# ╟─e44321cc-abd9-45ad-b106-e141a7fa086e
# ╟─9955422e-769d-442a-b7d7-edea3156e8f1
# ╟─b2c19571-95b1-4b7f-9ec1-ed83ba7b8aef
# ╟─ecc6cd29-8cbb-4b61-87c1-a7d825f46943
# ╟─b76aecc2-b80e-446d-958c-9c32c030a085
# ╟─375b5f20-ff08-4d9a-8d41-38214db962de
# ╟─b89d8514-2b56-4da9-8f49-e464579c2293
# ╟─c8618313-9982-44e0-a110-2d75c69c75e8
# ╟─d700218c-605d-47c2-b3f2-fcebfad8d633
# ╟─ca7a33bf-7198-4161-a3f8-39e432db2623
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
