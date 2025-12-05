extends Node2D

enum TO{Low = 0, High = 1, Vertex = -1, extra=2}
const EPSILON := Vector2(4e-6, 5e-6)
const EPSILON3 := Vector3(1e-6, 2e-5, -3e-6)
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
	
	func getNeighborhood():
		var c1 = Coordinates.new()
		var c2 = Coordinates.new()
		var c3 = Coordinates.new()
		var c4 = Coordinates.new()
		var c5 = Coordinates.new()
		var c6 = Coordinates.new()
		c1.setByCubeFace(1,0,-1)
		c2.setByCubeFace(0,1,-1)
		c3.setByCubeFace(-1,1,0)
		c4.setByCubeFace(-1,0,1)
		c5.setByCubeFace(0,-1,1)
		c6.setByCubeFace(1,-1,0)
		return [c1,c2,c3,c4,c5,c6]
	func setCubeCFValue():
		CubeCF.setValues(int(r) + p - q, q, -p)
		
	
	func setByCubeFace(x, y, z):
		p = -z
		q = y
		r = x+y+z
		#if r == -1:
			#p = -p
			#q = -q
			#r = -r
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
	
	func setByWCube(x,y,z):
		if x + y + z != 0:
			push_error("Not a cube coordinate: x+y+z must be 0")
			return Vector3.ZERO
		var coset = Utils.classify_hex_coset_direct(x, y, z)
		var C: Vector3
		if coset == 0:
			r = -1
			C = Vector3(1, -1, 0)      # C0
		elif coset == 1:
			r = 0
			C = Vector3(0,  0, 0)      # C1
		elif coset == 2:
			r = 1
			C = Vector3(-1, 1, 0)      # C2
		else:
			push_error("Invalid coset")
			return Vector3.ZERO
		
		var coord = Vector3(x,y,z)
		var X = coord - C
		var Xx = X.x
		var Xy = X.y
		
		var num_p = int(Xx + 2 * Xy)
		var num_q = int(2 * Xx + Xy)
		
		if num_p % 3 != 0 or num_q % 3 != 0:
			push_error("Point not representable as integer (p,q)")
			return Vector3.ZERO
		p = floor(num_p / 3)
		q = floor(num_q / 3)

	
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
		# 2) Convertir a pixeles (Y positivo hacia abajo)
		var cx = x * sizeLenght 
		var cy = -y * sizeLenght
		if r == TO.Vertex:
			return Vector2(cx,cy) - center * sizeLenght
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
			pf += r
		return Vector3(pf, qf, sf)
	
	func getWCubeCoords():
		# Class representatives
		var C0 := Vector3( 1, -1,  0)   # r = -1 (vertex)
		var C1 := Vector3( 0,  0,  0)   # r =  0 (down triangle)
		var C2 := Vector3(-1,  1,  0)   # r =  1 (up triangle)

		# Basis vectors
		var V1 := Vector3(-1,  2, -1)
		var V2 := Vector3( 2, -1, -1)
		# Pick the coset representative
		var C: Vector3
		match r:
			-1:
				C = C0
			0:
				C = C1
			1:
				C = C2
			_:
				push_error("r must be -1, 0, or 1")
				return Vector3.ZERO
		# Compute C + p*V1 + q*V2
		return C + V1 * float(p) + V2 * float(q)
	
	
	func edgeDistance(Coord: Utils.Coordinates = Utils.Coordinates.new()):
		var dif = self.substract(Coord)
		var c_abs = abs(dif.getCubeFaceCoords())
		return c_abs.x + c_abs.y + c_abs.z
	
	func vertexDistance(Coord: Utils.Coordinates = Utils.Coordinates.new()):
		var dif = self.substract(Coord)
		var c_abs = abs(dif.getCubeFaceCoords())
		return max( c_abs.x, c_abs.y, c_abs.z)
	
	func weakDistance(Coord: Utils.Coordinates = Utils.Coordinates.new()):
		var dif = self.getWCubeCoords() - Coord.getWCubeCoords()
		var c_abs = abs(dif)
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
		#var dif = self.substract(coord2)
		#var c_abs = abs(dif.getCubeFaceCoords())
		#var d =  c_abs.x + c_abs.y + c_abs.z
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
			var point = v1 + (v2 - v1) * t
			out.append(point)

		return out
	
	func lerp_plane_weak_points(coord2: Utils.Coordinates) -> Array:
		var N = self.weakDistance(coord2)
		#print("N : ", N)
		var v1 = self.getWCubeCoords()
		var v2 = coord2.getWCubeCoords()
		var out: Array = []

		if N == 0:
			out.append(v1)
			return out
			
		#v1 += EPSILON3*1000
		#v2 -= EPSILON3*1000
		
		for i in range(N + 1):
			var t = float(i) / float(N)
			var unround = v1 + (v2 - v1) * t
			var point = round(unround)
			var check = abs(unround - point)
			var check2 = unround - point

			#print("UnroundPoint ", i, " : ", unround)
			#print("Point ", i, " : ", point)

			# --- Apply your correction rule ---
			# If a pair is exactly 0.5, adjust the rounded point
			# We check each pair: (x,y), (y,z), (x,z)

			# Pair (x, y)
			if abs(check.x - 0.5) < 0.0001 and abs(check.y - 0.5) < 0.0001:
				point.x += round(check2.x)

			# Pair (y, z)
			elif abs(check.y - 0.5) < 0.0001 and abs(check.z - 0.5) < 0.0001:
				point.y += round(check2.y)

			# Pair (x, z)
			elif abs(check.x - 0.5) < 0.0001 and abs(check.z - 0.5) < 0.0001:
				point.x += round(check2.x)
			
			#print("PointAfter ", i, " : ", point)
			out.append(point)

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

