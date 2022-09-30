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

# ╔═╡ db978680-24b3-11ed-338e-d18072c03678
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
        Pkg.add("ImageFiltering")
        Pkg.add("CSV")
        Pkg.add("DataFrames")
        Pkg.add("GLM")
        Pkg.add(; url="https://github.com/JuliaHealth/DICOM.jl")
        Pkg.add(; url="https://github.com/Dale-Black/DICOMUtils.jl")
        Pkg.add(; url="https://github.com/Dale-Black/PhantomSegmentation.jl")
        Pkg.add("ImageComponentAnalysis")
        Pkg.add("Tables")
    end

    using PlutoUI
    using CairoMakie
    using Statistics
    using StatsBase: quantile!
    using ImageMorphology
    using ImageFiltering
    using CSV
    using DataFrames
    using GLM
    using DICOM
    using DICOMUtils
    using PhantomSegmentation
    using ImageComponentAnalysis
    using Tables
end

# ╔═╡ 7f5a24e6-e9b0-4a72-a9fa-98ab01a20125
TableOfContents()

# ╔═╡ 818de283-2626-4afd-9465-ee065dfaff8d
md"""
## Mask Overlay
"""

# ╔═╡ 562b6c00-5470-4437-9e50-a75bf1ddd030
function collect_tuple(tuple_array)
    row_num = size(tuple_array)
    col_num = length(tuple_array[1])
    container = zeros(Int64, row_num..., col_num)
    for i in 1:length(tuple_array)
        container[i, :] = collect(tuple_array[i])
    end
    return container
end

# ╔═╡ cf5b409e-2f02-4dec-afe4-3cf26dab0cd8
function overlay_mask_bind(mask)
    indices = findall(x -> x == 1, mask)
    indices = Tuple.(indices)
    label_array = collect_tuple(indices)
    zs = unique(label_array[:, 3])
    return PlutoUI.Slider(1:length(zs); default=25, show_value=true)
end;

# ╔═╡ 0358fdb5-f07e-4925-8fbf-8f7928565034
function overlay_mask_plot(array, mask, var, title::AbstractString)
    indices = findall(x -> x == 1, mask)
    indices = Tuple.(indices)
    label_array = collect_tuple(indices)
    zs = unique(label_array[:, 3])
    indices_lbl = findall(x -> x == zs[var], label_array[:, 3])

    fig = Figure()
    ax = Makie.Axis(fig[1, 1])
    ax.title = title
    heatmap!((array[:, :, zs[var]]); colormap=:grays)
    scatter!(
        label_array[:, 1][indices_lbl],
        label_array[:, 2][indices_lbl];
        markersize=1,
        color=:red,
    )
    return fig
end;

# ╔═╡ 013acd6e-0465-46c9-83b1-97613ebdee53
begin
	SIZE = "small";
	root_new = string(
        "/Users/xings/Google Drive/Research/dual energy/Segmentation/",
        SIZE,
        "/",
    )
    mask_L_HD = Array(CSV.read(string(root_new, "mask_L_HD.csv"), DataFrame; header=false))
	mask_M_HD = Array(CSV.read(string(root_new, "mask_M_HD.csv"), DataFrame; header=false))
    mask_S_HD = Array(CSV.read(string(root_new, "mask_S_HD.csv"), DataFrame; header=false))
	mask_L_MD = Array(CSV.read(string(root_new, "mask_L_MD.csv"), DataFrame; header=false))
	mask_M_MD = Array(CSV.read(string(root_new, "mask_M_MD.csv"), DataFrame; header=false))
	mask_S_MD = Array(CSV.read(string(root_new, "mask_S_MD.csv"), DataFrame; header=false))
    mask_L_LD = Array(CSV.read(string(root_new, "mask_L_LD.csv"), DataFrame; header=false))
    mask_M_LD = Array(CSV.read(string(root_new, "mask_M_LD.csv"), DataFrame; header=false))
    mask_S_LD = Array(CSV.read(string(root_new, "mask_S_LD.csv"), DataFrame; header=false))
end;

# ╔═╡ 4526ec32-2491-41be-91c4-03f545f9733c
masks = mask_L_HD+mask_L_MD+mask_L_LD+mask_M_HD+mask_M_MD+mask_M_LD+mask_S_HD+mask_S_MD+mask_S_LD;

# ╔═╡ fb440caa-f753-4b86-b6f2-fed47e31e94d
begin
	pth = string("/Users/xings/Google Drive/Research/dual energy/validation_originalsize_dcms/",SIZE, "1/", 135,"/")
	header, dcm, _ = dcm_reader(pth)
