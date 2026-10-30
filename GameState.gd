extends Node

var has_royal_letter: bool = false 
var queen_quest_completed: bool = false 

func collect_royal_letter() -> void:
	has_royal_letter = true
	print("you found the lost royal letter!")

func complete_queen_quest() -> void:
	if not has_royal_letter:
		return

	
	queen_quest_completed = true 
	print("The Queen's gate is now open!!")
