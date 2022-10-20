### A Pluto.jl notebook ###
# v0.19.13

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

# ╔═╡ 01fe7259-ef09-45a0-bf1b-7b1276aaad3d
# ╠═╡ show_logs = false
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
		Pkg.add("DataFrames")
		Pkg.add("CSV")
		Pkg.add("MAT")
		Pkg.add("LsqFit")
		Pkg.add("DICOM")
		Pkg.add(url="https://github.com/Dale-Black/DICOMUtils.jl")
	end
	
	using PlutoUI
	using CairoMakie
	using Statistics
	using StatsBase
	using ImageMorphology
	using DataFrames
	using MAT
	using CSV
	using LsqFit
	using DICOM
	using DICOMUtils
end

# ╔═╡ 86e2dfb0-7fbb-11ec-26c0-5d55c499ebc6
TableOfContents()

# ╔═╡ 29c32fb0-f961-4794-9f9f-0a1f91898111
md"""
#  Segmentation
"""

# ╔═╡ 4cfef276-751a-4746-9b5b-7bf38bb24b79
_size = "large"

# ╔═╡ b9d34b46-5844-4830-ae59-eef44831b138
root = joinpath(dirname(pwd()), "dcms_calibration", _size)

# ╔═╡ 02e01a44-9c7b-4881-9a2c-21125da82e9a
md"""
## Low Energy
"""

# ╔═╡ 624f9db8-2fe9-4a11-b90f-402d397b3709
path = string(root, "/80")

# ╔═╡ 4666ed27-97bf-4096-a939-b8ab204697ab
begin
	dcm = dcmdir_parse(path)
	dcm_array = load_dcm_array(dcm)
end;

# ╔═╡ 1e35d893-fa80-4350-967d-64732c4cb1ea
dcm

# ╔═╡ 77291dcf-b147-4f13-b932-8a83bec99aa7
if _size == "small"
	center_insert1, center_insert2 = 187, 318
elseif _size == "medium"
	center_insert1, center_insert2 = 238, 365
elseif _size == "large"
	center_insert1, center_insert2 = 285, 415
end

# ╔═╡ 407d0840-b80e-4d1e-b664-3f3798d66932
let
	f = Figure()
	ax = Makie.Axis(f[1, 1])
	heatmap!(ax, dcm_array[:, :, 5]; colormap=:grays)
	scatter!(ax, 
        center_insert1:center_insert1,
        center_insert2:center_insert2;
        markersize=10,
        color=:red,
    )
	f
end

# ╔═╡ 12b261eb-d092-4565-a761-de758796c60d
begin
	calibration_rod = zeros(25, 25, size(dcm_array, 3))
	
	for z in axes(dcm_array, 3)
		rows, cols, depth = size(dcm_array)
		half_row, half_col = center_insert1, center_insert2
		offset = 12
		row_range = half_row-offset:half_row+offset
		col_range = half_col-offset:half_col+offset	
		calibration_rod[:, :, z] .= dcm_array[row_range, col_range, z];
	end
end

# ╔═╡ 913e6c16-6e06-484f-9d35-4051546c01ec
@bind a PlutoUI.Slider(1:7, show_value=true)

# ╔═╡ a899ae02-ab0c-4741-a34a-db395b982cdb
heatmap(calibration_rod[:, :, a], colormap=:grays)

# ╔═╡ 30162a78-23da-42bf-aaea-005f93e84be5
mean(calibration_rod[:, :, a])

# ╔═╡ 715a1532-0ab2-4a99-b886-60ed488760a7
begin
	means1 = []
	for z in axes(calibration_rod, 3)
		append!(means1, mean(calibration_rod[:, :, z]))
	end
end

# ╔═╡ a5d5d874-6ea8-42b2-a691-de6881446a26
means1

# ╔═╡ 55038797-761f-453b-866f-e13f832b011c
md"""
## High Energy
"""

# ╔═╡ a746d138-8031-4fb1-aef3-5d0e1d9f733c
path2 = string(root, "/135")

# ╔═╡ dd8431bc-5036-4ca7-9cb3-a0b5093ced18
begin
	dcm2 = dcmdir_parse(path2)
	dcm_array2 = load_dcm_array(dcm2)
end;