func classify_hex_coset_direct(x: int, y: int, z: int) -> int:
	# Ensure cube constraint
	if x + y + z != 0:
		push_error("Not a cube coordinate: x + y + z must be 0")
		return -1

	var rx = posmod(x, 3)
	var ry = posmod(y, 3)
	var rz = posmod(z, 3)

	var s = posmod((rx - rz), 3)
	var t = posmod((ry - rz), 3)

	# (s, t) pattern defines the coset:
	# class 1 → C1
	if s == 0 and t == 0:
		return 1

	# class 0 → C0
	if s == 1 and t == 2:
		return 0

	# class 2 → C2
	if s == 2 and t == 1:
		return 2

	push_error("Unexpected residue pattern: %d, %d, %d" % [rx, ry, rz])
	return -1

####################
#


func Vector2ToCoords(vec: Vector2, tile_size: float) -> Utils.Coordinates:
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
	var r = int(u + v >= 1)

	# debug: see values while testing
	#print("vec=", vec, " -> p_f=", p_f, " q_f=", q_f, " p0=", p0, " q0=", q0, " u+v=", u+v, " r=", r)
	#print("CoordCuadr : x: ", p0, "  y: ", -q0,"  r: ", r)
	#print("CoordCube: p: ", p0 + q0, "  q: ", -q0,"  r: ", r)
	#var pf = p0 + q0
	#var qf = -q0
	#var sf = -p0
	#if r:
		#pf += 1
	#print("CoordCubeFace: p: ", pf, "  q: ", qf,"  s: ", sf)
	var tempC = Utils.Coordinates.new()
	tempC.setByCuadratic(p0,-q0,r)
	return tempC


func Vector2ToHex(vec: Vector2, tile_size: float) -> Vector3:
	#print("Mouse: ", vec.x, ", ", vec.y)
	var displacement = Vector2(0, sqrt(3)/ 12)
	var center = Vector2(1.0/2.0,sqrt(3)/4.0) 
	#center = Vector2(0,0)
	# convert to tile units; flip Y if needed because screen Y goes down
	#var size = tile_size/ sqrt(3)
	#var l = vec.x / size  + center.x
	#var t = -vec.y / size  - center.y 
	#print("l : ", l, " t : ", t)
	# skewed / rhombus coordinates (same transform you used)
	#var x = sqrt(3)/3.0 * l - 1.0/3.0 * t 
	#var y = -t * 2/3.0 
	#print("x : ", x, "y : ", y)
	#var p0 : int = ceil(x)
	#var q0 : int = ceil(y)
	var x = vec.x / (tile_size) + center.x
	var y = -vec.y / (tile_size) - center.y
	var temp = floor(x + sqrt(3) * y + 1)
	var p0 = floor((floor(2*x+1) + temp) / 3.0);
	var q0 = floor((temp + floor(-x + sqrt(3) * y + 1))/3.0);

	# triangle half: lower if u+v < 1, upper if >= 1
	#var r = -p0 + q0

	# debug: see values while testing
	#print("Offset : col : ", p0 , " row : ", -q0)
	#var parity = posmod(q0, 2)
	#print("Cube : p : ", p0 - (q0 + parity)/2 , " q : ", -q0, " r : ", q0 - (p0 - (q0 + parity)/2 ))
	#print("Cube2 : p : ", p0 - (q0 + parity)/2 + q0, " q : ", -q0, " r : ", - (p0 - (q0 + parity)/2 ))
	#return Vector3(p0 - (q0 + parity)/2 + q0, -q0, - (p0 - (q0 + parity)/2 ))
	#return Vector3(p0 - (q0 + parity)/2 , -q0, - (p0 - (q0 + parity)/2 ) + q0)
	return Vector3(p0 - q0, q0, -p0)


func Vector2ToHexCoord(vec: Vector2, tile_size: float) -> Utils.Coordinates:
	var Hex = Vector2ToHex(vec, tile_size)
	var Coord = Utils.Coordinates.new()
	Coord.setByCube(Hex.x,Hex.y, TO.Vertex)
	return Coord






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

func rotateWeakCube(vec : Vector3):
	var x = vec.x
	var y = vec.y
	var z = vec.z
	return Vector3(-y,-z,-x)

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
	
	
	
