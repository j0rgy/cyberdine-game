# Cyberpunk MUD
# Ship date: 

# ToDos - Features
# [x] Move inventory commands from hash in command_parser to player methods?
# [x] Figure out how to 'look' in a direction
# => [x] Create function that returns the exit for a given direction
# =>     [x] How do I reference a local or instance variable within a class? Answer: class_instance.variable
# [x] Create NPCs
# => [x] Put NPC in a room. Each room needs an NPC array with current NPCs there
# [x] Figure out 'custom events'
# => How do I trigger a conversation if a hero is standing in the room with a player?
# [x] Dialogue
# => Specific events that only happen if a trigger is true.
# [x] Create 'inspect' command to look at items and people

# ToDos - Refactoring 

# Questions
# [x] Where should the 'directions' table live? 
# -- Within rooms themselves? "w" => ['door',:@alley]

# Inventory
# => Array of items
# => You can 'pick up' items to add them to your Inventory
# => When you use an item it's depleted from your Inventory
# => Each 'room' also has an array of items in it
# => Have to add a 'quantity' for certain items
# => If you 'look at' an item it will describe it
# => Can you 'look at' an item in your inventory?

# Commands
# => look east (perform 'look(room)' in any direction)
# => take item (add item to inventory, remove it from room's inventory)
# => drop item (drop item from inventory, add it to room's inventory)
# => give item to character (drop item from inventory, add it to character's inventory)

# Custom room events
# => Add another hash/array for custom room events
# => Add a check for when they are triggered
# => - Ex: If NPC has disk in his inventory, trigger event where he calls you over in the cyber cafe

# Dialogue?
# => Dialogue choices by number

# Hacking
# => Hack workplace computers, security systems
# => Obtain a laptop

# Money
# => 

# Fighting
# => 

# Story
# => Add a newspaper in your apartment that describes the market crash, violence etc.
# => Discover your phone is bugged? For some reason make your apartment not safe anymore, then lead player to a new safe spot (someone else's)

# Map
# The game starts on a city street. Different locations:
# => Night club
# => -- Bar
# => -- Dance floor
# => -- VIP room
# => Alley
# => -- Your apartment (accessed by fire escape)
# => Cyber cafe
# => City square (Times Square esque)
# => Subway (you can take it to two different locations)
# => -- Pier
# => -- Financial district
# =>  		- Stock exchange (blocked off by military vehicles)
# =>      - Sky scraper
# =>        - Elevator
# =>        	- Office floor
# =>        	- Roof

# Command interpreter
@directions = { "n" => 0, "e" => 1, "s" => 2, "w" => 3, "north" => 0, "east" => 1, "south" => 2, "west" => 3 }
@inventory = { "i" => "inventory(@player)", "drop" => "@player.drop(next_move_args)", "take" => "@player.take(next_move_args)" }
@look_cur_room = { "look" => "look(@player.cur_room)", "l" => "look(@player.cur_room)" }
@look_next_room = { "look" => "look(@next_room)", "l" => "look(@next_room)" }
@event_commands = { "play message" => "play_message()", "select floor" => "select_floor()" }
@inspect = { "inspect" => "inspect(next_move_args)", "i" => "inspect(next_move_args)" }
@help = { "h" => "help()", "help" => "help()" }

# Item descriptions
@item_descriptions = { "slip of paper" => "It has \"Floor 62, 4624\" written on it." }

# Event flags
@cell_message_flag = 0
@melanie_hint_flag = 0

def start()
	print "> "
	next_move = gets.chomp
	if next_move != "exit"
		command_parser(next_move)
		start()
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


def command_parser(next_move)
	# ToDos
	# [-] Create table for accepted commands -- don't need this, the if statements work for now
	# [x] Split next_move on spaces, interpret each command like 'pick up cigarettess
	# [ ] Make it so I cann drop something that has a space in it like "pack of cigarettes" -- join next_move[1]+[2]+[3]?

	# Split next_move into different elements
	next_move = next_move.split(' ')
	if !next_move[1].nil? # If there is anything given after the first word...
		next_move_args = next_move.last(next_move.count - 1).join(" ") # Join all of the words after the first into a single variable
	end

	# Movement
	if @directions.include? next_move[0]
		if !@player.cur_room.exits[@directions[next_move[0]]][1].nil? # If this exit exists for the room... (not nil)
			# Then the player moves. Interpret the symbol for the next room found in the cur_room's exits hash as an instance variable (instance_variable_get)
			enter(instance_variable_get(@player.cur_room.exits[@directions[next_move[0]]][1])) 
		else
			puts "You can't go that way!"
		end

	# Inventory
	elsif @inventory.include? next_move[0]
		eval @inventory[next_move[0]]

	# Look in current room
	elsif (@look_cur_room.include? next_move[0]) && (next_move[1].nil?) # If there's not a second element in the next_move array...
																																	 # Why does "&&" not work here? -- It does. Use parenthesis around each statement
		eval @look_cur_room[next_move[0]]	

	# Look in next room
	elsif (@look_next_room.include? next_move[0]) && (@directions.include? next_move[1]) # ToDo -- Refactor this code. Pretty messy.
		if !@player.cur_room.exits[@directions[next_move[1]]][1].nil?
			@next_room = instance_variable_get(@player.cur_room.exits[@directions[next_move[1]]][1])
			look(@next_room)
		else
			puts "You can't look that way."
		end

	# Inspect items
	elsif @inspect.include? next_move[0]
		eval @inspect[next_move[0]]

	# Play message
	elsif @event_commands.include? next_move.join(" ")
		eval @event_commands[next_move.join(" ")]

 # Play message
	elsif @help.include? next_move[0]
		eval @help[next_move[0]]		

	# Unknown	
	else
		puts "I don't know what that means."
	end
		