# ╔═╡ c525308b-c29c-4e46-b3a0-896374de8d40
let
	f = Figure()
	ax = Makie.Axis(f[1, 1])
	heatmap!(ax, dcm_array2[:, :, 1])
	scatter!(ax, 
        center_insert1:center_insert1,
        center_insert2:center_insert2;
        markersize=10,
        color=:red,
    )
	f
end

# ╔═╡ d8ebc18a-bf32-413d-8479-2722261a07a2
begin
	calibration_rod2 = zeros(25, 25, size(dcm_array, 3))
	
	for z in axes(dcm_array2, 3)
		rows, cols, depth = size(dcm_array2)
		half_row, half_col = center_insert1, center_insert2
		offset = 12
		row_range = half_row-offset:half_row+offset
		col_range = half_col-offset:half_col+offset	
		calibration_rod2[:, :, z] .= dcm_array2[row_range, col_range, z];
	end
end

# ╔═╡ 52855bed-17f3-4f7b-9714-937b3f93b434
begin
	means2 = []
	for z in axes(calibration_rod2, 3)
		append!(means2, mean(calibration_rod2[:, :, z]))
	end
end

# ╔═╡ d420ce86-f83b-4685-87f9-3904a4b98750
means2

# ╔═╡ 441f2c0f-551b-4e71-8b8a-4952ef9a0265


# ╔═╡ a2340015-3792-4bd6-ad01-71aa110551fe
md"""

# Calibration Equation

Let's apply the calibration formula found in [An accurate method for direct dual-energy calibration and decomposition](https://www.researchgate.net/publication/20771282_An_accurate_method_for_direct_dual-energy_calibration_and_decomposition)

```math
\begin{aligned}	F = \frac{a_o + a_1x + a_2y + a_3x^2 + a_4xy + a_5y^2}{1 + b_1x + b_2y} 
\end{aligned}
\tag{1}
```

"""

# ╔═╡ 0fc12e78-57b4-4411-afe9-b01145084737
multimodel(x, p) = (p[1] .+ (p[2] .* x[:, 1]) .+ (p[3] .* x[:, 2]) .+ (p[4] .* x[:, 1].^2) .+ (p[5] .* x[:, 1] .* x[:, 2]) .+ (p[6] .* x[:, 2].^2)) ./ (1 .+ (p[7] .* x[:, 1]) + (p[8] .* x[:, 2]))

# ╔═╡ df84f63e-5246-4da9-b226-7b75a93fe103
md"""
Model needs some starting parameters. These might need to be adjusted to improve the fitting. We can also investigate a better technique
"""

# ╔═╡ a683e787-4677-4e8e-bde6-a3095981f616
p0 = [0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2, 0.2]

# ╔═╡ 14fa4199-50d0-4b67-9bfd-1640a3b82889
calculated_intensities = hcat(means1, means2)

# ╔═╡ 6782d259-3d00-4293-88a7-3a7ac5aecc87
calcium_densities = [
	25
	50
	100
	150
	200
	250
	300
	350
	400
	450
	500
	550
	600
	650
	750
	800
]

# ╔═╡ 4667f340-4096-4b92-bac9-1bae5fecd953
md"""
## Fit Parameters
"""

# ╔═╡ 269bb44e-0dce-42dd-ba9f-9e2ce8051cb7
params_ca = LsqFit.curve_fit(multimodel, calculated_intensities, calcium_densities, p0).param

# ╔═╡ ecd323a1-ceba-4924-ae8d-f8fe71fe2a7e
md"""
# Check Results
"""

# ╔═╡ bf9e8fe8-92ae-4bd2-84b5-8bf28da5ad69
function predict_concentration(x, y, p)
	A = p[1] + (p[2] * x) + (p[3] * y) + (p[4] * x^2) + (p[5] * x * y) + (p[6] * y^2)
	B = 1 + (p[7] * x) + (p[8] * y)
	F = A / B
end

# ╔═╡ 50657646-5c99-4a9d-be0c-7d39db72aad7
begin
	predicted_densities = []
	
	for i in 1:length(calcium_densities)
		append!(
			predicted_densities, 
			predict_concentration(
				means1[i], 
				means2[i], 
				params_ca
			)
		)
	end
end

# ╔═╡ 9bf8e56d-abcf-4830-a204-ec3cae9f0c69
md"""
## Show in Dataframe
"""

