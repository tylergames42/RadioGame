extends OmniLight3D


func _on_toggleable_component_toggled_on():
	self.show()


func _on_toggleable_component_toggled_off():
	self.hide()
