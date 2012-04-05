bl_info = {
	"name": "FC Resource format",
	"author": "Martin Linklater",
	"blender": (2, 6, 2),
	"location": "File > Export",
	"description": "Export scene as FC resource",
	"category": "Export"}

import xml.etree.ElementTree as ET
import bpy

class OBJECT_PT_fc(bpy.types.Panel):
	bl_space_type = 'PROPERTIES'
	bl_region_type = 'WINDOW'
	bl_context = "object"
	bl_label = "FC Properties"
	
	def draw(self, context):
		layout = self.layout
		obj = context.object
		
		row = layout.row()
		row.prop(obj, "fc_object_type", "Type")
		
		# now detail row
		
		fctype = obj.fc_object_type
		
		if fctype == 'Locator':
			pass
		elif fctype == 'Actor':
			row = layout.row()
			row.prop(obj, "fc_actor_dynamic", "Dynamic")
		elif fctype == 'Model':
			row = layout.row()
			row.prop(obj, "fc_shader_type", "Shader")
		elif fctype == 'Fixture':
			row = layout.row()
			row.prop(obj, "fc_fixture_type", "Fixture Type")

class Vector3:
	def __init__(self, x=0, y=0, z=0):
		self.x = x
		self.y = y
		self.z = z
		
	def __eq__(self, other):
		return self.x == other.x and self.y == other.y and self.z == other.z

	def __sub__(self, other):
		return Vector3( self.x - other.x, self.y - other.y, self.z - other.z )

	def __str__(self):
		return "({0.x!r},{0.y!r},{0.z!r})".format(self)

	def min(self, a, b):	#make class function ?
		self.x = a.x if a.x < b.x else b.x
		self.y = a.y if a.y < b.y else b.y
		self.z = a.z if a.z < b.z else b.z

	def max(self, a, b):	# make class function ?
		self.x = a.x if a.x > b.x else b.x
		self.y = a.y if a.y > b.y else b.y
		self.z = a.z if a.z > b.z else b.z
	
	def mid(self, a, b):
		self.x = (a.x + b.x) / 2
		self.y = (a.y + b.y) / 2
		self.z = (a.z + b.z) / 2

	def dot(self, other):
		return self.x * other.x + self.y * other.y + self.z * other.z
	
	def x_axis_from_matrix(self, mat):
		self.x = mat[0][0]
		self.y = mat[1][0]
		self.z = mat[2][0]

	def y_axis_from_matrix(self, mat):
		self.x = mat[0][1]
		self.y = mat[1][1]
		self.z = mat[2][1]

	def z_axis_from_matrix(self, mat):
		self.x = mat[0][2]
		self.y = mat[1][2]
		self.z = mat[2][2]
	
	def largest_axis(self):
		if self.x > self.y:
			return self.x if self.x > self.z else self.z
		else:
			return self.y if self.y > self.z else self.z

