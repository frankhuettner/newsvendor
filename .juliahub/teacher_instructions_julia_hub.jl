### A Pluto.jl notebook ###
# v0.16.1

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ f781cb20-578a-4d06-87fd-0c3a2f7428c0
using PlutoUI

# ╔═╡ bafbedc4-3617-400c-b50d-89d986523930
md" You have currently $(round(Int,Sys.free_memory() / 2^20)) MB free memory";

# ╔═╡ 7d80f9e4-c240-4db5-892c-ab6bf4952d97
md" 
# Running the Simulation on JuliaHub

### 👉 Step 0
Your total memory is $(round(Int,Sys.total_memory() / 2^20)) MB. This is **enough for roughly $(round(Int,  (Sys.total_memory() / 2^20 - 900) / 600   )) students or $(round(Int,  (Sys.total_memory() / 2^20 - 900) / 600   )) teams.**

(It might be a good idea to use multiple machines to distribute the communication load.)"

# ╔═╡ 2d27fdd4-b5c7-4a4b-a2a2-a839e758baf9


# ╔═╡ 44669039-0e22-4725-8710-7a16d166c0a8
md""" ### 👉 Step 1
You need your Juliahub Pluto session code. It is the part of the url of your Pluto session at Juliahub, which appears in the begining, directly before ".lauch"

![](https://github.com/frankhuettner/newsvendor/blob/main/img/readme/instructor_JH_url.png?raw=true)

"""

# ╔═╡ 36df0109-7a16-4260-aee7-81b322ed0abe
md"""**Enter YOUR session code here:** ``~`` $(@bind server_instance TextField(default="lr0fi"))"""

# ╔═╡ 92c5398e-cc1f-40cb-a439-1b807465981e


# ╔═╡ f5679d05-87f3-4e51-ad63-093a07cc52ff
begin
		
	sim_url = "https://github.com/frankhuettner/newsvendor/blob/main/notebooks/cheers_sim.jl"
	
	sim_url = "https://git.io/JKceu"
	
	juliahub_url = "https://" * server_instance * ".launch.juliahub.app/"
	
	url = juliahub_url * "open?url=" * sim_url

	
	md""" ### 👉 Step 2
	You can now share the url below with your students (it will start a new instance for each student):

	###### $(url)
	"""
end

# ╔═╡ a584bf7c-79ed-4029-b3fb-e5ee5298a4bc


# ╔═╡ 35932830-3f45-48df-9b66-dbacf54b140c
md"""

#### 💡 Tip

We strongly recommend that you **open a simulation by yourself 5 min before class.** This will **preload the needed packages** for the simulation. Thereafter, it will only take 1 minute for a student.

"""

# ╔═╡ 968567bf-143d-43f3-bbfa-19aa2c3e3b04


# ╔═╡ 381fda26-0aa1-4312-b0c1-e26de79bbb55
md"""
#### 💡 If you want students working together,...

then open the link above by yourself in a new browser tab for each team (or give the team leader the task to open the link). The simulation opens and the **url in the browser will change**, to something like 

`https://lr0fi.launch.juliahub.app/edit?id=85960940-24f6-11ec-0845-9de8558dfdf4`

(notice the word **"edit"** instead of **"open"** and a long number id)


Sharing these URLs (with the "edit") will not open a new instance but allows different players to jointly play in the same simulation.

"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.14"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[HypertextLiteral]]
git-tree-sha1 = "72053798e1be56026b81d4e2682dbe58922e5ec9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.0"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "a8709b968a1ea6abc2dc1967cb1db6ac9a00dfb6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.0.5"

[[PlutoUI]]
deps = ["Base64", "Dates", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "d1fb76655a95bf6ea4348d7197b22e889a4375f4"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.14"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
"""

# ╔═╡ Cell order:
# ╟─7d80f9e4-c240-4db5-892c-ab6bf4952d97
# ╟─2d27fdd4-b5c7-4a4b-a2a2-a839e758baf9
# ╟─44669039-0e22-4725-8710-7a16d166c0a8
# ╟─36df0109-7a16-4260-aee7-81b322ed0abe
# ╟─92c5398e-cc1f-40cb-a439-1b807465981e
# ╟─f5679d05-87f3-4e51-ad63-093a07cc52ff
# ╟─a584bf7c-79ed-4029-b3fb-e5ee5298a4bc
# ╟─35932830-3f45-48df-9b66-dbacf54b140c
# ╟─968567bf-143d-43f3-bbfa-19aa2c3e3b04
# ╟─381fda26-0aa1-4312-b0c1-e26de79bbb55
# ╟─f781cb20-578a-4d06-87fd-0c3a2f7428c0
# ╟─bafbedc4-3617-400c-b50d-89d986523930
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
