program makehighwayclass

gen highwayclass = .
replace highwayclass = 1 if highway == "motorway"
replace highwayclass = 1 if highway == "motorway_link"
replace highwayclass = 1 if highway == "trunk"
replace highwayclass = 1 if highway == "trunk_link"

replace highwayclass = 2 if highway == "primary"
replace highwayclass = 2 if highway == "primary_link"
replace highwayclass = 2 if highway == "secondary"
replace highwayclass = 2 if highway == "secondary_link"

replace highwayclass = 3 if highway == "tertiary"
replace highwayclass = 3 if highway == "tertiary_link"
replace highwayclass = 3 if highway == "residential"
replace highwayclass = 3 if highway == "unclassified"
replace highwayclass = 3 if highway == "road"
replace highwayclass = 3 if highway == "service"

replace highwayclass = 4 if highway == "footway"
replace highwayclass = 4 if highway == "track"
replace highwayclass = 4 if highway == "path"
replace highwayclass = 4 if highway == "cycleway"
replace highwayclass = 4 if highway == "pedestrian"
replace highwayclass = 4 if highway == "steps"

end
