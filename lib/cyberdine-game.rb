# Cyberdine, a short cyberpunk-esque adventure game
# Ship date: 2013-05-08 

# TODO Hacking
# => Hack workplace computers, security systems
# => Obtain a laptop

# TODO Story
# => Add a newspaper in your apartment that describes the market crash, violence etc.
# => Discover your phone is bugged? For some reason make your apartment not safe anymore, then lead player to a new safe spot (someone else's)



module Runner

	def start()
		puts "\n#{@name}, welcome to:"
		print "
		 .o88b. db    db d8888b. d88888b d8888b. d8888b. d888888b d8b   db d88888b 
		d8P  Y8 `8b  d8' 88  `8D 88'     88  `8D 88  `8D   `88'   888o  88 88'     
		8P       `8bd8'  88oooY' 88ooooo 88oobY' 88   88    88    88V8o 88 88ooooo 
		8b         88    88~~~b. 88~~~~~ 88`8b   88   88    88    88 V8o88 88~~~~~ 
		Y8b  d8    88    88   8D 88.     88 `88. 88  .8D   .88.   88  V888 88.     
		 `Y88P'    YP    Y8888P' Y88888P 88   YD Y8888D' Y888888P VP   V8P Y88888P                                             

		"
		puts "Type 'help' for help.\n\n"
		look
		game_loop
  end

	def game_loop
		print "> "
		next_move = gets.chomp
		if next_move != "exit"
			command_parser(next_move)
			game_loop
		end
	end

	COMMANDS = {
		# Directions - create move -- have it use next_move[0] has the direction
		"n" => :move , "north" => :move,  "e" => :move, "east" => :move, "s" => :move, "south" => :move, "w" => :move, "west" => :move,

		# Inventory and picking up/dropping items
	  "i" => :inventory, "drop" => :drop, "take" => :take,

		# Looking
		"look" => :look, "l" => :look,

		# Custom event commands
		"play" => :play_message, "select" => :select_floor, 

		# Inspect
		"inspect" => :inspect_item,

		# Help
		"help" => :help, "h" => :help
	}

	def command_parser(next_move)
		@next_move = next_move.split(' ')
		# If there is anything given after the first word, join all of the words after the first into a single variable
	  @next_move_args = @next_move.last(@next_move.count - 1).join(" ") if @next_move[1]

	  if COMMANDS.has_key?(@next_move[0])  # Check if next move is a key in the commands hash
	  	# puts "You're executing: #{COMMANDS[@next_move[0]]}(#{@next_move_args})"
	    send(COMMANDS[@next_move[0]], *@next_move_args) # If it is, send the command with everything following it as arguments
	    @next_move_args = [] # Empty next_move_args so they aren't carried over into future commands
	  else
	    puts "I don't know what that means."
	  end
	end

	def help()
			puts "
		To move around, type a direction. Ex: 'west' moves you wast.

		-----------------------------------------------------------------
		| Command       | Description                                   |
		-----------------------------------------------------------------
		| look          | Shows description of the room you're in       |
		| look north    | Shows description of the direction you look   |
		| north         | Move in that direction                        |
		| i             | Displays your inventory                       |
		| inspect item  | Shows description of the item you inspect     |
		| take item     | Picks up an item from the room                |
		| drop item     | Drops an item from your inventory             |
		-----------------------------------------------------------------
		"
  end

end




module Items
	
	ITEM_DESCRIPTIONS = {
		"slip of paper" => "It has \"Floor 62, 4624\" written on it.",
		"headphones" => "They look like Dre Beats." }

end


