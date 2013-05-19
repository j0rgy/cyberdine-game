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
