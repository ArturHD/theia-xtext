package io.typefox.xtext.langserver.example.ide


import java.util.Collection
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ide.editor.contentassist.IIdeContentProposalAcceptor
import org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalAcceptor
import org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalProvider
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistEntry

import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalCreator
import com.google.inject.Inject
import org.eclipse.xtext.util.TextRegion

import io.typefox.xtext.langserver.example.generator.MyDslGenerator


/* Some documentation from: https://www.eclipse.org/Xtext/documentation/330_web_support.html

    Content Assist
    Content assist proposals for cross-references are created by IdeCrossrefProposalProvider, while for 
    other grammar elements IdeContentProposalProvider is used. In order to customize the proposals, create 
    subclasses of these providers and register them in your IDE Guice module.

    IdeContentProposalProvider has one _createProposals(...) dispatch method for each type of grammar 
    element. In most cases the best choice is to override the method for Assignments and to filter the 
    correct assignments by comparing them with the instances in the generated GrammarAccess of your 
    language. A proposal is submitted by creating and configuring an instance of ContentAssistEntry 
    and passing it to the given acceptor. This entry class contains all information required to display 
    the proposal in the web browser and to apply it to the document. Usually it is sent to the client 
    in JSON format.

    The typical customization point for IdeCrossrefProposalProvider is the method createProposal(...), 
    which is called for each element found by the scope provider. Here you can fine-tune the information 
    to put into the ContentAssistEntry.

    Example implementation is here: https://github.com/eclipse/xtext/blob/v2.9.0/plugins/org.eclipse.xtext.ide/src/org/eclipse/xtext/ide/editor/contentassist/IdeContentProposalProvider.xtend

*/



class MyDslIdeProposalProvider extends IdeContentProposalProvider {
	
	@Accessors(PROTECTED_GETTER)
	@Inject IdeContentProposalCreator proposalCreator

	val dslKeywordDocs = newHashMap(
		'__example__' -> #['<description>', '<documentation>' ], 
		'count' -> #['Counts number of rows', '<Action> Counts numbers of rows in a dataframe. Syntax: <dataframe> : count' ], 
		'schema' -> #['Declares a dataframe schema', '<Statement> Declares a new dataframe schema from pairs <column-name>, <column-type>.\nSyntax: [new_var =] schema (<col_name> of <col_type>)*' ], 
		'select_cols' -> #['Selects specific columns', '[Transform] Selects a specific columns of a dataframe, creating a new dataframe.\nSyntax: <dataframe> : select_cols col (<col_name>,)+' ] 		
		) 

    override createProposals(Collection<ContentAssistContext> contexts, IIdeContentProposalAcceptor acceptor) {
		// Get standard proposals
		super.createProposals(contexts, acceptor)
		
		// AA: add description and documentation to each proposal
		// To understand this, check the main "loop" which seem to translate proposals to LSP format
		// xtext-core/org.eclipse.xtext.ide/src/org/eclipse/xtext/ide/server/contentassist/ContentAssistService.xtend
		
		val myAcceptor = acceptor as IdeContentProposalAcceptor

		// Add own data to each suggestion entry
		for (ContentAssistEntry entry  : myAcceptor.getEntries() ) {
			if (entry.kind == ContentAssistEntry.KIND_KEYWORD) {
				val proposal = entry.proposal
				if (dslKeywordDocs.containsKey(proposal)) {
					val docPair = dslKeywordDocs.get(proposal)
		            entry.description = docPair.get(0)
		            entry.documentation = docPair.get(1)
				}
			} 
		}
		
		// AA: my additional content proposal
		// To understand this, check the std implementation of proposal generation:
		// org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalProvider (in method createProposals(Assignment assignment, ...) )
		// 
        for (context : contexts) {
        	// Add a new content proposal
			val proposal = '\n' + MyDslGenerator.currentContent
			val entry = proposalCreator.createProposal(proposal, context) [
				editPositions += new TextRegion(context.offset + 1, proposal.length)
				kind = ContentAssistEntry.KIND_VALUE
				description = "<Python code>"
			]
			// Set high priority to be shown as 1st
			acceptor.accept(entry, proposalPriorities.getDefaultPriority(entry) + 1000)
		}
		

	}
	
}
