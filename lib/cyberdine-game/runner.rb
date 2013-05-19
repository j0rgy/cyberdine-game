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