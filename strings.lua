function data()
	return {
		en = {
			["_DESC"] = [[
				[b]This is a collection of tools to fine-tune the road vehicle routing and the streets.[/b]

				[h1]Problem A: inflexible roads[/h1]
				This mod adds a selection of streets with multiple lanes, to allow overtaking, but with the same width, so you can try different road types without destroying your buildings. Some road types reserve the right lane for passenger or cargo vehicles; they carry extra signs on the pavement.
				Use the categories to select the right street type, for ease of use.
				[h1]Problem B: little control destroying pieces of road[/h1]
				This mod adds two slicers to the street construction menu. They split a piece of road in two segments.
				- The automatic slicer preserves all buildings, just plop it where you want.
				- The manual slicer is a backup. Place it on the roadside and rotate it with <m>, <shift> + <m>, <n> or <shift> + <n>, carefully adjusting its location.
				Both slicers destroy themselves after placement, leaving your road split in two segments. Debug mode and AltGr + L will reveal their effect.
				After splitting a piece of road, you can alter or delete a small segment only, preserving the rest.
				[h1]Problem C: trams only run in the rightmost lane[/h1]
				This mod adds a street construction to toggle extra tram tracks. Plop it on a road and it will add or remove extra tram tracks, if there are enough lanes.
				Previous iterations exposed roads with many tram tracks in the street menu, but that was ugly.
				[h1]Problem D: vehicles queue up unnecessarily[/h1]
				The game does not offer lane-bound waypoints, so routing the vehicles might involve some trial and error.
				[h2]Solution: use dedicated roads[/h2]
				Replace the offending road with one of the same width, that reserves the right lane for certain vehicles. Use the standard replace tool (the magic wand), helping yourself with <shift> to select a shorter segment of road. Use the slicer to cut your own segments if you must. Select the new road with the category icon to avoid confusion. Toggle bus lanes on or off as required, using the standard tool. Toggle tram tracks in the middle as required, using the dedicated street construction tool.
				[h2]Fine-grained solution: split your road into segments[/h2]
				When you build a long enough piece of road, the game splits it into seamless segments. The joints between them allow vehicles to change lanes. The trouble is, these segments are fairly long, and crossings do not allow switching lanes. If you have a shortish stretch of road, then a crossing, then another shortish stretch, then another crossing, chances are, vehicles cannot change lanes for a long while.
				You can split a piece of road by adding an intersecting street and deleting it, but this often involves destroying several buildings. To keep the carnage down, use the slicer. Once you have multiple segments, you can change the road in some or all of them, selectively. Try adding an extra lane to the segment with the streetside stop only.
				[h1]Problem E: little control building roads[/h1]
				This mod adds a "street construction" to build chunks of road with useful parameters. These chunks can be single or multiple, arranged in parallel. Lock them to keep their shape pretty and prevent other roads merging in. Unlock them to treat them like ordinary roads. You cannot relock an unlocked chunk.
				[h1]Problem F: ugly or impossible merges[/h1]
				This mod adds a "street construction" to build merges. For example, you can merge up to four one-lane streets into a large one, perhaps for a fancy station square arrangement.
				Merges can be reconfigured after being placed, if the street layout allows it. If a merge misbehaves after a mod update, change its direction twice (ie reverse and restore) to update it to the latest version.
				[h1]Problem G: ugly tight curves[/h1]
				This mod adds a "street construction" to build prettier tight curves. Lock a curve to keep its shape pretty and prevent other roads merging in. Unlock it to treat it like ordinary roads. You cannot relock an unlocked curve.
				[h1]Problem H: no footpaths[/h1]
				This mod adds some thin footpaths, nearly invisible. You can use them to perform various tricks, eg connecting stations to roads or having people walk across a park. Give them a bus lane to pedestrianise them.
				There is also a 1-metre footpath.
				[h1]Problem I: vehicles make funny turns[/h1]
				Sometimes, vehicles overshoot a crossing, then reverse, then turn where they are meant to.
				Use the splitter to make them change lanes where you want - ie at the split.
				[h1]Tips:[/h1]
				- To better visualise the lanes, start the game in debug mode and press <AltGr> + <L>.
				- Press and hold <shift> to replace a short road segment between two joints.
				- Select street - upgrade and right-click a one-way road to reverse its direction.
				- Use the categories in the street menu to avoid headaches.
				- The construction mover helps adjust constructions after plopping them.
				
				[b]This mod may break your game if you use it and then remove it.[/b]
				[b]Thanks to Enzojz for luadump![/b]
				[b]I would love lorry-only or tram-only lanes, but the game does not allow this for now.[/b]
				[h2]Breaking Change A[/h2]
				The game won't allow changing or removing a piece of road, whose sizes have changed in a mod update.
				This affects the "Medium 1-way street with 1 lane and extra narrow pavement" and the "Medium 1-way street with 1 lane", which I shipped before Summer 2020.
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
				[h2]Breaking Change B[/h2]
				The street merges can be on bridges as of February 2022. This involved an incompatible change. If you want to update an older merge, bulldoze it and rebuild it.
				[h2]Known problems[/h2]
				A) When you split a road near a modded street station, whose mod was removed, and then apply a modifier, such as add / remove bus lane or change the street type, the game crashes.
				This happens with single as well as double-sided stations. You can tell those stations because the game shows a placeholder at their location.
				This is a UG problem. To solve it, replace those stations with some others available in your game.
				B) The game always draws the tram track on the outer lane(s), even if trams are barred there. Take this as a graphical glitch.
				C) The game always expects buses to be allowed in the outer lane(s).
                D) Adding a bus lane to a road can break your multi-lane paths. Trial and error is the way out of this game limitation.
			]],
			["_NAME"] = "Street fine tuning",
			["snapNodesName"] = "Snap to neighbours",
			["snapNodesDesc"] = "Cycle through these values to help configure a station once it is built",
			["No"] = "No",
			["Left"] = "End A",
			["Right"] = "End B",
			["Both"] = "Both Ends",
			["BridgeType"] = "Bridge Type",
			["NoBridge"] = "No Bridge",
			["StreetType"] = "Street Type",
			["ReplaceWithNewer"] = "This construction is an old version: remove it and rebuild it to upgrade",
			["YellowBusLanes"] = "Yellow bus lanes with stripes",
			["MakeReservedLanes"] = "Make reserved lanes",
		},
	}
end