# ╔═╡ b50622d4-b15f-46ee-b476-3cfb74ddf765
df = DataFrame(
	calcium_densities = calcium_densities,
	predicted_densities = predicted_densities,
	mean_intensities_low = means1,
	mean_intensities_high = means2,
)

# ╔═╡ 61c98667-82e6-4583-a328-f2e2c48474c6
rmsd(Float64.(calcium_densities), Float64.(predicted_densities))

# ╔═╡ 3b432411-31fa-48ec-b7fc-19807b193447
md"""
# Save Parameters
"""

# ╔═╡ 65a01fd9-15ee-4b03-89af-6dfe91693571
df_params = DataFrame(params_ca = params_ca)

# ╔═╡ 9f36fac1-c907-49aa-b3df-c92db6b03570
path_csv = string(dirname(pwd()), "/calibration_params/", _size, ".csv")

# ╔═╡ 17829cd4-f6d1-40da-a0f8-1c18e2cc735c
CSV.write(path_csv, df_params)

# ╔═╡ Cell order:
# ╠═01fe7259-ef09-45a0-bf1b-7b1276aaad3d
# ╠═86e2dfb0-7fbb-11ec-26c0-5d55c499ebc6
# ╟─29c32fb0-f961-4794-9f9f-0a1f91898111
# ╠═4cfef276-751a-4746-9b5b-7bf38bb24b79
# ╠═b9d34b46-5844-4830-ae59-eef44831b138
# ╟─02e01a44-9c7b-4881-9a2c-21125da82e9a
# ╠═624f9db8-2fe9-4a11-b90f-402d397b3709
# ╠═4666ed27-97bf-4096-a939-b8ab204697ab
# ╠═1e35d893-fa80-4350-967d-64732c4cb1ea
# ╠═77291dcf-b147-4f13-b932-8a83bec99aa7
# ╟─407d0840-b80e-4d1e-b664-3f3798d66932
# ╠═12b261eb-d092-4565-a761-de758796c60d
# ╟─913e6c16-6e06-484f-9d35-4051546c01ec
# ╠═a899ae02-ab0c-4741-a34a-db395b982cdb
# ╠═30162a78-23da-42bf-aaea-005f93e84be5
# ╠═715a1532-0ab2-4a99-b886-60ed488760a7
# ╠═a5d5d874-6ea8-42b2-a691-de6881446a26
# ╟─55038797-761f-453b-866f-e13f832b011c
# ╠═a746d138-8031-4fb1-aef3-5d0e1d9f733c
# ╠═dd8431bc-5036-4ca7-9cb3-a0b5093ced18
# ╠═c525308b-c29c-4e46-b3a0-896374de8d40
# ╠═d8ebc18a-bf32-413d-8479-2722261a07a2
# ╠═52855bed-17f3-4f7b-9714-937b3f93b434
# ╠═d420ce86-f83b-4685-87f9-3904a4b98750
# ╠═441f2c0f-551b-4e71-8b8a-4952ef9a0265
# ╟─a2340015-3792-4bd6-ad01-71aa110551fe
# ╠═0fc12e78-57b4-4411-afe9-b01145084737
# ╟─df84f63e-5246-4da9-b226-7b75a93fe103
# ╠═a683e787-4677-4e8e-bde6-a3095981f616
# ╠═14fa4199-50d0-4b67-9bfd-1640a3b82889
# ╠═6782d259-3d00-4293-88a7-3a7ac5aecc87
# ╟─4667f340-4096-4b92-bac9-1bae5fecd953
# ╠═269bb44e-0dce-42dd-ba9f-9e2ce8051cb7
# ╟─ecd323a1-ceba-4924-ae8d-f8fe71fe2a7e
# ╠═bf9e8fe8-92ae-4bd2-84b5-8bf28da5ad69
# ╠═50657646-5c99-4a9d-be0c-7d39db72aad7
# ╟─9bf8e56d-abcf-4830-a204-ec3cae9f0c69
# ╠═b50622d4-b15f-46ee-b476-3cfb74ddf765
# ╠═61c98667-82e6-4583-a328-f2e2c48474c6
# ╟─3b432411-31fa-48ec-b7fc-19807b193447
# ╠═65a01fd9-15ee-4b03-89af-6dfe91693571
# ╠═9f36fac1-c907-49aa-b3df-c92db6b03570
# ╠═17829cd4-f6d1-40da-a0f8-1c18e2cc735c