class ExportFCR(bpy.types.Operator):
	bl_idname = "export_scene.fcr"
	bl_label = "Export FCR"
	filename_ext = ".fcr"
	
	def __init__(self):
		self.__actors = []
		self.__fixtures = []
		self.__models = []
		self.__locators = []
		self.__binaryPayloadElement = []
		self.__texturesElement = []
		self.__gameplayElement = []
		self.__modelsElement = []
		self.__physicsElement = []
		self.__bodiesElement = []
		self.__sceneElement = []

	filepath = bpy.props.StringProperty(subtype="FILE_PATH")

	def processCircleFixture( self, fixture, fixtureElement ):
		fixtureElement.set( "type", "circle" )
		min = Vector3( 99999, 99999, 99999 )
		max = Vector3( -99999, -99999, -99999 )
		for vertex in fixture.data.vertices:
			vert = Vector3( vertex.co.x * fixture.scale[0], vertex.co.y * fixture.scale[1], vertex.co.z * fixture.scale[2] )
			min.min(min, vert)
			max.max(max, vert)
		range = max - min
		radius = range.largest_axis() / 2
		fixtureElement.set("radius", str(radius))
		min.mid(min, max)
		fixtureElement.set( "offsetX", str(min.x))
		fixtureElement.set( "offsetY", str(min.y))
		fixtureElement.set( "offsetZ", str(min.z))
		
	def processBoxFixture( self, fixture, fixtureElement ):
		fixtureElement.set( "type", "box" )
		xAxis = Vector3()
		yAxis = Vector3()
		zAxis = Vector3()
		mat = fixture.matrix_world
		xAxis.x_axis_from_matrix( mat )
		yAxis.y_axis_from_matrix( mat )
		zAxis.z_axis_from_matrix( mat )
		min = Vector3( 99999, 99999, 99999 )
		max = Vector3( -99999, -99999, -99999 )
		for vertex in fixture.data.vertices:
			vec3 = Vector3( vertex.co.x * fixture.scale[0], vertex.co.y * fixture.scale[1], vertex.co.z * fixture.scale[0] )
			min.min(min, vec3)
			max.max(max, vec3)
		size = max - min
		fixtureElement.set("xSize", str(size.x))
		fixtureElement.set("ySize", str(size.y))
		fixtureElement.set("zSize", str(size.z))
		fixtureElement.set("rotationX", str(fixture.rotation_euler.x))
		fixtureElement.set("rotationY", str(fixture.rotation_euler.y))
		fixtureElement.set("rotationZ", str(fixture.rotation_euler.z))
		
	def processHullFixture( self, fixture, fixtureElement ):
		fixtureElement.set( "type", "hull" )
		numVerts = len( fixture.data.vertices )
		fixtureElement.set("numVerts", str(numVerts))
		coordString = ""
		#TODO: Convex check or decomposition into multiple hulls
		for vert in fixture.data.vertices:
			coordString = coordString + "(" + str(vert.co.x) + "," + str(vert.co.y) + "," + str(vert.co.z) + ") "
		fixtureElement.set("verts", coordString)

	def processFixtures(self, fixtures, bodyElement):
		for fixture in fixtures:
			fixtureElement = ET.SubElement( bodyElement, "fixture" )
			fixtureElement.set( "id", fixture.name )
			fixtureElement.set( "material", fixture.material_slots[0].name )
			if fixture.fc_fixture_type == "Circle":
				self.processCircleFixture( fixture, fixtureElement )
			elif fixture.fc_fixture_type == "Box":
				self.processBoxFixture( fixture, fixtureElement )
			else:	# hull
				self.processHullFixture( fixture, fixtureElement )

	def processLocators(self):
		for locator in self.__locators:
			locatorElement = ET.SubElement( self.__gameplayElement, "locator" )
			locatorElement.set( "name", locator.name )
			locatorElement.set( "offsetX", str(locator.location.x) )
			locatorElement.set( "offsetY", str(locator.location.y) )
			locatorElement.set( "offsetZ", str(locator.location.z) )
			locatorElement.set( "rotationX", str(locator.rotation_euler.x) )
			locatorElement.set( "rotationY", str(locator.rotation_euler.y) )
			locatorElement.set( "rotationZ", str(locator.rotation_euler.z) )

	def processScene(self):
		for actor in self.__actors:
			actorElement = ET.SubElement( self.__sceneElement, "actor" )
			actorElement.set("id", actor.name)
			if actor.fc_actor_dynamic:
				actorElement.set("dynamic", "yes")
			else:
				actorElement.set("dynamic", "no")
			actorElement.set("offsetX", str(actor.location.x))
			actorElement.set("offsetY", str(actor.location.y))
			actorElement.set("offsetZ", str(actor.location.z))
			children = actor.children
			# are there any fixtures ?
			fixtures = []
			models = []
			for obj in children:
				if obj.fc_object_type == "Fixture":
					fixtures.append(obj)
				else:
					models.append(obj)

			if len(fixtures):
				actorElement.set("body", actor.name)
				bodyElement = ET.SubElement( self.__bodiesElement, "body")
				bodyElement.set( "id", actor.name )
				self.processFixtures(fixtures, bodyElement)
				
			if len(models):
				pass
