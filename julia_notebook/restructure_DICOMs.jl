### A Pluto.jl notebook ###
# v0.19.13

using Markdown
using InteractiveUtils

# ╔═╡ fdfd425e-4e62-11ed-186d-1bd72de5dde8
begin
    let
        using Pkg
        Pkg.activate(mktempdir())
        Pkg.Registry.update()
        Pkg.add("PlutoUI")
        Pkg.add("CairoMakie")
        Pkg.add("Statistics")
        Pkg.add("StatsBase")
        Pkg.add("ImageMorphology")
        Pkg.add("CSV")
        Pkg.add("DataFrames")
        Pkg.add(; url="https://github.com/JuliaHealth/DICOM.jl")
        Pkg.add(; url="https://github.com/Dale-Black/DICOMUtils.jl")
    end

    using PlutoUI
    using CairoMakie
    using Statistics
    using StatsBase: quantile!
    using ImageMorphology
    using CSV
    using DataFrames
    using DICOM
    using DICOMUtils
end

# ╔═╡ 38c1647e-5aa6-4202-b3ff-d90f345bb037
TableOfContents()

# ╔═╡ 06d50833-3b1b-4486-8e35-8102ca960f37
root_path = dirname(pwd())

# ╔═╡ df801a76-d5dd-47fa-a641-396fb146acb5
begin
	lookup_folder = "dcms_measurement"
	size_folder = ["small", "medium", "large", "small1", "medium1", "large1"]
	energy_folder = ["80", "135"]
	path = joinpath(root_path, lookup_folder, size_folder[1], energy_folder[1])
end

# ╔═╡ 1e4b0a27-1ddc-43c3-ad61-ac0e3cc859b2
md"""
# Load DICOM Files
"""

# ╔═╡ dc4aa8ac-b7ee-4d84-b96b-0dfe2884330f
dcms = dcmdir_parse(path);

# ╔═╡ 26d0abae-d9ad-4d92-82f3-2272e71843ac
begin
	new_dcms_slice1 = []
	new_dcms_slice2 = []
	new_dcms_slice3 = []
	for i in 1:3
		if i==1
			push!(new_dcms_slice1, dcms[i])
			push!(new_dcms_slice1, dcms[i])
			push!(new_dcms_slice1, dcms[i])
		elseif i==2
			push!(new_dcms_slice2, dcms[i])
			push!(new_dcms_slice2, dcms[i])
			push!(new_dcms_slice2, dcms[i])
		elseif i==3
			push!(new_dcms_slice3, dcms[i])
			push!(new_dcms_slice3, dcms[i])
			push!(new_dcms_slice3, dcms[i])
		end
		# if i==1 || i==4 || i==7
		# 	dcms[1][tag"Instance Number"] = 1
		# 	push!(new_dcms, dcms[1])
		# end

		# if i==2 || i==5 || i==8
		# 	dcms[2][tag"Instance Number"] = 2
		# 	push!(new_dcms, dcms[2])
		# end

		# if i==3 || i==6 || i==9
		# 	dcms[3][tag"Instance Number"] = 3
		# 	push!(new_dcms, dcms[3])
		# end
	end
end

# ╔═╡ 90ef7629-662d-4049-9e49-97b825713092
begin
	new_dcms_slice1[1][tag"Instance Number"] = 1
	new_dcms_slice1[2][tag"Instance Number"] = 2
	new_dcms_slice1[3][tag"Instance Number"] = 3
end

# ╔═╡ 6c5a5f22-46dc-46cd-9e6a-a2826c08d017
new_dcms_slice1[1][tag"Instance Number"]

# ╔═╡ a6ec1b9a-66c9-4abb-89a9-6a23a3ff3a73
# for i in 1:3
# 	new_dcms_slice1[i][tag"Instance Number"] = i
# 	new_dcms_slice2[i][tag"Instance Number"] = i
# 	new_dcms_slice3[i][tag"Instance Number"] = i
# end

# ╔═╡ d12ce3cb-2e11-4468-af29-eb63af303f92
# begin
# 	edited_dcms[1][tag"Instance Number"] = 1
# 	edited_dcms[2][tag"Instance Number"] = 2
# 	edited_dcms[3][tag"Instance Number"] = 3
# 	edited_dcms[4][tag"Instance Number"] = 1
# 	edited_dcms[5][tag"Instance Number"] = 2
# 	edited_dcms[6][tag"Instance Number"] = 3
# 	edited_dcms[7][tag"Instance Number"] = 1
# 	edited_dcms[8][tag"Instance Number"] = 2
# 	edited_dcms[9][tag"Instance Number"] = 3
# end

# ╔═╡ 1bf45f3f-1dea-47c6-984d-bd3add422993
dir = readdir(path)

# ╔═╡ 72d3d68a-33c2-4112-8a25-f13eaa5c5473
path_file = joinpath(path, dir[1])

# ╔═╡ 6bafb525-389b-4018-ae72-de5cfa6172d8
begin
	output_folder = "dcms_measurement_new"
	output_path = joinpath(root_path, output_folder, size_folder[1], energy_folder[1])

	if !isdir(output_path)
		mkpath(output_path)
	end
end

# ╔═╡ 808604cb-d3e0-4af6-9836-cc3ffc00c13a
cp()

# ╔═╡ Cell order:
# ╠═fdfd425e-4e62-11ed-186d-1bd72de5dde8
# ╠═38c1647e-5aa6-4202-b3ff-d90f345bb037
# ╠═06d50833-3b1b-4486-8e35-8102ca960f37
# ╠═df801a76-d5dd-47fa-a641-396fb146acb5
# ╟─1e4b0a27-1ddc-43c3-ad61-ac0e3cc859b2
# ╠═dc4aa8ac-b7ee-4d84-b96b-0dfe2884330f
# ╠═26d0abae-d9ad-4d92-82f3-2272e71843ac
# ╠═90ef7629-662d-4049-9e49-97b825713092
# ╠═6c5a5f22-46dc-46cd-9e6a-a2826c08d017
# ╠═a6ec1b9a-66c9-4abb-89a9-6a23a3ff3a73
# ╠═d12ce3cb-2e11-4468-af29-eb63af303f92
# ╠═1bf45f3f-1dea-47c6-984d-bd3add422993
# ╠═72d3d68a-33c2-4112-8a25-f13eaa5c5473
# ╠═6bafb525-389b-4018-ae72-de5cfa6172d8
# ╠═808604cb-d3e0-4af6-9836-cc3ffc00c13a