end;

# ╔═╡ ff366ede-a201-48da-9f59-638c9907ed72
begin
	pixel_size = DICOMUtils.get_pixel_size(header)
end

# ╔═╡ af62f7d2-8b32-40de-a789-99b112be3852
begin
    masks_3D = Array{Bool}(undef, size(dcm))
    for z in 1:size(dcm, 3)
        masks_3D[:, :, z] = masks
    end
end;

# ╔═╡ 25f36ebb-0b26-4f27-b42a-3ee08afb9496
@bind v1 overlay_mask_bind(masks_3D)

# ╔═╡ bef52d62-75f0-450e-83df-9f635dad2f5b
overlay_mask_plot(dcm, dilate(dilate(masks_3D)), v1, "masks overlayed")

# ╔═╡ 0f0bbe0d-a20f-4380-8e7e-cafd4e38cfe3
@bind c PlutoUI.Slider(1:size(dcm, 3), default=5, show_value=true)

# ╔═╡ 38fe9e90-f756-4972-bafb-491a65413542
heatmap(transpose(dcm[:,:,c]); colormap=:grays)

# ╔═╡ 4807a059-3711-4839-96c6-a3f1ce8b3c7c
md"""
## Load Calibration Parameters
"""

# ╔═╡ c268d8f1-706f-43d8-9d3d-dc4072666451
begin
	param_base_pth = "/Users/xings/Google Drive/Research/dual energy/Calibration/"
	small_pth = string(param_base_pth,"smallCalibration.csv")
	med_pth = string(param_base_pth,"mediumCalibration.csv")
	large_pth = string(param_base_pth,"largeCalibration.csv")
	small_param = DataFrame(CSV.File(small_pth))
	med_param = DataFrame(CSV.File(med_pth))
	large_param = DataFrame(CSV.File(large_pth))
end;

# ╔═╡ f56f17fd-6d9b-4b7a-a4d0-724c2efbbecc
function predict_concentration(x, y, p)
	A = p[1] + (p[2] * x) + (p[3] * y) + (p[4] * x^2) + (p[5] * x * y) + (p[6] * y^2)
	B = 1 + (p[7] * x) + (p[8] * y)
	F = A / B
end;

# ╔═╡ 1d878c11-fca2-49e4-bd12-e645cc8bcb70
md"""
## Mass Scoring
"""

# ╔═╡ e187ea3e-1df5-4e1b-afb6-fc374103fbd9
md"""
### known mass
"""

# ╔═╡ 5727d686-72cc-4f33-9ef8-e43cc6ef06b6
begin
	known_density = [797,101,37,403,48,32,199,41,27]/1000
	known_mass_L = pixel_size[3]*2.5^2*π*known_density
	known_mass_M = pixel_size[3]*1.5^2*π*known_density
	known_mass_S = pixel_size[3]*0.5^2*π*known_density
end;

# ╔═╡ 70ecff76-4520-414e-9766-b33576909045
md"""
### Number of Voxels
"""

# ╔═╡ 3bd9e9bb-a42e-4059-a2cf-feacf8c29d0e
begin
	root = string("/Users/xings/Google Drive/Research/dual energy/dilate_segmentation/", SIZE, "/") 
	CSV.write(string(root, "mask_L_HD.csv"),  Tables.table(mask_L_HD), writeheader=false)
 	CSV.write(string(root, "mask_M_HD.csv"),  Tables.table(mask_M_HD), writeheader=false)
 	CSV.write(string(root, "mask_S_HD.csv"),  Tables.table(mask_S_HD), writeheader=false)
 	CSV.write(string(root, "mask_L_MD.csv"),  Tables.table(mask_L_MD), writeheader=false)
 	CSV.write(string(root, "mask_M_MD.csv"),  Tables.table(mask_M_MD), writeheader=false)
 	CSV.write(string(root, "mask_S_MD.csv"),  Tables.table(mask_S_MD), writeheader=false)
 	CSV.write(string(root, "mask_L_LD.csv"),  Tables.table(mask_L_LD), writeheader=false)
 	CSV.write(string(root, "mask_M_LD.csv"),  Tables.table(mask_M_LD), writeheader=false)
 	CSV.write(string(root, "mask_S_LD.csv"),  Tables.table(mask_S_LD), writeheader=false)
end

# ╔═╡ b8773df7-c386-45d4-a737-1409f8ab8514
md"""
### Total Volume
"""

# ╔═╡ 9a871410-c0c6-47ad-9bc0-bed9d2f7e454
md"""
### Intensity Measurement
"""

