extends Node2D

enum TO{Low = 0, High = 1, extra=2}
const EPSILON := Vector2(4e-6, 5e-6)
class Tupla:
	var a
	var b
	
	func _init(InA=null, InB=null):
		a = InA
		b = InB
	

class CubeFaceCoords:
	var CP = 0
	var CQ = 0
	var CR = TO.Low
	
	func _init(InP=0, InQ=0, InR=TO.Low):
		CP = InP
		CQ = InQ
		CR = InR
		return
		
	func setValues(InP=0, InQ=0, InR=TO.Low):
		CP = InP
		CQ = InQ
		CR = InR
		return

class Coordinates:
	var p = 0
	var q = 0
	var r = TO.Low
	var CubeCF = CubeFaceCoords.new()
	
	func _init(InP=0, InQ=0, InR=TO.Low):
		p = InP
		q = InQ
		r = InR
		# transform coords to cube face coords
		setCubeCFValue()
		return
	
	func setCubeCFValue():
		CubeCF.setValues(int(r) + p - q, q, -p)
		
	
	func setByCubeFace(x, y, z):
		p = -z
		q = y
		r = x+y+z
		if r == -1:
			p = -p
			q = -q
			r = -r
		setCubeCFValue()
		return
	
	func setByPush(x, y, z):
		p = x - y
		q = y
		r = z
		setCubeCFValue()
		return
	
	func setByCube(x, y, z):
		p = x + y
		q = y
		r = z
		setCubeCFValue()
		return
	
	func setByCuadratic(x, y, z):
		p = x
		q = y
		r = z
		setCubeCFValue()
		return
	func getCenter(sizeLenght):
		var displacement = Vector2(0,-sqrt(3)/12)
		var center = ToVector2(sizeLenght) 
		if r:
			center -= sizeLenght * displacement - EPSILON
		else:
			center += sizeLenght * displacement - EPSILON
		return center
		
	
	
	func ToVector2(sizeLenght):
		var center = Vector2(1.0/2.0,sqrt(3)/4) 
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
		var x = p_aux + q_aux * sin(theta)
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
		
	func getPushCoords():
		var x = p + q
		var y = q
		return Coordinates.new(x,y,r)
	
	func getCubeCoords():
		var x = p - q
		var y = q
		return Coordinates.new(x,y,r)
	
	func getCubeFaceCoords():
		var pf = p - q
		var qf = q
		var sf = -p
		if r:
			pf += 1
		return Vector3(pf, qf, sf)
		
	func edgeDistance(Coord: Utils.Coordinates = Utils.Coordinates.new()):
		var dif = self.substract(Coord)
		var c_abs = abs(dif.getCubeFaceCoords())
		return c_abs.x + c_abs.y + c_abs.z
	
	func vertexDistance(Coord: Utils.Coordinates = Utils.Coordinates.new()):
		var dif = self.substract(Coord)
		var c_abs = abs(dif.getCubeFaceCoords())
		return max( c_abs.x, c_abs.y, c_abs.z)
	
	func _to_string() -> String:
		var ret = "(%s, %s, %s)" % [str(p), str(q), str(r)]
		return ret
	
	func substract(Coord: Utils.Coordinates) -> Utils.Coordinates:
		var vec1 = self.getCubeFaceCoords()
		var vec2 = Coord.getCubeFaceCoords()
		var dif = vec1 - vec2
		var new_Coord = Utils.Coordinates.new()
		new_Coord.setByCubeFace(dif.x,dif.y,dif.z)
		return new_Coord
	
	func lerp_plane_points(coord2: Utils.Coordinates, TileSize) -> Array:
		var N = self.edgeDistance(coord2)
		var v1 = self.getCenter(TileSize)
		var v2 = coord2.getCenter(TileSize)
		var dif = self.substract(coord2)
		var c_abs = abs(dif.getCubeFaceCoords())
		var d =  c_abs.x + c_abs.y + c_abs.z
		var dif2 = self.getCubeFaceCoords() - coord2.getCubeFaceCoords()
		var dif2_coord = Utils.Coordinates.new()
		dif2_coord.setByCubeFace(dif2.x,dif2.y, dif2.z)
		#print("c1 : ", self)
		#print("c2 : ", coord2)
		#print("c1_CF : ", self.getCubeFaceCoords())
		#print("c2_CF : ", coord2.getCubeFaceCoords())
		#print("dif : ", dif)
		#print("dif2 : ", dif2)
		#print("dif2_FC : ", dif2_coord.getCubeFaceCoords())
		#print("d : ",d)
		#print("N : ", N)
		var out: Array = []

		if N == 0:
			out.append(v1)
			return out

		for i in range(N + 1):
			var t = float(i) / float(N)
			var p = v1 + (v2 - v1) * t
			out.append(p)

		return out
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
	var tempC = Utils.Coordinates.new()
	tempC.setByCuadratic(p0,-q0,r)
	return tempC

func Vector2ToSubspace(vec:Vector2):
	#var center = Vector2(1.0/2.0,sqrt(3)/4) 
	var theta_base = 30
	var theta = PI * -theta_base / 180
	var l = vec.x  
	var t = -vec.y

	# skewed / rhombus coordinates (same transform you used)
	var x = l - t * tan(theta) 
	var y = -t * 1/cos(theta) 
	return Vector2(x,y)

func SubspaceToVector2(vec:Vector2):
	#var center = Vector2(1.0/2.0,sqrt(3)/4) 
	var theta_base = -30
	var theta = PI * -theta_base / 180
	var l = vec.x  
	var t = -vec.y

	# skewed / rhombus coordinates (same transform you used)
	var x = l - t * tan(theta) 
	var y = -t * 1/cos(theta) 
	return Vector2(x,y)


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
	
	
	
