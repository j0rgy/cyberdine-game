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