# ╔═╡ 624bb83b-cbbb-4455-8678-302e68c54e03
begin
		intensityS135 = Vector{Float64}()
		intensityS80 = Vector{Float64}()
		intensityM135 = Vector{Float64}()
		intensityM80 = Vector{Float64}()
		intensityL135 = Vector{Float64}()
		intensityL80 = Vector{Float64}()
		voxel_L = Vector{Int64}()
		voxel_M = Vector{Int64}()
		voxel_S = Vector{Int64}()
end;

# ╔═╡ 86223ca8-5b3c-4594-9a11-0001e24b6b72
begin
	dilate_mask_S_HD = dilate(dilate(mask_S_HD))
	dilate_mask_M_HD = dilate(dilate(mask_M_HD))
	dilate_mask_L_HD = dilate(dilate(mask_L_HD))
	dilate_mask_S_MD = dilate(dilate(mask_S_MD))
	dilate_mask_M_MD = dilate(dilate(mask_M_MD))
	dilate_mask_L_MD = dilate(dilate(mask_L_MD))
	dilate_mask_S_LD = dilate(dilate(mask_S_LD))
	dilate_mask_M_LD = dilate(dilate(mask_M_LD))
	dilate_mask_L_LD = dilate(dilate(mask_L_LD))

	
	push!(voxel_S,count(dilate_mask_S_HD))
	push!(voxel_M,count(dilate_mask_M_HD))
	push!(voxel_L,count(dilate_mask_L_HD))
	push!(voxel_S,count(dilate_mask_S_MD))
	push!(voxel_M,count(dilate_mask_M_MD))
	push!(voxel_L,count(dilate_mask_L_MD))
	push!(voxel_S,count(dilate_mask_S_LD))
	push!(voxel_M,count(dilate_mask_M_LD))
	push!(voxel_L,count(dilate_mask_L_LD))
end;

# ╔═╡ 734ab63d-ea4e-4b8d-ac31-c4ab79a32b68
begin
	vol_S = repeat(voxel_S*pixel_size[1]*pixel_size[2]*pixel_size[3],3)
	vol_M = repeat(voxel_M*pixel_size[1]*pixel_size[2]*pixel_size[3],3)
	vol_L = repeat(voxel_L*pixel_size[1]*pixel_size[2]*pixel_size[3],3)
end;

# ╔═╡ 9c71642a-87da-4198-a9d0-2e0ecdda82d7
begin
	KVs = [80,135]
	for ENERGY in KVs
		pth = string("/Users/xings/Google Drive/Research/dual energy/validation_originalsize_dcms/",SIZE,"1/", ENERGY,"/")
		_, dcm_array, _ = dcm_reader(pth)
		for i in 1:size(dcm_array,3)
			d = dcm_array[:,:,i]
			if ENERGY == 80
				push!(intensityS80,mean(d[dilate_mask_S_HD]))
				push!(intensityM80,mean(d[dilate_mask_M_HD]))
				push!(intensityL80,mean(d[dilate_mask_L_HD]))
					
				push!(intensityS80,mean(d[dilate_mask_S_MD]))
				push!(intensityM80,mean(d[dilate_mask_M_MD]))
				push!(intensityL80,mean(d[dilate_mask_L_MD]))
					
				push!(intensityS80,mean(d[dilate_mask_S_LD]))
				push!(intensityM80,mean(d[dilate_mask_M_LD]))
				push!(intensityL80,mean(d[dilate_mask_L_LD]))
			else
				push!(intensityS135,mean(d[dilate_mask_S_HD]))
				push!(intensityM135,mean(d[dilate_mask_M_HD]))
				push!(intensityL135,mean(d[dilate_mask_L_HD]))
					
				push!(intensityS135,mean(d[dilate_mask_S_MD]))
				push!(intensityM135,mean(d[dilate_mask_M_MD]))
				push!(intensityL135,mean(d[dilate_mask_L_MD]))
					
				push!(intensityS135,mean(d[dilate_mask_S_LD]))
				push!(intensityM135,mean(d[dilate_mask_M_LD]))
				push!(intensityL135,mean(d[dilate_mask_L_LD]))
			end
		end
	end
end

# ╔═╡ 58faf78d-9bcf-4985-8254-26b280d9a2f8
df1 = DataFrame(:known_density=>known_density*1000,:intensityS80=>intensityS80,:intensityS135=>intensityS135,
		:intensityM80=>intensityM80,:intensityM135=>intensityM135,
:intensityL80=>intensityL80,:intensityL135=>intensityL135,)