module Events

	# Event flags
	@cell_message_flag = 0
	@melanie_hint_flag = 0

	# Events
	def cypher_thumb()
		if !@inventory.include? "thumb drive"
			puts "\nCypher looks you up and down."
			@game.cypher.says("Can I help you?")
			cypher_dialogue()	
    else
     puts "Do nothing."	
		end
	end

	def cypher_dialogue()
		puts "\nChoose your response:\n1: \"Just minding my own business.\"\n2: \"What's it to you, old man?\"\n3: \"Looks like rain today, doesn't it?\""
		print "> "
		response = gets.chomp
		if response == "1"
			@game.cypher.says("Well mind it somewhere else.")
			puts "#{@cypher.name} shoves you out of the room."
			enter(@cafe)
		elsif response == "2"
			dead("Cypher stabs you in the throat and you bleed to death on the floor.")
		elsif response == "3"
			@game.cypher.says("#{@name}! I've been waiting for you!") # Why does @name work here? Shouldn't it have to be @player.name? I'm calling it from outside the 'Player' class..?? -- Update: No. I had 'enter' as a player method, so when I moved I was calling look from inside Player!
			npc_give(@game.cypher,"thumb drive")
			@game.cypher.says("Melanie needs this. She's in the financial district, Cyberdine building, floor 62. You'll need this code to get in.")
			npc_give(@game.cypher,"slip of paper")
			@game.cypher.says("Good luck, #{@name}.")
			puts "#{@game.cypher.name} slips out of the room."
			@game.cafe_corner.heroes.delete(@game.cypher)
		else
			puts "I don't know what that means."
			cypher_dialogue()
		end
	end

	def cell_message()
		if @cell_message_flag != 1
			puts "Your answering machine is blinking it has 1 message waiting. ['play']"
		end
	end

	def stock_security()
		if (@cur_room == @game.stock_exchange) and (@cur_room.npcs.include? @game.stock_guard)
			puts "\nThe heavily armed guard points a large machine gun at you."
			@game.stock_guard.says("Get back, this area is restricted!")
			puts "The heavily armed guard shoves you backwards, hard.\n\n"
			move("s")
		end
	end

	def elevator_first()
		puts "There are numbers for floors 1-70 next to a nine digit keypad. ['select']"
	end

	def elevator_move(floor)
		puts "\nThe elevator door closes."
		puts "The elevator begins to move."
		puts "\nThe elevator chimes and a female voice says 'FLOOR #{floor}.'"
		puts "The elevator stops."
		puts "The elevator door opens."
	end

	def select_floor()
   # ToDo - fix so elevator works

		if @cur_room == @game.cyberdine_elevator || @cur_room == @game.cyberdine_elevator_62
			puts "Which floor? (1-70)"
			print "> "
			floor = gets.chomp.to_i
			if (floor > 70) or (floor == 0)
				puts "That floor doesn't exist."
				select_floor()
			elsif floor == 1
				if @cur_room == @game.elevator_first
					puts "You're already on the first floor."
				else
					puts elevator_move(floor)
					@cur_room = @game.cyberdine_elevator
					look
				end
			else
				puts "Enter four digit key code for floor #{floor}:"
				print "> "
				floor_code = gets.chomp
				if (floor == 62) and (floor_code == "4624")
					elevator_move(floor)
					@cur_room = @game.cyberdine_elevator_62
					look
				else
					puts "Access code for floor #{floor} incorrect."
				end
			end
		else
			puts "I don't know what that means."
		end
	end


	def manager_security()
		@game.executive.says("Hey! Who the hell are you? You're not allowed to be here! Security!!")
		dead("Two security guards burst through the door, drag you to a windowless-room, and never let you out.")
	end

	def melanie_meeting()
		if (@melanie_hint_flag == 0) || (@inventory.include? "thumb drive")
			@game.melanie.says("#{@name}! You made it! Do you have the drive?")
			melanie_dialogue()
			@melanie_hint_flag = 1
		end
	end

	def melanie_dialogue()
		puts "\nChoose your response:\n1: \"Sorry, I don't have it yet.\""
		if @inventory.include? "thumb drive"
			puts "2: \"Here you go. Who the hell was that Cypher guy?\""
		end
		print "> "
		response = gets.chomp
		if response == "1"
			@game.melanie.says("Please, come back when you get it! Talk to my friend Cypher in the cafe. Careful though, he's kinda paranoid. I told him you'd ask about the weather.")
		elsif response == "2"
			player_give(@game.melanie, "thumb drive")
		else
			puts "I don't know what that means."
			melanie_dialogue()
		end
	end
		

	def play_message()
		if @cur_room == @game.apartment
			puts "\nPLAYING MESSAGE --"
			puts "\"#{@name}, it's... where are you? It's Melanie. You have to -- *muffled* -- bring me something. Grab a coffee. It looks like rain today, doesn't it? Please hur--\""
			puts "MESSAGE OVER. You have zero new messages.\n"
			@cell_message_flag = 1
		else
			puts "I don't know what that means."
		end
	end

end

