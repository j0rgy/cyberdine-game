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
