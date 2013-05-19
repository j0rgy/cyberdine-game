# Cyberdine, a short cyberpunk-esque adventure game
# Original ship date: 2013-05-08 

require_relative 'cyberdine-game/runner'
require_relative 'cyberdine-game/items'
require_relative 'cyberdine-game/events'
require_relative 'cyberdine-game/player'
require_relative 'cyberdine-game/game'
require_relative 'cyberdine-game/room'
require_relative 'cyberdine-game/npc'
require_relative 'cyberdine-game/hero'

# Create player

@player = Player.new(:@apartment,"Decard",["headphones", "bottle cap"])
@player.start()

