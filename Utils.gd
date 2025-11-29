extends Node2D

enum TO{Low = 0, High = 1}

class Tupla:
	var a
	var b
	
	func _init(InA=null, InB=null):
		a = InA
		b = InB
	

class Coordinates:
	var p = 0
	var q = 0
	var r = TO.Low
	
	func _init(InP=0, InQ=0, InR=TO.Low):
		p = InP
		q = InQ
		r = InR
		return
	
	func setByCubeFace(x, y, z):
		p = -z
		q = y
		r = x+y+z
		return
	func setByCuadratic(x, y, z):
		p = x - y
		q = y
		r = z
		return
		
	func ToVector2(sizeLenght):
		##var x = - q*(sizeLenght/2)  + r*(sizeLenght/2) 
		##var x = (sqrt(3)/2*p + sqrt(3)/4 * q) * sizeLenght + r*(sizeLenght/2) 
		#var x = q*(sizeLenght/2) + p*sizeLenght 
		#if r:
			#x += (sizeLenght/2)
		##var y = -q*sqrt(3)*(sizeLenght/2)
		##var y = (3.0/4) * p * sizeLenght
		#var y = -q*sqrt(3)*(sizeLenght/2)
		#return Vector2(x, y)
		var theta_base = 30
		var theta = PI * theta_base / 180
		var p_aux = p
		var q_aux = -q
		# 1) Convertir coord → centro matemático del triángulo
		var x = p_aux - q_aux * sin(theta) 
		var y = -q_aux * cos(theta) 
		
		#x = p 
		#y = -q
		var h = sizeLenght * cos(theta)
		# 2) Convertir a pixeles (Y positivo hacia abajo)
		var cx = x * sizeLenght 
		var cy = -y * sizeLenght
		if r:
			cx += (sizeLenght/2)
		return Vector2(cx,cy)
		
	func toCuadratic():
		var x = p + q
		var y = q
		return Coordinates.new(x,y,r)
	
	func toCube():
		var x = p - q
		var y = q
		return Coordinates.new(x,y,r)
	
	func toCubeFace():
		var pf = p - q
		var qf = q
		var sf = -p
		if r:
			pf += 1
		return Vector3(pf, qf, sf)
		
	func edgeDistance():
		var c_abs = abs(self.toCubeFace())
		return c_abs.x + c_abs.y + c_abs.z
	
	func vertexDistance():
		var c_abs = abs(self.toCubeFace())
		return max( c_abs.x, c_abs.y, c_abs.z)
	
	func _to_string() -> String:
		var ret = "(%d, %d, %d)" % [p, q, r]
		return ret
	
#
#
#
# MATHS 
func _combinations(arr: Array, r: int) -> Array:
	var out := []
	_comb_dfs(arr, r, 0, [], out)
	return out

func _comb_dfs(arr: Array, r: int, start: int, current: Array, out: Array) -> void:
	if current.size() == r:
		out.append(current.duplicate())
		return
	for i in range(start, arr.size()):
		current.append(arr[i])
		_comb_dfs(arr, r, i+1, current, out)
		current.pop_back()
		
func _sign_assignments(count: int, current: Array, out: Array) -> void:
	if current.size() == count:
		out.append(current.duplicate())
		return
	# append -1
	current.append(-1)
	_sign_assignments(count, current, out)
	current.pop_back()
	# append +1
	current.append(1)
	_sign_assignments(count, current, out)
	current.pop_back()
####################
#


func Vector2ToCoords(vec: Vector2, tile_size: float, invert_y := true) -> Utils.Coordinates:
	var center = Vector2(1.0/2.0,sqrt(3)/4) 
	#center = Vector2(0,0)
	var theta_base = 30
	var theta = PI * -theta_base / 180
	# convert to tile units; flip Y if needed because screen Y goes down
	var l = vec.x / tile_size  + center.x
	var t = -vec.y / tile_size  - center.y

	# skewed / rhombus coordinates (same transform you used)
	var x = l - t * tan(theta) 
	var y = -t * 1/cos(theta) 

	var p0 : int = floor(x)
	var q0 : int = floor(y)

	var u = x - p0    # fractional part 0..1
	var v = y - q0    # fractional part 0..1

	# triangle half: lower if u+v < 1, upper if >= 1
	var r = (u + v >= 1)

	# debug: see values while testing
	#print("vec=", vec, " -> p_f=", p_f, " q_f=", q_f, " p0=", p0, " q0=", q0, " u+v=", u+v, " r=", r)
	#print("CoordCuadr : x: ", p0, "  y: ", -q0,"  r: ", r)
	#print("CoordCube: p: ", p0 + q0, "  q: ", -q0,"  r: ", r)
	var pf = p0 + q0
	var qf = -q0
	var sf = -p0
	if r:
		pf += 1
	#print("CoordCubeFace: p: ", pf, "  q: ", qf,"  s: ", sf)

	return Utils.Coordinates.new(p0, -q0, r)


	

class CoordinatesCF:
	var a = 0
	

### ---- ---- ###


enum Side{Left=0, Right, Up, Down}

class TableroFlexible:
	var XSize:Vector2 = Vector2(0,0)
	var YSize:Vector2 = Vector2(0,0)
	
	var TRVector:Array = []
	var TLVector:Array = []
	var BRVector:Array = []
	var BLVector:Array = []
	
	
	func _init(LeftLenght:int, RightLenght:int, TopLenght:int, BottomLenght:int) -> void:
		# Left <= 0
		if LeftLenght > 0 : LeftLenght = 0
		if BottomLenght > 0 : BottomLenght = 0
		if RightLenght < 0 : LeftLenght = 0
		if TopLenght < 0 : TopLenght = 0
		self.XSize = Vector2(LeftLenght, RightLenght)
		self.YSize = Vector2(BottomLenght, TopLenght)
		
		# Add Arrays
		
		for y in TopLenght:
			var Rarr = []
			Rarr.resize(RightLenght)
			Rarr.fill(0)
			var Larr = []
			Larr.resize(LeftLenght)
			Larr.fill(0)
			TRVector.append(Rarr)
			TLVector.append(Larr)
		for y in BottomLenght:
			var Rarr = []
			Rarr.resize(RightLenght)
			Rarr.fill(0)
			var Larr = []
			Larr.resize(LeftLenght)
			Larr.fill(0)
			BRVector.append(Rarr)
			BLVector.append(Larr)
		
		
		pass
	
	
	