# ╔═╡ a652cc4e-5e5e-4310-bdfc-1eca9a345ad5
begin
	pred_ρ_S = Vector{Float64}()
	pred_ρ_M = Vector{Float64}()
	pred_ρ_L = Vector{Float64}()

	for i in 1:size(intensityS135,1)
		ρ_S = predict_concentration(intensityS80[i],intensityS135[i],med_param[!,1])
		ρ_M = predict_concentration(intensityM80[i],intensityM135[i],med_param[!,1])
		ρ_L = predict_concentration(intensityL80[i],intensityL135[i],med_param[!,1])

		push!(pred_ρ_S,ρ_S)
		push!(pred_ρ_M, ρ_M)
		push!(pred_ρ_L,ρ_L)
	end
end

# ╔═╡ aff1f647-11f4-4c6e-9916-6e33ee5297b3
md"""
### Predicted Mass
"""

# ╔═╡ 13ee93f0-3449-44ea-89d2-02547b60683b
begin
	pred_mass_S = Vector{Float64}()
	pred_mass_M = Vector{Float64}()
	pred_mass_L = Vector{Float64}()
	for i in 1:size(pred_ρ_S,1)
		push!(pred_mass_S,pred_ρ_S[i]*vol_S[i]*1e-03)
		push!(pred_mass_M,pred_ρ_M[i]*vol_M[i]*1e-03)
		push!(pred_mass_L,pred_ρ_L[i]*vol_L[i]*1e-03)
	end
end

# ╔═╡ e5ac81ae-f25b-424e-80db-4c10572641bb
pred_mass_L

# ╔═╡ af3d223b-9f1a-462b-a381-1e0485834253
df = DataFrame(:known_density=>known_density*1000,:known_mass_S=>known_mass_S,:predicted_mass_S=>pred_mass_S,
		:known_mass_M=>known_mass_M,:predicted_mass_M=>pred_mass_M,
		:known_mass_L=>known_mass_L,:predicted_mass_L=>pred_mass_L)


# ╔═╡ e96fbbe7-83fd-4999-9f01-08b2d05e6db0
begin
	fig = Figure()
	ax = Axis(fig[1,1])

	scatter!(df[!,:known_mass_S],df[!,:predicted_mass_S],label = "small insert")
	scatter!(df[!,:known_mass_M],df[!,:predicted_mass_M],label = "medium insert")
	scatter!(df[!,:known_mass_L],df[!,:predicted_mass_L],label = "large insert")
	lines!(0:50,0:50,color=:red,label = "unity")

	ax.title = "Measurement vs Truth (using standard HA density)"
	ax.xlabel = "Ground Truth Mass (mg)"
	ax.ylabel = "Predicted Mass (mg)"


	fig[1, 2] = Legend(fig, ax, framevisible = false)
	
	fig
end

# ╔═╡ 2bb61507-fdf1-4eed-a292-1ef21f2200f1
begin
	fig1 = Figure()
	ax1 = Axis(fig1[1,1])

	scatter!(df[!,:known_mass_S],df[!,:predicted_mass_S],label = "small insert")
	lines!(df[!,:known_mass_S],df[!,:known_mass_S],color=:red,label = "unity")

	ax1.title = "Measurement vs Truth (small insert)"
	ax1.xlabel = "Ground Truth Mass (mg)"
	ax1.ylabel = "Predicted Mass (mg)"


	fig1[1, 2] = Legend(fig1, ax1, framevisible = false)
	
	fig1
end

# ╔═╡ b5f532e9-03fd-482d-91ee-1ccc3f110d24
begin
	fig2 = Figure()
	ax2 = Axis(fig2[1,1])

	scatter!(df[!,:known_mass_M],df[!,:predicted_mass_M],label = "medium insert")
	lines!(df[!,:known_mass_M],df[!,:known_mass_M],color=:red,label = "unity")

	ax2.title = "Measurement vs Truth (medium insert)"
	ax2.xlabel = "Ground Truth Mass (mg)"
	ax2.ylabel = "Predicted Mass (mg)"


	fig2[1, 2] = Legend(fig2, ax2, framevisible = false)
	
	fig2
end

# ╔═╡ 0774f0e8-a1db-45c7-9287-5f3a7b6f5b70
begin
	fig3 = Figure()
	ax3 = Axis(fig3[1,1])

	scatter!(df[!,:known_mass_L],df[!,:predicted_mass_L],label = "large insert")
	lines!(df[!,:known_mass_L],df[!,:known_mass_L],color=:red,label = "unity")

	ax3.title = "Measurement vs Truth (large insert)"
	ax3.xlabel = "Ground Truth Mass (mg)"
	ax3.ylabel = "Predicted Mass (mg)"


	fig3[1, 2] = Legend(fig3, ax3, framevisible = false)
	
	fig3
