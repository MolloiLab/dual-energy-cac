### A Pluto.jl notebook ###
# v0.19.4

using Markdown
using InteractiveUtils

# ╔═╡ 01fe7259-ef09-45a0-bf1b-7b1276aaad3d
begin
	let
		using Pkg
		Pkg.activate(mktempdir())
		Pkg.Registry.update()
		Pkg.add("PlutoUI")
		Pkg.add("CairoMakie")
		Pkg.add("Statistics")
		Pkg.add("ImageMorphology")
		Pkg.add("DataFrames")
		Pkg.add("CSV")
		Pkg.add("MAT")
	end
	
	using PlutoUI
	using CairoMakie
	using Statistics
	using ImageMorphology
	using DataFrames
	using MAT
	using CSV
end

# ╔═╡ 86e2dfb0-7fbb-11ec-26c0-5d55c499ebc6
TableOfContents()

# ╔═╡ 29c32fb0-f961-4794-9f9f-0a1f91898111
md"""
###  Segmentation
"""

# ╔═╡ 624f9db8-2fe9-4a11-b90f-402d397b3709
#path = "C:\\Users\\xings\\Documents\\Xingshuo\\Research\\Material Decomposition\\patient size\\Medium\\100mg135kVpMedium.mat"

# ╔═╡ 4666ed27-97bf-4096-a939-b8ab204697ab
begin
	file = matopen(path);
	I_high = read(file);
	close(file)
end

# ╔═╡ 12b261eb-d092-4565-a761-de758796c60d
calibration_rod = transpose(I_high["I_high"])[315:385,190:250];

# ╔═╡ 09556a3b-19c7-4cda-97c7-47a1450571c0
begin
	fig1 = Figure()
	
	ax1 = Makie.Axis(fig1[1, 1])
	ax1.title = "High kVp"
	heatmap!(calibration_rod, colormap=:grays)
	fig1
end

# ╔═╡ cff1e699-7672-468b-a14b-907f6348ce60
high_mask = calibration_rod .> 0;

# ╔═╡ db232de3-651c-4352-8dd0-2c98e75c0eb9
begin
	fig3 = Figure()
	
	ax3 = Makie.Axis(fig3[1, 1])
	ax3.title = "High Mask"
	heatmap!(high_mask, colormap=:grays)
	fig3
end

# ╔═╡ 5343cbe2-5e65-4a93-8f70-a56c49c50a96
core = Bool.(erode(erode(erode(erode(high_mask)))));

# ╔═╡ 7b339826-0b08-4b5d-8fc4-f10ee452961f
mean_high = mean(calibration_rod[core])

# ╔═╡ 2f3616f5-7016-43e2-8d8a-8358a716a91e
begin
	fig5 = Figure()
	
	ax5 = Makie.Axis(fig5[1, 1])
	ax5.title = "core"
	heatmap!(transpose(I_high["I_high"])[315:385,190:250].*core, colormap=:grays)
	fig5
end

# ╔═╡ e196a556-bc56-4be0-a020-c9638c9045af
md"""
### Prepare Dataframe
"""

# ╔═╡ 4bc6aeac-73f2-4967-a1bb-ad4e16841421
High_Intensity = Vector{Float64}();

# ╔═╡ 204009be-040c-4ab3-873b-65f5d07b2c63
Low_Intensity = Vector{Float64}();

# ╔═╡ b0135550-2ca5-4375-9ef5-e44d16d47b66
Density = Vector{Int64}();

# ╔═╡ 807efaa0-95a5-4247-a2b3-d8ef3f281303
md"""
### Import Files
"""

# ╔═╡ 2aa9c968-f60a-42b2-884e-5e953f41d097
cd("C:\\Users\\xings\\Documents\\Xingshuo\\Research\\Material Decomposition\\patient size\\Medium");

# ╔═╡ 0a4bf8f9-c11b-4d82-a482-85d20621f6c8
files = readdir()

