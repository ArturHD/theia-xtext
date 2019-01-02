package io.typefox.xtext.langserver.example.ide

import io.typefox.xtext.langserver.example.services.MyDslGrammarAccess

import java.util.Collection
import javax.inject.Inject
import org.eclipse.xtext.ide.editor.contentassist.ContentAssistContext
import org.eclipse.xtext.ide.editor.contentassist.IIdeContentProposalAcceptor
import org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalProvider

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

    override createProposals(Collection<ContentAssistContext> contexts, IIdeContentProposalAcceptor acceptor) {
		println("start here")
		super.createProposals(contexts, acceptor)
        for (context : contexts) {
			for (element : context.firstSetGrammarElements) {
				if (!acceptor.canAcceptMoreProposals) {
					return
				}
				// createProposals(element, context, acceptor)
                println("Element type: " + element)
			}
		}

	}


	
}


    /* Commented-out, example from a user (not resolved post) 
        // From post: https://www.eclipse.org/forums/index.php/t/1081951/
        @Inject
        MyDslGrammarAccess ga
        
        override createProposals(Collection<ContentAssistContext> contexts, IIdeContentProposalAcceptor acceptor) {
            super.createProposals(contexts, acceptor)
            for (context : contexts) {
                for (ge : context.firstSetGrammarElements) {
                    if (ga.barAccess.textAssignment_1 == ge) {
                        for (element : #["FooBar", "Test", "Example"].filter[startsWith(context.prefix)]) {
                            val entry = proposalCreator.createProposal(element, context)
                            val prio = proposalPriorities.getDefaultPriority(entry)
                            acceptor.accept(entry, prio)
                        }
                    }
                }
            }
        }

        /*
        From post: https://www.eclipse.org/forums/index.php/t/1081951/
        p.s. and yes you could override 
        org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalProvider.createProposals(AbstractElement, ContentAssistContext, IIdeContentProposalAcceptor)
        or
        _createProposals(Assignment assignment, ContentAssistContext context, IIdeContentProposalAcceptor acceptor) 
        or
        org.eclipse.xtext.ide.editor.contentassist.IdeContentProposalProvider._createProposals(RuleCall, ContentAssistContext, IIdeContentProposalAcceptor)
        or one of the other _createProposals methods
        as well  
        */
    */