#				for model in models:
#					actorElement.set("model", actor.name)
#					modelElement = ET.SubElement( self.__modelsElement, "model")
#					modelElement.set( "id", actor.name )
#					self.processMeshes(
	
	def execute(self, context):
		print("executed FCR export at " + self.filepath)
		# set up both filenames
		
		strippedFilename = ""
		suffixPos = self.filepath.find(".")
		if suffixPos == -1:
			strippedFilename = self.filepath
		else:
			strippedFilename = self.filepath[:suffixPos]

		fcrFilename = strippedFilename + ".fcr"
		binFilename = strippedFilename + ".bin"
		
		binFile = open(binFilename, "wb")
		
		# do stuff
				
		objs = bpy.data.objects


		for obj in objs:
			if obj.fc_object_type == "Actor":
				self.__actors.append( obj )
			if obj.fc_object_type == "Fixture":
				self.__fixtures.append( obj )
			if obj.fc_object_type == "Model":
				self.__models.append( obj )
			if obj.fc_object_type == "Locator":
				self.__locators.append( obj )

		
		xmlRoot = ET.Element("fcr")
		xmlRoot.set( 'version', '1' )
		
		self.__binaryPayloadElement = ET.SubElement( xmlRoot, "binarypayload" )
		self.__texturesElement = ET.SubElement( xmlRoot, "textures" )
		self.__gameplayElement = ET.SubElement( xmlRoot, "gameplay" )
		self.__modelsElement = ET.SubElement( xmlRoot, "models" )
		self.__physicsElement = ET.SubElement( xmlRoot, "physics" )
		self.__bodiesElement = ET.SubElement( self.__physicsElement, "bodies" )
		self.__sceneElement = ET.SubElement( xmlRoot, "scene" )
		
		self.processScene()
		self.processLocators()
		
		#write xml out
		root = ET.ElementTree(xmlRoot)
		root.write( fcrFilename, encoding='UTF-8', xml_declaration=True )

		binFile.close()

		return {'FINISHED'}

	def invoke(self, context, event):
		context.window_manager.fileselect_add(self)
		return {'RUNNING_MODAL'}	
		

def menu_func_export(self, context):
	self.layout.operator(ExportFCR.bl_idname, text="FC Resource (.fcr/.bin)")

def register():
	FCObjectTypes = [("None", "None", "None"), ("Locator", "Locator", "Locator"), ("Actor", "Actor", "Actor"), ("Fixture", "Fixture", "Fixture"), ("Model", "Model", "Model")]
	bpy.types.Object.fc_object_type = bpy.props.EnumProperty( items = FCObjectTypes, name = "FC Type", description = "FC Type", default = "None")
	
	FCFixtureTypes = [("Circle", "Circle", "Circle"), ("Box", "Box", "Box"), ("Hull", "Hull", "Hull")]
	bpy.types.Object.fc_fixture_type = bpy.props.EnumProperty( items=FCFixtureTypes, name="FixtureType", description="Fixture Type", default="Hull" )
	
	FCShaderTypes = [("Debug", "Debug", "Debug"), ("Simple", "Simple", "Simple")]
	bpy.types.Object.fc_shader_type = bpy.props.EnumProperty( items=FCShaderTypes, name="ShaderType", description="Shader", default="Debug" )
	
	bpy.types.Object.fc_actor_dynamic = bpy.props.BoolProperty( name="Dynamic", description="Dynamic, moving actor" )
	
	bpy.utils.register_class(OBJECT_PT_fc)
	bpy.utils.register_class(ExportFCR)
	bpy.types.INFO_MT_file_export.append(menu_func_export)
	
def unregister():
	bpy.utils.unregister_class(OBJECT_PT_fc)
	bpy.utils.unregister_class(ExportFCR)
	bpy.types.INFO_MT_file_export.remove(menu_func_export)

if __name__ == "__main__":
	register()