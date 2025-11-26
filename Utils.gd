extends Node2D

enum TO{Low = 0, High = 1}

class Coordinates:
	var p = 0
	var q = 0
	var r = TO.Low
	
	func _init(InP=0, InQ=0, InR=TO.Low):
		p = InP
		q = InQ
		r = InR
		return
	
	func ToVector2(sizeLenght):
		#var x = - q*(sizeLenght/2)  + r*(sizeLenght/2) 
		#var x = (sqrt(3)/2*p + sqrt(3)/4 * q) * sizeLenght + r*(sizeLenght/2) 
		var x = q*(sizeLenght/2) + p*sizeLenght + r*(sizeLenght/2)
		#var y = -q*sqrt(3)*(sizeLenght/2)
		#var y = (3.0/4) * p * sizeLenght
		var y = -q*sqrt(3)*(sizeLenght/2)
		return Vector2(x, y)
	
	func DistanceTo(InCoord):
		
		return InCoord
