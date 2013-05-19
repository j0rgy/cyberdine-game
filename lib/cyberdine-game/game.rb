class Game

	# ToDo
	# [] Add code that automatically creates attr_reader for all local variables of Game

	attr_reader :apartment, :alley, :city_square, :cafe, :stock_exchange,
    :cyberdine_lobby, :manager_office, :cafe_corner, :melanie_office,
    :cypher, :melanie, :vendor, :stock_guard, :receptionist, :executive,
    :cyberdine_elevator, :cyberdine_elevator_62, :elevator_first

	def initialize

		# Create rooms
		# -----------------------------------------------
		# 1. Description
		# 2. Items
		# 3. Exits (clockwise) - north, east, south, west  => exit description, room
		# 4. Npcs
		# 5. Heroes
		# 6. Events
		# -----------------------------------------------

		@apartment = Room.new(
			"Your apartment. It smells like smoke. There's a large flat screen on the wall and an unmade bed in one corner. The only other piece of furniture is a solid oak coffee table.",
			['Guns & Ammo magazine', 'pack of cigarettes', 'switchblade'],
			{ "w" => { "desc" => "door", "room" => :@alley } },
			[],
			[],
			[:cell_message])

		@alley = Room.new(
			"A dark alley. There's gang graffiti on the brick walls. Trash is piled everywhere. Not a place you want to run into someone.",
			['latex glove', 'lottery ticket', 'dead rat'],
			{ "e" => { "desc" => "door", "room" => :@apartment }, 
			  "w" => { "desc" => "busy city square" , "room" => :@city_square }
			} )

		@city_square = Room.new(
			"The bustling center of the city. People are walking about everywhere. Bright video advertisements play from screens suspended in the sky, one after the other. Street vendors line the sidewalk.",
			['newspaper', 'empty coke can', 'ATM receipt'],
			{ "n" => { "desc" => "financial district", "room" => :@financial_district },
			  "e" => { "desc" => "side alley", "room" => :@alley },
			  "w" => { "desc" => "cafe", "room" => :@cafe }
			} )

		@cafe = Room.new(
			"A busy cyber cafe. Rows of desks line the room with people hunched over staring into bright flat screens. The smell of rich coffee is almost overpowering.",
			[],
			{ "n" => { "desc" => "dark corner", "room" => :@cafe_corner },
			  "e" => { "desc" => "busy city square", "room" => :@city_square }
			} )

		@cafe_corner = Room.new(
			"A dark corner of the cafe, away from the prying eyes of customers and employees.",
			['laptop', 'old computer cable'],
			{ "s" => { "desc" => "cafe", "room" => :@cafe } } )

		@financial_district = Room.new(
			"The financial district. Gleaming skyscrapers rise up all around you. Businessmen and women are marching around with expressions of serious purpose. The streets smell like money.",
			['expired sell ticket', 'crumpled resume'],
			{ "n" => { "desc" => "large stock exchange building", "room" => :@stock_exchange },
			  "s" => { "desc" => "busy city square", "room" => :@city_square },
			  "w" => { "desc" => "tall skyscraper", "room" => :@cyberdine_lobby }
			} )

		@stock_exchange = Room.new(
			# Desc
			"The stock exchange. A massive, courthouse-like building framed by two large crumbling marble columns. The building was destroyed two years ago by rioters during the crash of 2018, and although currently operational it's still being slowly re-built.",
			# Items
			[],
			# Exits
			{ "s" => { "desc" => "financial district", "room" => :@financial_district } },
			# Npcs
			[], 
			# Heroes
			[],
			# Events
			[:stock_security])

		@cyberdine_lobby = Room.new(
			"The granite-floored lobby of a towering office high-rise. The metallic logo behind the receptionist reads \"Cyberdine Headquarters.\"",
			['lamp','leather couch','gold trash can'],
			{ "n" => { "desc" => "elevator", "room" => :@cyberdine_elevator },
			  "e" => { "desc" => "financial district", "room" => :@financial_district }
			} )

		@cyberdine_elevator = Room.new(
			"A luxurious, modern elevator. The back wall is one large mirror.",
			# Items
			[],
			# Exits
			{ "s" => { "desc" => "lobby", "room" => :@cyberdine_lobby } },
			# Npcs
			[], 
			# Heroes
			[],
			# Events
			[:elevator_first])

		@cyberdine_elevator_62 = Room.new(
			"A luxurious, modern elevator. The back wall is one large mirror.",
			# Items
			[],
			# Exits
			{ "e" => { "desc" => "office hallway", "room" => :@office_hallway } },
			[],
			[],
			[:elevator_first])

		@office_hallway = Room.new(
			"A nicely carpeted hallway leading to two doors separated by a large floor-to-ceiling window. You can see the whole city from up here.",
			[],
			{ "n" => { "desc" => "office door", "room" => :@manager_office },
			  "s" => { "desc" => "office door", "room" => :@melanie_office },
			  "w" => { "desc" => "elevator", "room" => :@cyberdine_elevator_62 }
			} )

		@manager_office = Room.new(
			"An executive office suite. A large oak desk in the center of the office. Old leather books, college credentials and corporate placques line the walls.",
			[],
			{ "s" => { "desc" => 'office hallway', "room" => :@office_hallway } },
			[],
			[],
			[:manager_security])


		@melanie_office = Room.new(
			"A younger person's office. Artistic grafitti murals cover the walls. There are bean bag chairs and a low, modern desk.",
			[],
			{ "n" => { "desc" => 'office hallway', "room" => :@office_hallway } } )

		# Create NPCs

		@vendor = Npc.new(@city_square,"street vendor",["hotdog"]) # Do I need the 'location' here? I guess I should keep it in case I want to make them move around.
		@city_square.npcs << @vendor # Put the vendor in the city square, after we define both

		@stock_guard = Npc.new(@stock_exchange,"heavily armed guard")
		@stock_exchange.npcs << @stock_guard

		@receptionist = Npc.new(@cyberdine_lobby,"receptionist")
		@cyberdine_lobby.npcs << @receptionist

		@executive = Npc.new(@manager_office,"business executive")
		@manager_office.npcs << @executive

		# Create heroes
		@cypher = Hero.new(@cafe_corner,"Cypher",["thumb drive","slip of paper"],[:cypher_thumb])
		@cafe_corner.heroes << @cypher

		@melanie = Hero.new(@melanie_office,"Melanie",[],[:melanie_meeting])
		@melanie_office.heroes << @melanie		
	end
end