end

# Die

def dead(why)
	puts "#{why} Nice!"
	Process.exit(0)
end

# Events

def cypher_thumb()
	if @cypher.inventory.include? "thumb drive"
		puts "\nCypher looks you up and down."
		@cypher.says("Can I help you?")
		cypher_dialogue()		
	end
end

def cypher_dialogue()
	puts "\nChoose your response:\n1: \"Just minding my own business.\"\n2: \"What's it to you, old man?\"\n3: \"Looks like rain today, doesn't it?\""
	print "> "
	response = gets.chomp
	if response == "1"
		@cypher.says("Well mind it somewhere else.")
		puts "#{@cypher.name} shoves you out of the room."
		enter(@cafe)
	elsif response == "2"
		dead("Cypher stabs you in the throat and you bleed to death on the floor.")
	elsif response == "3"
		@cypher.says("#{@player.name}! I've been waiting for you!") # Why does @name work here? Shouldn't it have to be @player.name? I'm calling it from outside the 'Player' class..?? -- Update: No. I had 'enter' as a player method, so when I moved I was calling look from inside Player!
		npc_give(@cypher,"thumb drive")
		@cypher.says("Melanie needs this. She's in the financial district, Cyberdine building, floor 62. You'll need this code to get in.")
		npc_give(@cypher,"slip of paper")
		@cypher.says("Good luck, #{@player.name}.")
		puts "#{@cypher.name} slips out of the room."
		@cafe_corner.heroes.delete(@cypher)
	else
		puts "I don't know what that means."
		cypher_dialogue()
	end
end

def cell_message()
	if @cell_message_flag == 0
		puts "Your answering machine is blinking it has 1 message waiting. ['play message']"
	end
end

def stock_security()
	if (@player.cur_room == @stock_exchange) and (@player.cur_room.npcs.include? @stock_guard)
		puts "\nThe heavily armed guard points a large machine gun at you."
		@stock_guard.says("Get back, this area is restricted!")
		puts "The heavily armed guard shoves you backwards, hard.\n\n"
		enter(@financial_district)
	end
end

def elevator_first()
	puts "There are numbers for floors 1-70 next to a nine digit keypad. ['select floor']"
end

def elevator_move(floor)
	puts "\nThe elevator door closes."
	puts "The elevator begins to move."
	puts "\nThe elevator chimes and a female voice says 'FLOOR #{floor}.'"
	puts "The elevator stops."
	puts "The elevator door opens."
end

def select_floor()
	if @player.cur_room == @cyberdine_elevator || @player.cur_room == @cyberdine_elevator_62
		puts "Which floor? (1-70)"
		print "> "
		floor = gets.chomp.to_i
		if (floor > 70) or (floor == 0)
			puts "That floor doesn't exist."
			select_floor()
		elsif floor == 1
			if @player.cur_room == elevator_first
				puts "You're already on the first floor."
			else
				puts elevator_move(floor)
				enter(@cyberdine_elevator)
			end
		else
			puts "Enter four digit key code for floor #{floor}:"
			print "> "
			floor_code = gets.chomp
			if (floor == 62) and (floor_code == "4624")
				elevator_move(floor)
				enter(@cyberdine_elevator_62)
			else
				puts "Access code for floor #{floor} incorrect."
			end
		end
	else
		puts "I don't know what that means."
	end
end


def manager_security()
	@executive.says("Hey! Who the hell are you? You're not allowed to be here! Security!!")
	dead("Two security guards burst through the door, drag you to a windowless-room, and never let you out.")
end

def melanie_meeting()
	if (@melanie_hint_flag == 0) || (@player.inventory.include? "thumb drive")
		@melanie.says("#{@player.name}! You made it! Do you have the drive?")
		melanie_dialogue()
		@melanie_hint_flag = 1
	end
end

