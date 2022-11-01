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

# ╔═╡ 71621e0e-0b10-4398-95c1-c73cab737e5b
# ╠═╡ show_logs = false
begin
	using Pkg
	Pkg.activate(".")

    using PlutoUI
    using CairoMakie
    using MAT
    using DICOM
    using DICOMUtils
end

# ╔═╡ 3982c500-52e3-4dad-ac99-e6423ecc3282
TableOfContents()

# ╔═╡ ee37a9bf-545e-4c68-b22d-0c3fce8df0ba
energies = [80, 135]

# ╔═╡ 03049b0b-9ac2-4d0e-b105-e36055cc6f42
densities = ["Density1", "Density2", "Density3"]

# ╔═╡ 753bf413-2094-4642-8c13-26d70c8f99f8
sizes_folders = ["Small", "Medium", "Large", "Small1", "Medium1", "Large1"]

# ╔═╡ 98f46c6e-da8c-4b1d-817e-b3285452f210
sizes = ["small", "medium", "large"]

# ╔═╡ 13912914-7ab7-479b-a959-03576a9b117e
file_nums = [1, 2, 3]

# ╔═╡ 6e8c4d1a-08ad-4cf7-976c-e4b718951b53
begin
	for size_folder in sizes_folders
		for density in densities
    		for energy in energies
        		for _size in sizes
					for file_num in file_nums

						local energy_folder_file_name
						if (size_folder == "Small1" || size_folder == "Medium1" || size_folder == "Large1")
							energy_folder_file_name = chop(lowercase(string(size_folder)))
							# @info energy_folder_file_name
						elseif (size_folder == "Small" || size_folder == "Medium" || size_folder == "Large")
							energy_folder_file_name = lowercase(string(size_folder))
						end
						
		                ## Path to the original dataset of .mat files
						path = string("/Users/daleblack/Google Drive/dev/MolloiLab/dual-energy-cac/mat_measurement/", size_folder, "/", density, "energy", energy, energy_folder_file_name, ".mat")
						vars1 = matread(path)
						array1 = vars1[string("I")]
						array1 = Int16.(round.(array1))
						
						## Path to known DICOM file
						dcm_path = "/Users/daleblack/Google Drive/Datasets/Canon_Aquilion_One_Vision/Large_rep1/96E1EB4F"
						
						dcm = dcm_parse(dcm_path)
						dcm[tag"Pixel Data"] = array1
						dcm[tag"Instance Number"] = file_num
						dcm[tag"Rows"] = size(array1, 1)
						dcm[tag"Columns"] = size(array1, 2)
		
		                ## Path to output the newly creted DICOM files
						output_root = joinpath("/Users/daleblack/Google Drive/dev/MolloiLab/dual-energy-cac/dcms_measurement_new", size_folder, density, string(energy))
						if !isdir(output_root)
							mkpath(output_root)
						end
						global output_path
						output_path = joinpath(output_root, string(file_num) * ".dcm")
						dcm_write(output_path, dcm)
					end
				end
			end
        end
    end
end

# ╔═╡ 40095bc7-a7a5-4455-9198-52a383e5434e
md"""
## Check DICOM image(s)
"""

# ╔═╡ 36946509-a59e-4218-b501-cb9fc401fcc9
dcmdir_combined = dcmdir_parse(dirname(output_path));

# ╔═╡ 05a9b1a9-26c7-4472-9f3a-44e131cc84d1
vol_combined = load_dcm_array(dcmdir_combined);

# ╔═╡ c442c24c-2ab7-4dab-9bc1-95ec68d69996
@bind c PlutoUI.Slider(1:size(vol_combined, 3); default=1, show_value=true)

# ╔═╡ f1a6dd2e-e9d2-4bda-aee6-0219b25a4098
heatmap(transpose(vol_combined[:, :, c]); colormap=:grays)

# ╔═╡ Cell order:
# ╠═71621e0e-0b10-4398-95c1-c73cab737e5b
# ╠═3982c500-52e3-4dad-ac99-e6423ecc3282
# ╠═ee37a9bf-545e-4c68-b22d-0c3fce8df0ba
# ╠═03049b0b-9ac2-4d0e-b105-e36055cc6f42
# ╠═753bf413-2094-4642-8c13-26d70c8f99f8
# ╠═98f46c6e-da8c-4b1d-817e-b3285452f210
# ╠═13912914-7ab7-479b-a959-03576a9b117e
# ╠═6e8c4d1a-08ad-4cf7-976c-e4b718951b53
# ╟─40095bc7-a7a5-4455-9198-52a383e5434e
# ╠═36946509-a59e-4218-b501-cb9fc401fcc9
# ╠═05a9b1a9-26c7-4472-9f3a-44e131cc84d1
# ╠═c442c24c-2ab7-4dab-9bc1-95ec68d69996
# ╠═f1a6dd2e-e9d2-4bda-aee6-0219b25a4098
