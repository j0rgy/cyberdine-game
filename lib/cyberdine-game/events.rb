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
