function data()
	return {
		en = {
			["_DESC"] = [[
				[b]This is a collection of tools to fine-tune the road vehicle routing and the streets.[/b]

				[h1]Problem A: vehicles queue up[/h1]
				When you build a long enough piece of road, the game splits it into seamless chunks. The joints between these chunks allow vehicles to change lanes. The trouble is, these chunks are fairly long, and crossings do not allow switching lanes. As a result, vehicles will queue up more than required.
				[h2]Solution part 1: add lane switchers[/h2]
				You can create an extra lane switcher by adding an intersecting street and deleting it, but this often involves destroying several buildings.To keep the carnage down, this mod adds a very thin street slicer into the street construction menu. Place it on the roadside and rotate it with <m>, <shift> + <m>, <n> or <shift> + <n>, carefully adjusting its location. If you are careful, no buildings will need destroying, or just one. The slicer will destroy itself after placement, leaving your new lane switcher in place. AltGr + L will reveal it.
				[h2]Solution part 2: add lanes[/h2]
				Once you have a few lane switchers, you can change the road segments between them. This mod adds a selection of streets with multiple lanes, to allow overtaking, but with the same width, so you can try different road types without destroying your buildings.The game does not offer lane-bound waypoints, so routing the vehicles can involve a fair amount of trial and error.
				[h2]The easiest way to have lorries overtake stopping trams, or viceversa[/h2]
				- Add two lane switchers before and after your roadside stop, with no crossings in between.
				- Replace the road between them with one of the same width, but an extra lane and maybe extra tram lanes.
				[h1]Problem B: little control building roads[/h1]
				This mod adds a "street construction" to build chunks of road with useful parameters. These chunks can be single or multiple, arranged in parallel.
				[h1]Problem C: ugly merges[/h1]
				This mod adds a "street construction" to build prettier merges. For example, you can merge up to four one-lane streets into a large one, perhaps for a fancy station square arrangement.
				Merges can be reconfigured after being placed, if the street layout allows it. If a merge misbehaves after an upgrade, change its direction twice (ie reverse and restore) to update it to the latest version.
				[h1]Problem D: ugly tight curves[/h1]
				This mod adds a "street construction" to build prettier tight curves.
				[h1]Problem E: no footpaths[/h1]
				This mod contains some thin footpaths. You can use them to perform various tricks, eg connecting stations to roads or having people walk across a park. Give them a bus lane to pedestrianise them.
				[h1]Some handy tips:[/h1]
				- To better visualise the lanes, start the game in debug mode and press <AltGr> + <L>.
				- Press and hold <shift> to place a short road segment between two joints.
				- Select street - upgrade and right-click a one-way road to reverse its direction.
				
				[b]This mod may break your game if you use it and then remove it.[/b]
				[b]Thanks to Enzojz for luadump![/b][h2]Word of warning[/h2]
				The game won't allow changing or removing a piece of road, whose parameters have changed in a mod update.
				This affects the "Medium 1-way street with 1 lane and extra narrow pavement" and the "Medium 1-way street with 1 lane".
				To fix this:
				- locate the mod in your folder "C:\Program Files (x86)\Steam\steamapps\workshop\content\1066780"
				- locate the file "lollo_medium_1_way_1_lane_street.lua"
				- set [code]streetWidth = 3.0, 
				 sidewalkWidth = 2.5,[/code]
				- locate the file "lollo_medium_1_way_1_lane_street_narrow_sidewalk.lua"
				- set [code]streetWidth = 3.0, 
				 sidewalkWidth = 0.5,[/code]
				- start the game
				- remove all the instances of these roads
				- save the game
				- restore the files to their previous state (ie from the latest update)
				- reload the game and rebuild the roads you destroyed
				Chances are, the new street merger will help you make them nicer anyway.
			]],
			["_NAME"] = "Street fine tuning"
		},
	}
end