def melanie_dialogue()
	puts "\nChoose your response:\n1: \"Sorry, I don't have it yet.\""
	if @player.inventory.include? "thumb drive"
		puts "2: \"Here you go. Who the hell was that Cypher guy?\""
	end
	print "> "
	response = gets.chomp
	if response == "1"
		@melanie.says("Please, come back when you get it! Talk to my friend Cypher in the cafe. Careful though, he's kinda paranoid. I told him you'd ask about the weather.")
	elsif response == "2"
		player_give(@melanie, "thumb drive")
	else
		puts "I don't know what that means."
		melanie_dialogue()
	end
end
	

def play_message()
	if @player.cur_room == @apartment
		puts "\nPLAYING MESSAGE --"
		puts "\"#{@player.name}, it's... where are you? It's Melanie. You have to -- *muffled* -- bring me something. Grab a coffee. It looks like rain today, doesn't it? Please hur--\""
		puts "MESSAGE OVER. You have zero new messages.\n"
		@cell_message_flag = 1
	else
		puts "I don't know what that means."
	end
end

# Create commands

def npc_give(giver, item)
	@player.inventory << giver.inventory.delete(item) # Again, not sure why 'inventory' works here and not @player.inventoru
	puts "#{giver.name} gives you a #{item}."
end

def player_give(receiver, item)
	receiver.inventory << @player.inventory.delete(item)
	puts "You give #{receiver.name} the #{item}."
	if (item == "thumb drive") && (receiver == @melanie)
		@melanie.says("#{@player.name}, you may have just saved my life. But the information on this disk could endanger us both.")
		puts "\nMelanie lowers her voice to a whisper."
		@melanie.says("#{@player.name}.. I know who was behind the market crash. In fact... I've been working for them. And this disk proves it.")
		puts "\nMelanie looks at her watch."
		@melanie.says("Secuity is going to come through that door in 20 seconds. You can either run with me, or get out now. They'll kill you if you stay.")
		puts "\nMelanie looks you in the eye."
		@melanie.says("What'll it be, #{@player.name}?")
		puts "\nTO BE CONTINUED..."
		Process.exit(0)
	end
end

def inventory(character)
	if character == @player
		print "Your current inventory: #{@player.inventory}\n" 
	end
end

def inspect(item)
	if (@player.inventory.include? item) || (@player.cur_room.items.include? item) 
		if @item_descriptions.include? item
			puts @item_descriptions[item]
		else
			puts "You don't notice anything special."
		end
	else
		puts "There's no #{item} here."
	end
end
		

def look(room)
	if room.nil?
		puts "You can't look that way."
	else
		puts room.desc # Room description
		puts "Items here: #{room.items.to_s}" if !room.items[0].nil? # Items
		if !room.exits[0][0].nil? then puts "There's a #{room.exits[0][0]} to the north." end # Room exits
		if !room.exits[1][0].nil? then puts "There's a #{room.exits[1][0]} to the east." end
		if !room.exits[2][0].nil? then puts "There's a #{room.exits[2][0]} to the south." end
		if !room.exits[3][0].nil? then puts "There's a #{room.exits[3][0]} to the west." end
		# if room.exits[0..3].nil? then puts "There are no exits defined!" end # This doesn't work
	  
  	for npc in room.npcs
  		puts "There's a #{npc.type} here."
  	end

  	for hero in room.heroes
  		puts "#{hero.name} is standing here."
  		if (@player.cur_room == room)	# If the player and hero are in the same room, trigger hero events if there are any
  			for event in hero.events
  				eval event
  			end
  		end
  	end

  	if @player.cur_room == room
	  	for event in room.events
	  		eval event
	  	end
	  end

	end
end

def enter(room)
	@player.cur_room = room
	look(room)
end

class Player

	attr_accessor :cur_room, :name, :inventory

	def initialize(cur_room, name, inventory)
		@cur_room = cur_room
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
	[[nil],[nil],[nil],['door',:@alley]],
	[],
	[],
	['cell_message()'])

@alley = Room.new(
	"A dark alley. There's gang graffiti on the brick walls. Trash is piled everywhere. Not a place you want to run into someone.",
	['latex glove', 'lottery ticket', 'dead rat'],
	[[nil],['door',:@apartment],[nil],['busy city square',:@city_square]])

@city_square = Room.new(
	"The bustling center of the city. People are walking about everywhere. Bright video advertisements play from screens suspended in the sky, one after the other. Street vendors line the sidewalk.",
	['newspaper', 'empty coke can', 'ATM receipt'],
	[['financial district',:@financial_district],['side alley',:@alley],[nil],['cafe',:@cafe]])

@cafe = Room.new(
	"A busy cyber cafe. Rows of desks line the room with people hunched over staring into bright flat screens. The smell of rich coffee is almost overpowering.",
	[],
	[['dark corner',:@cafe_corner],['busy city square',:@city_square],[nil],[nil]])