# ╔═╡ 394c98f9-4abc-4d7a-bfcc-fb01112cff72
for f in files
	p = joinpath(pwd(),f)
	f0 = matopen(p)
	f1 = read(f0);
	close(f0)
	
	if f[3] == 'm'
		d = parse(Int64,SubString(f, 1:2));
		s =SubString(f, 5);
		if s[3] == 'k'
			i = parse(Int64,s[1:2])
			r = transpose(f1["I_low"])[315:385,190:250];
		else
			i = parse(Int64,s[1:3])
			r = transpose(f1["I_high"])[315:385,190:250];
		end
	else
		d = parse(Int64,SubString(f, 1:3));
		s =SubString(f, 6);
		if s[3] == 'k'
			i = parse(Int64,SubString(s, 1:2))
			r = transpose(f1["I_low"])[315:385,190:250];
		else
			i = parse(Int64,SubString(s, 1:3))
			r = r = transpose(f1["I_high"])[315:385,190:250];
		end
	end
	
	if d ∉ Density
		push!(Density, d)
	end
	

	
	if i == 135
		h = mean(r[core]);
		push!(High_Intensity,h)
	else
		l =  mean(r[core]);
		push!(Low_Intensity,l)
	end
		
		
	
end

# ╔═╡ 82158420-e098-4fa9-ad0e-9e903e68dcfa
df1 = sort!(DataFrame(calcium = Density, high_energy = High_Intensity[1:11],low_energy = Low_Intensity[1:11]),[:calcium])

# ╔═╡ e2903b41-f4c6-4a87-8476-1c445775df01
begin
	fig2 = Figure()
	ax2 = Makie.Axis(fig2[1, 1])
	#ax2.title("Density vs Intensity")
	
	scatter!(df1[!,"calcium"],df1[!,"high_energy"],label = "High Energy",color=:blue)
	scatter!(df1[!,"calcium"], df1[!,"low_energy"],label = "Low Energy", color=:red)
	ax2.xlabel = "Density (mg/cc)"
	ax2.ylabel = "Intensity (HU)"
	fig2[1, 2] = Legend(fig2, ax2, framevisible = false)
	
	fig2
end

# ╔═╡ f4a475ed-8a5c-47dd-80d1-48f5ac655174
cd("C:\\Users\\xings\\Documents\\Xingshuo\\Research\\")

# ╔═╡ eb17abd1-0921-45d0-af69-e8e47ed8bf4d
#outputPath = joinpath(pwd(),"Material Decomposition\\patient size\\mediumCalibration.csv")

# ╔═╡ 4c9457d7-2bf7-41f4-9ef9-9cc58947375b
# CSV.write(outputPath,df1)

# ╔═╡ Cell order:
# ╠═01fe7259-ef09-45a0-bf1b-7b1276aaad3d
# ╠═86e2dfb0-7fbb-11ec-26c0-5d55c499ebc6
# ╟─29c32fb0-f961-4794-9f9f-0a1f91898111
# ╠═624f9db8-2fe9-4a11-b90f-402d397b3709
# ╠═4666ed27-97bf-4096-a939-b8ab204697ab
# ╠═12b261eb-d092-4565-a761-de758796c60d
# ╟─09556a3b-19c7-4cda-97c7-47a1450571c0
# ╠═cff1e699-7672-468b-a14b-907f6348ce60
# ╟─db232de3-651c-4352-8dd0-2c98e75c0eb9
# ╠═5343cbe2-5e65-4a93-8f70-a56c49c50a96
# ╠═7b339826-0b08-4b5d-8fc4-f10ee452961f
# ╟─2f3616f5-7016-43e2-8d8a-8358a716a91e
# ╟─e196a556-bc56-4be0-a020-c9638c9045af
# ╠═4bc6aeac-73f2-4967-a1bb-ad4e16841421
# ╠═204009be-040c-4ab3-873b-65f5d07b2c63
# ╠═b0135550-2ca5-4375-9ef5-e44d16d47b66
# ╟─807efaa0-95a5-4247-a2b3-d8ef3f281303
# ╠═2aa9c968-f60a-42b2-884e-5e953f41d097
# ╠═0a4bf8f9-c11b-4d82-a482-85d20621f6c8
# ╠═394c98f9-4abc-4d7a-bfcc-fb01112cff72
# ╠═82158420-e098-4fa9-ad0e-9e903e68dcfa
# ╠═e2903b41-f4c6-4a87-8476-1c445775df01
# ╠═f4a475ed-8a5c-47dd-80d1-48f5ac655174
# ╠═eb17abd1-0921-45d0-af69-e8e47ed8bf4d
# ╠═4c9457d7-2bf7-41f4-9ef9-9cc58947375b
