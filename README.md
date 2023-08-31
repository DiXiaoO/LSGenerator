## LSGenerator
ini file generator for loading screen mods
# Usage
Edit LSConfig.txt as follows:
	image_name_and_its_extension image_resizing fill_type fill_color(R) fill_color(G) fill_color(B) fill_color(A)
	Example 1.dds 0 1 1 0.5 0.5 1

image_name_and_its_extension has two spellings
1. single image: 1.dds
2. Image and its background image: 1_1.dds|1_2.dds
in the second case, both images are separated by |

image_resizing:
0 - auto
1 - y-axis
2 - x-axis

fill_type:
0 - blur
1 - color

fill_color:
SRGBA format! Like regular RGBA only divided by 255!

After generating the ini file, place the images that you entered in LSConfig.txt in the data folder

For the resulting mod to work, you need:

LSMod.ini

draw_2d.hlsl

data/imgs...