class Player

	include Runner
  include Events
  include Items

  attr_reader   :game
	attr_accessor :cur_room, :name, :inventory

	def initialize(cur_room, name, inventory)

		# Include Game
		@game = Game.new

		# Construct player
		@cur_room = @game.instance_variable_get(cur_room)
		@name = name
		@inventory = inventory
	end

	def drop(item)

		if @inventory.include? item
			@cur_room.items << @inventory.delete(item) # Add the item to cur_room.items array and remove it from inventory array
			puts "You drop the #{item}."
		else
			puts "You don't have '#{item}' in your inventory."
		end
	end

	def take(item)

		if @cur_room.items.include? item
			@inventory << @cur_room.items.delete(item) # Add the item to inventory array and remove it from cur_room.items array
			puts "You pick up the #{item}."
		else
			puts "There's no '#{item}' here."
		end
	end

	def npc_give(giver, item)
		@inventory << giver.inventory.delete(item)
		puts "#{giver.name} gives you a #{item}."
	end

	def player_give(receiver, item)
		receiver.inventory << @inventory.delete(item)
		puts "You give #{receiver.name} the #{item}."
		if (item == "thumb drive") && (receiver == @game.melanie)
			@game.melanie.says("#{@name}, you may have just saved my life. But the information on this disk could endanger us both.")
			puts "\nMelanie lowers her voice to a whisper."
			@game.melanie.says("#{@name}.. I know who was behind the market crash. In fact... I've been working for them. And this disk proves it.")
			puts "\nMelanie looks at her watch."
			@game.melanie.says("Security is going to come through that door in 20 seconds. You can either run with me, or get out now. They'll kill you if you stay.")
			puts "\nThere's a LOUD BANGING on the door."
			puts "Melanie looks you in the eye."
			@game.melanie.says("What'll it be, #{@name}?")
			puts "\nTO BE CONTINUED..."
			Process.exit(0)
		end
	end

	def inventory
		print "Your current inventory: #{@inventory}\n" 
	end

	def move(move_direction = @next_move[0])
		if @cur_room.exits[move_direction] # If this exit exists for the room... (not nil)
				# Then the player moves. Interpret the symbol for the next room found in the cur_room's exits hash as an instance variable (instance_variable_get)
				@cur_room = @game.instance_variable_get(cur_room.exits[move_direction]["room"])
				look
			else
				puts "You can't go that way!"
			end
	end

	def inspect_item(item)
		if (@inventory.include? item) || (@cur_room.items.include? item) 
			if ITEM_DESCRIPTIONS.include? item
				puts ITEM_DESCRIPTIONS[item]
			else
				puts "You don't notice anything special."
			end
		else
			puts "There's no #{item} here."
		end
	end

	def look(direction = nil)
		# If no direction is given, room = current room
		# If a direction is given and the direction exists for the current room, room = room in that direction
		# Else - "You can't look at that way."

		if direction.nil?
			room = @cur_room
		elsif !direction.nil? && @cur_room.exits.has_key?(direction)
			room = @game.instance_variable_get(@cur_room.exits[direction]["room"])
		else
			puts "You can't look that way."
		end

		directions_long = { "n" => "north", "e" => "east", "s" => "south", "w" => "west" }

		if room
			puts room.desc # Room description
			puts "Items here: #{room.items.join(', ')}" if room.items # Items
			["n", "e", "s", "w"].each do |exit|
				if room.exits[exit]
				  puts "There's a #{room.exits[exit]["desc"]} to the #{directions_long[exit]}."
				end
			end
		  
	  	for npc in room.npcs
	  		puts "There's a #{npc.type} here."
	  	end

	  	for hero in room.heroes
	  		puts "#{hero.name} is standing here."
	  		if (@cur_room == room)	# If the player and hero are in the same room, trigger hero events if there are any
	  			for event in hero.events
	  				send(event)
	  			end
	  		end
	  	end

	  	if @cur_room == room
		  	for event in room.events
		  		self.send event
		  	end
		  end

		end
	end

	# Die

	def dead(why)
		puts "#{why} Nice!"
		Process.exit(0)
	end		

end

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

class Room

	attr_accessor :desc, :items, :exits, :npcs, :heroes, :events  	# Do :desc and :exits need to be writable here? I think they only need to be read.

	def initialize(desc, items, exits, npcs = [], heroes = [], events = [])
		@desc = desc
		@items = items
		@exits = exits
		@npcs = npcs
		@heroes = heroes
		@events = events

	end
end
	
class Npc # Can I combine Npc and Hero class? Make them a child of a parent class? They are both very similar. In fact they're very similar in general - main difference is heroes have first names and npcs don't.

	attr_accessor :cur_room, :type, :inventory

	def initialize(cur_room, type, inventory=[])
		@cur_room = cur_room
		@type = type
		@inventory = inventory
	end

	def says(string)
		puts "The #{@type} says: \"#{string}\""
	end

end

class Hero

	attr_accessor :cur_room, :name, :inventory, :events

	def initialize(cur_room, name, inventory, events = [])
		@cur_room = cur_room
		@name = name
		@inventory = inventory
		@events = events
	end

	def says(string)
		puts "#{@name} says: \"#{string}\""
	end
end


# Create player

@player = Player.new(:@apartment,"Decard",["headphones", "bottle cap"])
@player.start()

