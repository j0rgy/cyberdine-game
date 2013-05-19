
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
