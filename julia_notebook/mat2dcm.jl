### A Pluto.jl notebook ###
# v0.19.12

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

# ╔═╡ c25c8d78-8fbb-4714-bd64-1d907e699d13
# ╠═╡ show_logs = false
begin
    let
        using Pkg
        Pkg.activate(mktempdir())
        Pkg.Registry.update()
        Pkg.add("PlutoUI")
        Pkg.add("CairoMakie")
        Pkg.add("MAT")
        Pkg.add(; url="https://github.com/JuliaHealth/DICOM.jl")
        Pkg.add(; url="https://github.com/Dale-Black/DICOMUtils.jl")
    end

    using PlutoUI
    using CairoMakie
    using MAT
    using DICOM
    using DICOMUtils
end

# ╔═╡ 8c78db8b-5dc8-403a-841e-e1f3faf1549d
TableOfContents()

# ╔═╡ 9a5a408f-d6d8-445e-b6e8-7e3eb4636ab4
densities = [
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

# ╔═╡ 8d3e474e-ce26-4a68-bc6b-046c221952c9
energies = [80, 135]

# ╔═╡ 84031932-d692-4102-bb1f-970780e2aa1c
sizes = ["small", "medium", "large"]

# ╔═╡ 455e943d-a824-44e9-8453-164f853b8845
begin
    for energy in energies
        for _size in sizes
            for density in densities

                ## Path to the original dataset of .mat files
                path = string(
                    "/Users/daleblack/Google Drive/dev/MolloiLab/dual-energy-cac/imgs_calibration/",
					_size,
					"/",
                    density,
                    "rod",
                    energy,
                    ".mat"
                )
                vars1 = matread(path)
                array1 = vars1[string("I")]
                array1 = Int16.(round.(array1))

                ## Path to a known DICOM files
                dcm_path = "/Users/daleblack/Google Drive/Datasets/Canon_Aquilion_One_Vision/Large_rep1/96E1EB4F"

                dcm = dcm_parse(dcm_path)
                dcm[tag"Pixel Data"] = array1
                dcm[tag"Instance Number"] = density
                dcm[tag"Rows"] = size(array1, 1)
                dcm[tag"Columns"] = size(array1, 2)

                ## Path to output the newly creted DICOM files
				output_root1 = string(dirname(dirname(dirname(path))), "/dcms_calibration/", _size)
				
                if !isdir(output_root1)
                    mkdir(output_root1)
                end
                output_root2 = string(
                    output_root1,
                    "/",
                    energy,
                )
                if !isdir(output_root2)
                    mkdir(output_root2)
                end

				global output_path
                output_path = string(output_root2, "/", density, ".dcm")
                dcm_write(output_path, dcm)
            end
        end
    end
end

# ╔═╡ 7efbcb1c-09dc-45d2-979e-86c005edd387
md"""
## Check DICOM image(s)
"""

# ╔═╡ fc683127-d9fd-4f36-8c22-ba334fa2bc63
dcmdir_combined = dcmdir_parse(dirname(output_path));

# ╔═╡ d75c3cdf-200e-491c-bb65-ece16cf16ca0
vol_combined = load_dcm_array(dcmdir_combined);

# ╔═╡ fb34c978-bd0c-4b20-9c19-c25603fa8dc9
@bind c PlutoUI.Slider(1:size(vol_combined, 3); default=1, show_value=true)

# ╔═╡ a122aeef-9289-4bc7-908b-64a7734dcae8
heatmap(transpose(vol_combined[:, :, c]); colormap=:grays)

# ╔═╡ Cell order:
# ╠═c25c8d78-8fbb-4714-bd64-1d907e699d13
# ╠═8c78db8b-5dc8-403a-841e-e1f3faf1549d
# ╠═9a5a408f-d6d8-445e-b6e8-7e3eb4636ab4
# ╠═8d3e474e-ce26-4a68-bc6b-046c221952c9
# ╠═84031932-d692-4102-bb1f-970780e2aa1c
# ╠═455e943d-a824-44e9-8453-164f853b8845
# ╟─7efbcb1c-09dc-45d2-979e-86c005edd387
# ╠═fc683127-d9fd-4f36-8c22-ba334fa2bc63
# ╠═d75c3cdf-200e-491c-bb65-ece16cf16ca0
# ╟─fb34c978-bd0c-4b20-9c19-c25603fa8dc9
# ╠═a122aeef-9289-4bc7-908b-64a7734dcae8