@cafe_corner = Room.new(
	"A dark corner of the cafe, away from the prying eyes of customers and employees.",
	['laptop', 'old computer cable'],
	[[nil],[nil],['cafe',:@cafe],[nil]])

@financial_district = Room.new(
	"The financial district. Gleaming skyscrapers rise up all around you. Businessmen and women are marching around with expressions of serious purpose. The streets smell like money.",
	['expired sell ticket', 'crumpled resume'],
	[['large stock exchange building',:@stock_exchange],[nil],['busy city square',:@city_square],['tall skyscraper',:@cyberdine_lobby]])

@stock_exchange = Room.new(
	# Desc
	"The stock exchange. A massive, courthouse-like building framed by two large crumbling marble columns. The building was destroyed two years ago by rioters during the crash of 2018, and although currently operational it's still being slowly re-built.",
	# Items
	[],
	# Exits
	[[nil],[nil],['financial district',:@financial_district],[nil]],
	# Npcs
	[], 
	# Heroes
	[],
	# Events
	['stock_security()'])

@cyberdine_lobby = Room.new(
	"The granite-floored lobby of a towering office high-rise. The metallic logo behind the receptionist reads \"Cyberdine Headquarters.\"",
	['lamp','leather couch','gold trash can'],
	[['elevator',:@cyberdine_elevator],['financial district',:@financial_district],[nil],[nil]])

@cyberdine_elevator = Room.new(
	"A luxurious, modern elevator. The back wall is one large mirror.",
	# Items
	[],
	# Exits
	[[nil],[nil],['lobby',:@cyberdine_lobby],[nil]],
	# Npcs
	[], 
	# Heroes
	[],
	# Events
	['elevator_first()'])

@cyberdine_elevator_62 = Room.new(
	"A luxurious, modern elevator. The back wall is one large mirror.",
	# Items
	[],
	# Exits
	[[nil],['office hallway',:@office_hallway],[nil],[nil]],
	[],
	[],
	['elevator_first()'])

@office_hallway = Room.new(
	"A nicely carpeted hallway leading to two doors separated by a large floor-to-ceiling window. You can see the whole city from up here.",
	[],
	[['office door',:@manager_office],[nil],['office door',:@melanie_office],['elevator',:@cyberdine_elevator_62]])

@manager_office = Room.new(
	"An executive office suite. A large oak desk in the center of the office. Old leather books, college credentials and corporate placques line the walls.",
	[],
	[[nil],[nil],['office hallway',:@office_hallway],[nil]],
	[],
	[],
	['manager_security()'])


@melanie_office = Room.new(
	"A younger person's office. Artistic grafitti murals cover the walls. There are bean bag chairs and a low, modern desk.",
	[],
	[['office hallway',:@office_hallway],[nil],[nil],[nil]])

# Create Npcs
# (location, name, inventory)

@vendor = Npc.new(@city_square,"street vendor",["hotdog"]) # Do I need the 'location' here? I guess I should keep it in case I want to make them move around.
@city_square.npcs << @vendor # Put the vendor in the city square, after we define both

@stock_guard = Npc.new(@stock_exchange,"heavily armed guard")
@stock_exchange.npcs << @stock_guard

@receptionist = Npc.new(@cyberdine_lobby,"receptionist")
@cyberdine_lobby.npcs << @receptionist

@executive = Npc.new(@manager_office,"business executive")
@manager_office.npcs << @executive

# Create heroes
@cypher = Hero.new(@cafe_corner,"Cypher",["thumb drive","slip of paper"],['cypher_thumb()'])
@cafe_corner.heroes << @cypher

@melanie = Hero.new(@melanie_office,"Melanie",[],['melanie_meeting()'])
@melanie_office.heroes << @melanie

# Create player

# Start game
print "Name your character: "
char_name = gets.chomp()

# Create player

@player = Player.new(@apartment,char_name,["headphones", "bottle cap"])

puts "\n#{@player.name}, welcome to:"
print "
 .o88b. db    db d8888b. d88888b d8888b. d8888b. d888888b d8b   db d88888b 
d8P  Y8 `8b  d8' 88  `8D 88'     88  `8D 88  `8D   `88'   888o  88 88'     
8P       `8bd8'  88oooY' 88ooooo 88oobY' 88   88    88    88V8o 88 88ooooo 
8b         88    88~~~b. 88~~~~~ 88`8b   88   88    88    88 V8o88 88~~~~~ 
Y8b  d8    88    88   8D 88.     88 `88. 88  .8D   .88.   88  V888 88.     
 `Y88P'    YP    Y8888P' Y88888P 88   YD Y8888D' Y888888P VP   V8P Y88888P                                             

"
puts "Type 'help' for help.\n\n"

look(@player.cur_room)
start()