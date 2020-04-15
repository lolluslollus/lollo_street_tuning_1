function data()
	return {
		en = {
			["_DESC"] = "[b]This is a collection of tools to fine-tune the road vehicle routing.[/b]\n\n"

			.."[h2]The trouble: vehicles queue up[/h2]\n"
			.."When you build a long enough piece of road, the game splits it into seamless chunks. The joints between these chunks allow vehicles to change lanes. The trouble is, these chunks are fairly long, and crossings do not allow switching lanes. As a result, vehicles will queue up more than required.\n"

			.."[h2]Solution part 1: add lane switchers[/h2]\n"
			.."You can create an extra lane switcher by adding an intersecting street and deleting it, but this often involves destroying several buildings."
			.."To keep the carnage down, this mod adds a very thin street slicer into the street construction menu. Place it on the roadside and rotate it with <m>, <shift> + <m>, <n> or <shift> + <n>, carefully adjusting its location. If you are careful and lucky, no buildings will need destroying. The slicer will destroy itself after placement, leaving your new lane switcher in place.\n"

			.."[h2]Solution part 2: add lanes[/h2]\n"
			.."Once you have a few lane switchers, you can change the road segments between them. This mod adds a selection of streets with multiple lanes, to allow overtaking, but with the same width, so you can try different road types without destroying your buildings."
			.."The game does not offer lane-bound waypoints, so routing the vehicles can involve a fair amount of trial and error.\n"

			.."[h2]The easiest way to have lorries overtake stopping trams, or viceversa[/h2]\n"
			.."- Add two lane switchers before and after your roadside stop, with no crossings in between.\n"
			.."- Replace the road between them with one of the same width, but an extra lane and maybe extra tram lanes.\n"

			.."[h2] This mod also contains a very thin footpath[/h2]\n"
			.."You can use it to perform various tricks. Give it a bus lane to pedestrianise it.\n"

			.."[h2]Some handy tips:[/h2]\n"
			.."- To better visualise the lanes, start the game in debug mode and press <AltGr> + <L>.\n"
			.."- Press and hold <shift> to place a short road segment between two joints.\n"
			.."- Select street - upgrade and right-click a one-way road to reverse its direction.\n"
			.."\n"
			.."[b]This mod may break your game if you use it and then remove it.[/b]\n"
			.."[b]Thanks to Enzojz for luadump![/b]",
			["_NAME"] = "Street fine tuning"
		},
	}
end
