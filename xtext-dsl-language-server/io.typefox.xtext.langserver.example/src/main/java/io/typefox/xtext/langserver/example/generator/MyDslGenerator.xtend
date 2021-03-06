/*
 * generated by Xtext 2.12.0-SNAPSHOT
 */
package io.typefox.xtext.langserver.example.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

import io.typefox.xtext.langserver.example.myDsl.CmdWithColList
import io.typefox.xtext.langserver.example.myDsl.CmdWithDf
import io.typefox.xtext.langserver.example.myDsl.CmdWithRowCond
import io.typefox.xtext.langserver.example.myDsl.ColumnList
import io.typefox.xtext.langserver.example.myDsl.NewSession
import io.typefox.xtext.langserver.example.myDsl.StopSession
import io.typefox.xtext.langserver.example.myDsl.ChainOperation
import io.typefox.xtext.langserver.example.myDsl.Enum_CmdWithRowCond
import io.typefox.xtext.langserver.example.myDsl.LineOperation
import io.typefox.xtext.langserver.example.myDsl.NewSchema
import io.typefox.xtext.langserver.example.myDsl.Assignment
import io.typefox.xtext.langserver.example.myDsl.LoadData
import io.typefox.xtext.langserver.example.myDsl.Filetype
import org.eclipse.emf.ecore.EObject
import io.typefox.xtext.langserver.example.myDsl.ColumnType
import io.typefox.xtext.langserver.example.myDsl.TypedColumn
import io.typefox.xtext.langserver.example.myDsl.CmdNoParameter
import io.typefox.xtext.langserver.example.myDsl.RowCondition

/**
 * Generates code from your model files on save.
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class MyDslGenerator extends AbstractGenerator {

	public static CharSequence currentContent

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {

		// We generate a Python file called generate.py
		// FIXME: The generated file needs to be parametrized
		fsa.generateFile('example.py', generateAllContent(resource))
	}


	/**
	 * Generate the code for the entire @Resource object.
	 * Each line is iterated and a respective Python code line
	 * is generated by this method
	 */
	def CharSequence generateAllContent(Resource resource) {

		var str = new StringBuilder()
		for (line : resource.allContents.toIterable.filter(LineOperation)) {

			//val res = line.eResource()
			//println(res.getURIFragment(line))

			str.append(generateOperationContent(line))
		}
		currentContent = str
		return str
	}

	def CharSequence generateOperationContent(LineOperation lineOperation) {

		for (newSession : lineOperation.eAllContents.toIterable.filter(NewSession)) {
			return newSession.compile
		}

		// End Session
		for (stopSession : lineOperation.eAllContents.toIterable.filter(StopSession)) {
			return stopSession.compile
		}

		val str = new StringBuilder()

		// Load
		for (load : lineOperation.eAllContents.toIterable.filter(LoadData)) {
			str.append(load.compile)
		}

		// Chained Operations
		for (chain : lineOperation.eAllContents.toIterable.filter(ChainOperation)) {
			str.append('''«chain.compile»''')
		}
		return str

	}

	def CharSequence generateFileTypeCode(LoadData e) {
		if(e.fileType == Filetype.JSON)
			return "json("
		if(e.fileType == Filetype.CSV)
			return "csv("
		if(e.fileType == Filetype.PARQUET)
			return "load("
	}

	def CharSequence generateAssignment(EObject container) {
		// FIXME: There must be a better way to do this check
		if(container !== null && container instanceof Assignment) {
			return container.compile
		}
		return ''
	}

	def CharSequence generateStructField(TypedColumn col) '''
		StructField("«col.columnName»", «getType(col.type)», True)'''

	//withColumn(a, df["a"].cast(FloatType))
	def dispatch compile(NewSchema e) '''
		«generateAssignment(e.eContainer)»StructType([
			«e.identifierList.typedcolumns.map[generateStructField].join(",\n")»])

	'''

	def CharSequence getType(ColumnType type) {
		switch(type) {
			case DOUBLE: return 'DoubleType()'
			case FLOAT: return 'FloatType()'
			case INT: return 'IntegerType()'
			case STR: return 'StringType()'
		}
	}

	def dispatch compile(LoadData e) '''
		«generateAssignment(e.eContainer)»spark.read.«generateFileTypeCode(e)»«e.pathname», schema=«e.schema»)

	'''

	def dispatch compile(Assignment e) '''«e.name» = '''

	def dispatch compile(NewSession e) '''spark = SparkSession \
	.builder("«e.applicationName»") \
	.getOrCreate()
sc = spark.sparkContext

	'''

	// FIXME: Check why we have StopSession.name
	def dispatch compile(StopSession e) '''
		spark.stop()

	'''

	def dispatch compile(CmdNoParameter e) '''
		.«e.concreteCmd»()
	'''

	def dispatch compile(CmdWithDf e) '''
		«generateAssignment(e.eContainer)»«e.dataframe»'''

	def dispatch compile(CmdWithColList e) '''
		.select(«e.colList.compileColumList»)'''

	def compileColumList(ColumnList e) '''«e.columnName.join(", ")»'''

	def compileRowCondition(RowCondition e) '''
		col("«e.col»") «e.boolOp» «e.toCompare»'''

	def dispatch compile(CmdWithRowCond e) '''
		«IF e.concreteCmd == Enum_CmdWithRowCond.SELECT_ROWS»
			.filter(«e.rowCondition.compileRowCondition»)
		«ENDIF»
		«IF e.concreteCmd == Enum_CmdWithRowCond.DROP_ROWS»
			.drop(«e.rowCondition.compileRowCondition»)
		«ENDIF»
	'''


}