end

# ╔═╡ 2e7c6c61-dffc-4d40-8f27-4e2343aeff8d
begin
	RMSE_L = 0
	RMSE_M = 0
	RMSE_S = 0
	RMSE = 0
	for i in 1:size(known_mass_M,1)
		RMSE_L = RMSE_L+(known_mass_L[i]-pred_mass_L[i])^2
		RMSE_M = RMSE_M+(known_mass_M[i]-pred_mass_M[i])^2
		RMSE_S = RMSE_S+(known_mass_S[i]-pred_mass_S[i])^2
	end
	RMSE = sqrt((RMSE_L+RMSE_M+RMSE_S)/(size(known_mass_L,1)*3))
	RMSE_L = sqrt(RMSE_L/size(known_mass_L,1))
	RMSE_M = sqrt(RMSE_M/size(known_mass_M,1))
	RMSE_S = sqrt(RMSE_S/size(known_mass_S,1))
	
end

# ╔═╡ bbf36a3e-9f72-4a71-97a3-5a1f58a831af
RMSE

# ╔═╡ Cell order:
# ╠═db978680-24b3-11ed-338e-d18072c03678
# ╠═7f5a24e6-e9b0-4a72-a9fa-98ab01a20125
# ╟─818de283-2626-4afd-9465-ee065dfaff8d
# ╟─562b6c00-5470-4437-9e50-a75bf1ddd030
# ╟─cf5b409e-2f02-4dec-afe4-3cf26dab0cd8
# ╟─0358fdb5-f07e-4925-8fbf-8f7928565034
# ╠═013acd6e-0465-46c9-83b1-97613ebdee53
# ╠═4526ec32-2491-41be-91c4-03f545f9733c
# ╠═fb440caa-f753-4b86-b6f2-fed47e31e94d
# ╠═ff366ede-a201-48da-9f59-638c9907ed72
# ╠═af62f7d2-8b32-40de-a789-99b112be3852
# ╠═25f36ebb-0b26-4f27-b42a-3ee08afb9496
# ╠═bef52d62-75f0-450e-83df-9f635dad2f5b
# ╠═0f0bbe0d-a20f-4380-8e7e-cafd4e38cfe3
# ╠═38fe9e90-f756-4972-bafb-491a65413542
# ╟─4807a059-3711-4839-96c6-a3f1ce8b3c7c
# ╠═c268d8f1-706f-43d8-9d3d-dc4072666451
# ╠═f56f17fd-6d9b-4b7a-a4d0-724c2efbbecc
# ╟─1d878c11-fca2-49e4-bd12-e645cc8bcb70
# ╟─e187ea3e-1df5-4e1b-afb6-fc374103fbd9
# ╠═5727d686-72cc-4f33-9ef8-e43cc6ef06b6
# ╟─70ecff76-4520-414e-9766-b33576909045
# ╠═86223ca8-5b3c-4594-9a11-0001e24b6b72
# ╠═3bd9e9bb-a42e-4059-a2cf-feacf8c29d0e
# ╟─b8773df7-c386-45d4-a737-1409f8ab8514
# ╠═734ab63d-ea4e-4b8d-ac31-c4ab79a32b68
# ╟─9a871410-c0c6-47ad-9bc0-bed9d2f7e454
# ╠═624bb83b-cbbb-4455-8678-302e68c54e03
# ╠═9c71642a-87da-4198-a9d0-2e0ecdda82d7
# ╠═58faf78d-9bcf-4985-8254-26b280d9a2f8
# ╠═a652cc4e-5e5e-4310-bdfc-1eca9a345ad5
# ╟─aff1f647-11f4-4c6e-9916-6e33ee5297b3
# ╠═13ee93f0-3449-44ea-89d2-02547b60683b
# ╠═e5ac81ae-f25b-424e-80db-4c10572641bb
# ╠═af3d223b-9f1a-462b-a381-1e0485834253
# ╠═e96fbbe7-83fd-4999-9f01-08b2d05e6db0
# ╠═2bb61507-fdf1-4eed-a292-1ef21f2200f1
# ╠═b5f532e9-03fd-482d-91ee-1ccc3f110d24
# ╠═0774f0e8-a1db-45c7-9287-5f3a7b6f5b70
# ╠═2e7c6c61-dffc-4d40-8f27-4e2343aeff8d
# ╠═bbf36a3e-9f72-4a71-97a3-5a1f58a831af
